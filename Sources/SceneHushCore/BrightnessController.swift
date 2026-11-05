import AppKit
import Darwin

public enum BrightnessError: LocalizedError, Equatable {
    case unavailable
    case commandTimedOut
    case commandFailed(operation: String)
    case malformedResponse
    case invalidBrightness
    case noConnectedDisplays
    case restorePending(count: Int)

    public var errorDescription: String? {
        switch self {
        case .unavailable: return "BetterDisplay is not installed or its executable is unavailable."
        case .commandTimedOut: return "BetterDisplay did not respond in time."
        case .commandFailed(let operation): return "BetterDisplay rejected the \(operation) command."
        case .malformedResponse: return "BetterDisplay returned an unrecognized display list."
        case .invalidBrightness: return "The original brightness could not be read safely."
        case .noConnectedDisplays: return "No connected displays were found."
        case .restorePending(let count): return "Brightness restoration is pending for \(count) display(s)."
        }
    }
}

public protocol CommandRunning {
    func run(executableURL: URL, arguments: [String], timeout: TimeInterval) throws -> String
}

private final class CommandOutput {
    private let lock = NSLock()
    private var storage = Data()

    func store(_ data: Data) {
        lock.lock()
        storage = data
        lock.unlock()
    }

    func text() -> String {
        lock.lock()
        defer { lock.unlock() }
        return String(data: storage, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
}

public final class ProcessCommandRunner: CommandRunning {
    public init() {}

    public func run(executableURL: URL, arguments: [String], timeout: TimeInterval) throws -> String {
        let process = Process()
        let pipe = Pipe()
        let output = CommandOutput()
        let ended = DispatchSemaphore(value: 0)
        let read = DispatchSemaphore(value: 0)
        process.executableURL = executableURL
        process.arguments = arguments
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        process.terminationHandler = { _ in ended.signal() }
        try process.run()
        // Drain stdout while the child runs; a large display list must not fill the pipe.
        DispatchQueue.global(qos: .utility).async {
            output.store(pipe.fileHandleForReading.readDataToEndOfFile())
            read.signal()
        }
        guard ended.wait(timeout: .now() + timeout) == .success else {
            if process.isRunning { process.terminate() }
            if ended.wait(timeout: .now() + 0.25) != .success {
                if process.isRunning { kill(process.processIdentifier, SIGKILL) }
                _ = ended.wait(timeout: .now() + 0.25)
            }
            throw BrightnessError.commandTimedOut
        }
        guard read.wait(timeout: .now() + 0.5) == .success else {
            throw BrightnessError.commandTimedOut
        }
        let text = output.text()
        guard process.terminationStatus == 0, text != "Failed.", !text.hasPrefix("Failed.\n") else {
            throw BrightnessError.commandFailed(operation: arguments.first ?? "requested")
        }
        return text
    }
}

public struct DisplayState: Codable, Equatable {
    public let uuid: String
    public let name: String
    public let brightness: Double
    public let autoBrightness: String?

    public init(uuid: String, name: String, brightness: Double, autoBrightness: String? = nil) {
        self.uuid = uuid
        self.name = name
        self.brightness = brightness
        self.autoBrightness = autoBrightness
    }
}

/// Run capture, dim and restore on one serial queue.
public final class BrightnessController {
    public let paths: RuntimePaths
    private let preferredExecutableURL: URL?
    private let runner: CommandRunning
    private let logger: (String) -> Void

    public init(paths: RuntimePaths = RuntimePaths(), executableURL: URL? = nil,
                runner: CommandRunning = ProcessCommandRunner(),
                logger: @escaping (String) -> Void = { _ in }) {
        self.paths = paths
        self.preferredExecutableURL = executableURL
        self.runner = runner
        self.logger = logger
    }

    public var executableURL: URL? {
        if let preferredExecutableURL { return preferredExecutableURL }
        var bundles = [URL(fileURLWithPath: "/Applications/BetterDisplay.app", isDirectory: true),
                       FileManager.default.homeDirectoryForCurrentUser
                        .appendingPathComponent("Applications/BetterDisplay.app", isDirectory: true)]
        if let registered = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "pro.betterdisplay.BetterDisplay") {
            bundles.append(registered)
        }
        return bundles.map { $0.appendingPathComponent("Contents/MacOS/BetterDisplay") }
            .first { FileManager.default.isExecutableFile(atPath: $0.path) }
    }

    public var isAvailable: Bool {
        guard let executableURL else { return false }
        return FileManager.default.isExecutableFile(atPath: executableURL.path)
    }

    public var hasPendingSnapshot: Bool {
        FileManager.default.fileExists(atPath: paths.snapshotURL.path)
    }

    public func run(_ arguments: [String]) throws -> String {
        guard let executableURL else { throw BrightnessError.unavailable }
        return try runner.run(executableURL: executableURL, arguments: arguments, timeout: 5)
    }

    public func value(_ uuid: String, _ feature: String) throws -> String {
        try run(["get", "-UUID=\(uuid)", "-\(feature)"])
    }

    public func capture() throws -> [DisplayState] {
        let identifiers = try run(["get", "-type=Display", "-identifiers"])
        let data = Data("[\(identifiers)]".utf8)
        guard let displays = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw BrightnessError.malformedResponse
        }
        var result: [DisplayState] = []
        for display in displays {
            guard let uuid = display["UUID"] as? String, !uuid.isEmpty,
                  try value(uuid, "connected") == "on" else { continue }
            guard let brightness = Double(try value(uuid, "brightness")), brightness.isFinite,
                  brightness >= 0 else { throw BrightnessError.invalidBrightness }
            let automatic = try? value(uuid, "autoBrightness")
            result.append(DisplayState(uuid: uuid, name: display["name"] as? String ?? "Display",
                                       brightness: brightness,
                                       autoBrightness: ["on", "off"].contains(automatic ?? "") ? automatic : nil))
        }
        guard !result.isEmpty else { throw BrightnessError.noConnectedDisplays }
        return result
    }

    public func save(_ states: [DisplayState]) throws {
        try paths.writePrivate(JSONEncoder().encode(states), to: paths.snapshotURL)
    }

    public func dim() throws {
        let current = try capture()
        var saved = current
        if hasPendingSnapshot {
            let pending = try loadSnapshot()
            // Keep the pre-dim value if a disconnected screen has not been restored yet.
            let pendingIDs = Set(pending.map(\.uuid))
            saved = pending + current.filter { !pendingIDs.contains($0.uuid) }
        }
        try save(saved)
        do {
            for state in current where state.autoBrightness == "on" {
                _ = try run(["set", "-UUID=\(state.uuid)", "-autoBrightness=off"])
            }
            for state in current {
                _ = try run(["set", "-UUID=\(state.uuid)", "-brightness=0"])
            }
            logger("Dimmed \(current.count) connected display(s).")
        } catch {
            do { try restore() }
            catch { logger("Rollback has pending brightness restoration.") }
            throw error
        }
    }

    public func restore() throws {
        guard hasPendingSnapshot else { return }
        let saved = try loadSnapshot()
        var pending: [DisplayState] = []
        for state in saved {
            do {
                guard try value(state.uuid, "connected") == "on" else {
                    pending.append(state)
                    continue
                }
                if state.autoBrightness == "on" {
                    _ = try run(["set", "-UUID=\(state.uuid)", "-autoBrightness=on"])
                }
                // Re-enabling automatic brightness may immediately change the slider.
                // Apply the original combined value last to preserve the user's level.
                _ = try run(["set", "-UUID=\(state.uuid)", "-brightness=\(state.brightness)"])
            } catch { pending.append(state) }
        }
        guard pending.isEmpty else {
            try save(pending)
            logger("Restoration pending for \(pending.count) display(s).")
            throw BrightnessError.restorePending(count: pending.count)
        }
        try FileManager.default.removeItem(at: paths.snapshotURL)
        logger("Restored \(saved.count) display(s).")
    }

    private func loadSnapshot() throws -> [DisplayState] {
        let states = try JSONDecoder().decode([DisplayState].self, from: Data(contentsOf: paths.snapshotURL))
        guard states.allSatisfy({ !$0.uuid.isEmpty && $0.brightness.isFinite && $0.brightness >= 0 }) else {
            throw BrightnessError.invalidBrightness
        }
        return states
    }
}
