import Darwin
import Foundation

public enum LocalCommandError: LocalizedError, Equatable {
    case timeout
    case failed(operation: String)

    public var errorDescription: String? {
        switch self {
        case .timeout: return "The local command did not complete in time."
        case .failed(let operation): return "The local \(operation) command failed."
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
        guard timeout.isFinite, timeout > 0 else { throw LocalCommandError.timeout }
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
        // Drain while the command runs so output larger than the pipe cannot block it.
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
            throw LocalCommandError.timeout
        }
        guard read.wait(timeout: .now() + 0.5) == .success else { throw LocalCommandError.timeout }
        guard process.terminationStatus == 0 else {
            throw LocalCommandError.failed(operation: arguments.first ?? executableURL.lastPathComponent)
        }
        return output.text()
    }
}
