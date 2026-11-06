import Foundation

/// Run dimming, progress updates and recovery on the app's serial display queue.
public final class DisplayDimmingController {
    public let native: NativeGammaController
    private let paths: RuntimePaths

    public init(paths: RuntimePaths = RuntimePaths(), logger: @escaping (String) -> Void = { _ in }) {
        self.paths = paths
        native = NativeGammaController(paths: paths, logger: logger)
    }

    public var hasPendingSnapshot: Bool { native.hasPendingSnapshot }

    /// Historical recovery data is retained, without executing the removed display integration.
    public var hasLegacySnapshot: Bool {
        FileManager.default.fileExists(atPath: paths.legacySnapshotURL.path)
    }

    public func dim() throws {
        guard !hasLegacySnapshot else { throw NativeGammaError.legacyRestorationRequired }
        try native.dim()
    }

    public func setRestoreProgress(_ progress: Double) throws {
        try native.setRestoreProgress(progress)
    }

    public func restore() throws {
        try native.restore()
    }
}
