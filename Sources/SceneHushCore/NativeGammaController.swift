import ColorSync
import CoreGraphics
import Darwin
import Foundation

public enum NativeGammaError: LocalizedError, Equatable {
    case displayListUnavailable
    case noConnectedDisplays
    case displayUnavailable
    case unsupportedDisplay
    case invalidTable
    case invalidSnapshot
    case invalidRecoveryLease
    case missingSnapshot
    case invalidProgress
    case legacyRestorationRequired
    case operationFailed(operation: String, status: Int32)
    case verificationFailed
    case restorePending(count: Int)

    public var errorDescription: String? {
        switch self {
        case .displayListUnavailable: return "The connected display list could not be read."
        case .noConnectedDisplays: return "No connected displays were found."
        case .displayUnavailable: return "A display is no longer connected."
        case .unsupportedDisplay: return "A display does not support native gamma control."
        case .invalidTable: return "A display's original gamma table could not be read safely."
        case .invalidSnapshot: return "The saved native display state is invalid."
        case .invalidRecoveryLease: return "The native recovery session identifier is invalid."
        case .missingSnapshot: return "No saved display state is available for gradual restoration."
        case .invalidProgress: return "Display restoration progress must be a finite value between 0 and 1."
        case .legacyRestorationRequired:
            return "A previous version has brightness awaiting restoration. Restore it with that version before starting a new dimming session."
        case .operationFailed(let operation, let status):
            return "macOS rejected the native display \(operation) operation (\(status))."
        case .verificationFailed: return "A display did not retain the requested gamma table."
        case .restorePending(let count): return "Native display restoration is pending for \(count) display(s)."
        }
    }
}

public struct GammaTable: Codable, Equatable {
    public let red: [Float]
    public let green: [Float]
    public let blue: [Float]

    public init(red: [Float], green: [Float], blue: [Float]) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    public var isValid: Bool {
        (2...65_536).contains(red.count) && green.count == red.count && blue.count == red.count
            && [red, green, blue].allSatisfy { $0.allSatisfy { $0.isFinite && (0...1).contains($0) } }
    }

    public var isBlack: Bool {
        isValid && [red, green, blue].allSatisfy { $0.allSatisfy { abs($0) <= 0.0001 } }
    }

    public func isApproximatelyEqual(to other: GammaTable, tolerance: Float = 0.002) -> Bool {
        guard isValid, other.isValid, tolerance.isFinite, tolerance >= 0 else { return false }
        func matches(_ values: [Float], _ reference: [Float]) -> Bool {
            for (index, value) in values.enumerated() {
                let position = Double(index) * Double(reference.count - 1) / Double(values.count - 1)
                let lower = min(Int(position), reference.count - 1)
                let upper = min(lower + 1, reference.count - 1)
                let fraction = Float(position - Double(lower))
                let expected = reference[lower] + (reference[upper] - reference[lower]) * fraction
                if abs(value - expected) > tolerance { return false }
            }
            return true
        }
        return zip([red, green, blue], [other.red, other.green, other.blue]).allSatisfy {
            matches($0.0, $0.1) && matches($0.1, $0.0)
        }
    }

    fileprivate var black: GammaTable {
        let zeros = [Float](repeating: 0, count: red.count)
        return GammaTable(red: zeros, green: zeros, blue: zeros)
    }

    fileprivate func scaled(by factor: Float) -> GammaTable {
        GammaTable(red: red.map { $0 * factor }, green: green.map { $0 * factor },
                   blue: blue.map { $0 * factor })
    }
}

public struct GammaDisplayState: Codable, Equatable {
    public let uuid: String
    public let name: String
    public let table: GammaTable

    public init(uuid: String, name: String, table: GammaTable) {
        self.uuid = uuid
        self.name = name
        self.table = table
    }
}

public struct GammaDisplay: Equatable {
    public let uuid: String
    public let name: String

    public init(uuid: String, name: String) {
        self.uuid = uuid
        self.name = name
    }
}

public protocol GammaDisplayDriving {
    func connectedDisplays() throws -> [GammaDisplay]
    func read(uuid: String) throws -> GammaTable
    func write(_ table: GammaTable, uuid: String) throws
}

public final class CoreGraphicsGammaDriver: GammaDisplayDriving {
    public init() {}

    private func displays() throws -> [(id: CGDirectDisplayID, display: GammaDisplay)] {
        var count: UInt32 = 0
        guard CGGetOnlineDisplayList(0, nil, &count) == .success, count <= 256 else {
            throw NativeGammaError.displayListUnavailable
        }
        guard count > 0 else { return [] }
        var identifiers = [CGDirectDisplayID](repeating: 0, count: Int(count))
        guard CGGetOnlineDisplayList(count, &identifiers, &count) == .success,
              count <= identifiers.count else { throw NativeGammaError.displayListUnavailable }
        var result: [(id: CGDirectDisplayID, display: GammaDisplay)] = []
        for id in identifiers.prefix(Int(count)) {
            guard let value = CGDisplayCreateUUIDFromDisplayID(id)?.takeRetainedValue() else {
                throw NativeGammaError.displayListUnavailable
            }
            let uuid = CFUUIDCreateString(nil, value) as String
            let name = CGDisplayIsBuiltin(id) != 0 ? "Built-in display" : "External display"
            result.append((id, GammaDisplay(uuid: uuid, name: name)))
        }
        guard Set(result.map { $0.display.uuid }).count == result.count else {
            throw NativeGammaError.displayListUnavailable
        }
        return result
    }

    public func connectedDisplays() throws -> [GammaDisplay] {
        try displays().map(\.display)
    }

    private func displayID(for uuid: String) throws -> CGDirectDisplayID {
        guard let display = try displays().first(where: { $0.display.uuid == uuid }) else {
            throw NativeGammaError.displayUnavailable
        }
        return display.id
    }

    public func read(uuid: String) throws -> GammaTable {
        let id = try displayID(for: uuid)
        let capacity = CGDisplayGammaTableCapacity(id)
        guard (2...65_536).contains(capacity) else { throw NativeGammaError.unsupportedDisplay }
        var red = [CGGammaValue](repeating: 0, count: Int(capacity))
        var green = red
        var blue = red
        var samples: UInt32 = 0
        let status = CGGetDisplayTransferByTable(id, capacity, &red, &green, &blue, &samples)
        guard status == .success else {
            throw NativeGammaError.operationFailed(operation: "read", status: status.rawValue)
        }
        guard samples <= capacity else { throw NativeGammaError.invalidTable }
        let table = GammaTable(red: Array(red.prefix(Int(samples))),
                               green: Array(green.prefix(Int(samples))), blue: Array(blue.prefix(Int(samples))))
        guard table.isValid else { throw NativeGammaError.invalidTable }
        return table
    }

    public func write(_ table: GammaTable, uuid: String) throws {
        guard table.isValid else { throw NativeGammaError.invalidTable }
        let id = try displayID(for: uuid)
        let status = CGSetDisplayTransferByTable(id, UInt32(table.red.count), table.red, table.green, table.blue)
        guard status == .success else {
            throw NativeGammaError.operationFailed(operation: "write", status: status.rawValue)
        }
    }
}

/// Call capture, dim, progress updates, verification and restore on the same serial queue.
public final class NativeGammaController {
    public let paths: RuntimePaths
    private let driver: GammaDisplayDriving
    private let logger: (String) -> Void
    private let maximumSnapshotBytes = 16 * 1_024 * 1_024

    public init(paths: RuntimePaths = RuntimePaths(), driver: GammaDisplayDriving = CoreGraphicsGammaDriver(),
                logger: @escaping (String) -> Void = { _ in }) {
        self.paths = paths
        self.driver = driver
        self.logger = logger
    }

    public var hasPendingSnapshot: Bool {
        FileManager.default.fileExists(atPath: paths.nativeSnapshotURL.path)
    }

    public var recoveryLeaseURL: URL {
        paths.supportDirectory.appendingPathComponent("native-recovery-owner")
    }

    public func claimRecoveryLease(_ token: String) throws {
        guard UUID(uuidString: token) != nil else { throw NativeGammaError.invalidRecoveryLease }
        try withExclusiveAccess {
            try paths.writePrivate(Data(token.utf8), to: recoveryLeaseURL)
        }
    }

    @discardableResult
    public func restore(ifRecoveryLease token: String) throws -> Bool {
        guard UUID(uuidString: token) != nil else { throw NativeGammaError.invalidRecoveryLease }
        return try withExclusiveAccess {
            guard FileManager.default.fileExists(atPath: recoveryLeaseURL.path) else { return false }
            let owner = try String(contentsOf: recoveryLeaseURL, encoding: .utf8)
            guard owner == token else { return false }
            try restoreUnlocked()
            return true
        }
    }

    public func capture() throws -> [GammaDisplayState] {
        try withExclusiveAccess { try captureUnlocked() }
    }

    private func captureUnlocked() throws -> [GammaDisplayState] {
        let displays = try driver.connectedDisplays()
        guard !displays.isEmpty else { throw NativeGammaError.noConnectedDisplays }
        guard validIdentifiers(displays.map(\.uuid)) else { throw NativeGammaError.displayListUnavailable }
        return try displays.map {
            let table = try driver.read(uuid: $0.uuid)
            guard table.isValid else { throw NativeGammaError.invalidTable }
            return GammaDisplayState(uuid: $0.uuid, name: $0.name, table: table)
        }
    }

    public func dim() throws {
        try withExclusiveAccess { try dimUnlocked() }
    }

    private func dimUnlocked() throws {
        let pending = hasPendingSnapshot ? try loadSnapshot() : []
        let current = try captureUnlocked()
        let pendingIDs = Set(pending.map(\.uuid))
        let saved = pending + current.filter { !pendingIDs.contains($0.uuid) }
        try save(saved)
        do {
            for state in current {
                try driver.write(state.table.black, uuid: state.uuid)
                guard try driver.read(uuid: state.uuid).isBlack else { throw NativeGammaError.verificationFailed }
            }
            logger("Dimmed \(current.count) display(s) with native gamma control.")
        } catch {
            let originalError = error
            do { try restoreUnlocked() }
            catch { logger("Native rollback has pending display restoration.") }
            throw originalError
        }
    }

    public func restore() throws {
        try withExclusiveAccess { try restoreUnlocked() }
    }

    /// Progress always derives from saved originals, never from a previously scaled table.
    /// Call `restore()` after the last frame, on cancellation, or before leaving the demo.
    public func setRestoreProgress(_ progress: Double) throws {
        guard progress.isFinite, (0...1).contains(progress) else { throw NativeGammaError.invalidProgress }
        try withExclusiveAccess {
            guard hasPendingSnapshot else { throw NativeGammaError.missingSnapshot }
            let saved = try loadSnapshot()
            do {
                let connected = try driver.connectedDisplays().map(\.uuid)
                guard validIdentifiers(connected) else { throw NativeGammaError.displayListUnavailable }
                guard Set(saved.map(\.uuid)).isSubset(of: Set(connected)) else {
                    throw NativeGammaError.displayUnavailable
                }
                for state in saved {
                    let target = state.table.scaled(by: Float(progress))
                    try driver.write(target, uuid: state.uuid)
                    guard try driver.read(uuid: state.uuid).isApproximatelyEqual(to: target) else {
                        throw NativeGammaError.verificationFailed
                    }
                }
            } catch {
                let originalError = error
                do { try restoreUnlocked() }
                catch { logger("Gradual restoration rollback has pending display restoration.") }
                throw originalError
            }
        }
    }

    private func restoreUnlocked() throws {
        guard hasPendingSnapshot else { return }
        let saved = try loadSnapshot()
        let connectedIDs = Set(try driver.connectedDisplays().map(\.uuid))
        var pending: [GammaDisplayState] = []
        for state in saved {
            guard connectedIDs.contains(state.uuid) else { pending.append(state); continue }
            do {
                try driver.write(state.table, uuid: state.uuid)
                guard try driver.read(uuid: state.uuid).isApproximatelyEqual(to: state.table) else {
                    throw NativeGammaError.verificationFailed
                }
            } catch { pending.append(state) }
        }
        guard pending.isEmpty else {
            try save(pending)
            logger("Native restoration pending for \(pending.count) display(s).")
            throw NativeGammaError.restorePending(count: pending.count)
        }
        try FileManager.default.removeItem(at: paths.nativeSnapshotURL)
        logger("Restored \(saved.count) native display table(s).")
    }

    public func verifyDark() throws {
        try withExclusiveAccess {
            guard try captureUnlocked().allSatisfy({ $0.table.isBlack }) else { throw NativeGammaError.verificationFailed }
        }
    }

    public func verifyRestored(_ states: [GammaDisplayState]) throws {
        try withExclusiveAccess {
            guard validStates(states) else { throw NativeGammaError.invalidSnapshot }
            for state in states {
                guard try driver.read(uuid: state.uuid).isApproximatelyEqual(to: state.table) else {
                    throw NativeGammaError.verificationFailed
                }
            }
        }
    }

    private func withExclusiveAccess<T>(_ body: () throws -> T) throws -> T {
        try paths.ensureDirectory()
        let url = paths.supportDirectory.appendingPathComponent("native-display.lock")
        let descriptor = open(url.path, O_CREAT | O_RDWR | O_CLOEXEC | O_NOFOLLOW, mode_t(0o600))
        guard descriptor >= 0 else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        defer { close(descriptor) }
        guard fchmod(descriptor, mode_t(0o600)) == 0 else {
            throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO)
        }
        while flock(descriptor, LOCK_EX) != 0 {
            guard errno == EINTR else { throw POSIXError(POSIXErrorCode(rawValue: errno) ?? .EIO) }
        }
        defer { flock(descriptor, LOCK_UN) }
        return try body()
    }

    private func validIdentifiers(_ identifiers: [String]) -> Bool {
        !identifiers.isEmpty && identifiers.count <= 256
            && identifiers.allSatisfy { !$0.isEmpty && $0.utf8.count <= 256 }
            && Set(identifiers).count == identifiers.count
    }

    private func validStates(_ states: [GammaDisplayState]) -> Bool {
        validIdentifiers(states.map(\.uuid)) && states.allSatisfy { $0.table.isValid }
    }

    private func save(_ states: [GammaDisplayState]) throws {
        guard validStates(states) else { throw NativeGammaError.invalidSnapshot }
        let data = try JSONEncoder().encode(states)
        guard data.count <= maximumSnapshotBytes else { throw NativeGammaError.invalidSnapshot }
        try paths.writePrivate(data, to: paths.nativeSnapshotURL)
    }

    private func loadSnapshot() throws -> [GammaDisplayState] {
        let attributes = try FileManager.default.attributesOfItem(atPath: paths.nativeSnapshotURL.path)
        guard let size = attributes[.size] as? NSNumber, size.uint64Value <= maximumSnapshotBytes else {
            throw NativeGammaError.invalidSnapshot
        }
        let data = try Data(contentsOf: paths.nativeSnapshotURL)
        guard let states = try? JSONDecoder().decode([GammaDisplayState].self, from: data), validStates(states) else {
            throw NativeGammaError.invalidSnapshot
        }
        return states
    }
}
