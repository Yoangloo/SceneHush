import Foundation
import SceneHushCore

final class DisplayRecoveryMonitor {
    private let paths: RuntimePaths
    private var process: Process?
    private var lifetime: Pipe?
    private var ended: DispatchSemaphore?
    private var sessionToken: String?

    init(paths: RuntimePaths) { self.paths = paths }

    /// EOF reaches the child even if the parent is force-quit or crashes.
    func startIfNeeded() throws {
        if process?.isRunning == true, let sessionToken {
            try NativeGammaController(paths: paths).claimRecoveryLease(sessionToken)
            return
        }
        let token = UUID().uuidString
        try NativeGammaController(paths: paths).claimRecoveryLease(token)
        let child = Process()
        let input = Pipe()
        let completion = DispatchSemaphore(value: 0)
        child.executableURL = URL(fileURLWithPath: CommandLine.arguments[0]).standardizedFileURL
        child.arguments = ["--watch-recovery", paths.supportDirectory.path, token]
        child.standardInput = input
        child.standardOutput = FileHandle.nullDevice
        child.standardError = FileHandle.nullDevice
        child.terminationHandler = { _ in completion.signal() }
        try child.run()
        try? input.fileHandleForReading.close()
        process = child
        lifetime = input
        ended = completion
        sessionToken = token
    }

    func finish() {
        try? lifetime?.fileHandleForWriting.close()
        if process?.isRunning == true { _ = ended?.wait(timeout: .now() + 2) }
        lifetime = nil
        process = nil
        ended = nil
        sessionToken = nil
    }
}

func watchRecovery(in directory: String, token: String) throws {
    // This is a child of SceneHush, not an installed background daemon.
    _ = FileHandle.standardInput.readDataToEndOfFile()
    let paths = RuntimePaths(supportDirectory: URL(fileURLWithPath: directory, isDirectory: true))
    let controller = NativeGammaController(paths: paths)
    for attempt in 0..<3 {
        do { _ = try controller.restore(ifRecoveryLease: token); return }
        catch {
            if attempt == 2 { throw error }
            Thread.sleep(forTimeInterval: 0.25)
        }
    }
}
