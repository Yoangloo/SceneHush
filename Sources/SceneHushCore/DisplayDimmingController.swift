import Foundation

/// Both backends run on the app's serial display queue, including recovery.
public final class DisplayDimmingController {
    public let native: NativeGammaController
    public let betterDisplay: BrightnessController

    public init(paths: RuntimePaths = RuntimePaths(), logger: @escaping (String) -> Void = { _ in }) {
        native = NativeGammaController(paths: paths, logger: logger)
        betterDisplay = BrightnessController(paths: paths, logger: logger)
    }

    public var hasPendingSnapshot: Bool { native.hasPendingSnapshot || betterDisplay.hasPendingSnapshot }

    public func isAvailable(_ method: DimmingMethod) -> Bool {
        method == .native || betterDisplay.isAvailable
    }

    public func dim(using method: DimmingMethod) throws {
        switch method {
        case .native:
            try betterDisplay.restore()
            try native.dim()
        case .betterDisplay:
            try native.restore()
            try betterDisplay.dim()
        }
    }

    public func restore() throws {
        var failures: [Error] = []
        do { try native.restore() } catch { failures.append(error) }
        // Preserve and recover snapshots made before the standalone engine existed.
        do { try betterDisplay.restore() } catch { failures.append(error) }
        if let error = failures.first { throw error }
    }
}
