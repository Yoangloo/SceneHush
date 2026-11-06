import Foundation
import SceneHushCore

enum DisplayDemonstrationError: LocalizedError {
    case invalidDuration
    case alreadyRunning

    var errorDescription: String? {
        switch self {
        case .invalidDuration: return "The display demonstration needs a positive, finite duration."
        case .alreadyRunning: return "A display demonstration is already running."
        }
    }
}

/// The queue must be the app's serial display worker, shared with normal dimming.
final class DisplayDemonstration {
    private let controller: DisplayDimmingController
    private let recovery: DisplayRecoveryMonitor
    private let queue: DispatchQueue
    private var timer: DispatchSourceTimer?
    private var operation: UInt64 = 0
    private var completion: ((Result<Void, Error>) -> Void)?

    init(controller: DisplayDimmingController, recovery: DisplayRecoveryMonitor, queue: DispatchQueue) {
        self.controller = controller
        self.recovery = recovery
        self.queue = queue
    }

    func start(duration: TimeInterval = 5, progress: @escaping (Double) -> Void,
               completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async {
            guard duration.isFinite, duration > 0 else {
                DispatchQueue.main.async { completion(.failure(DisplayDemonstrationError.invalidDuration)) }
                return
            }
            guard self.completion == nil else {
                DispatchQueue.main.async { completion(.failure(DisplayDemonstrationError.alreadyRunning)) }
                return
            }
            self.operation &+= 1
            let operation = self.operation
            self.completion = completion
            do {
                try self.controller.restore()
                try self.recovery.startIfNeeded()
                try self.controller.dim()
            } catch {
                self.finish(operation: operation, result: .failure(error))
                return
            }

            let start = DispatchTime.now().uptimeNanoseconds
            self.deliver(operation: operation) { progress(0) }
            let timer = DispatchSource.makeTimerSource(queue: self.queue)
            timer.schedule(deadline: .now() + 1.0 / 30.0,
                           repeating: .nanoseconds(33_333_333), leeway: .milliseconds(3))
            timer.setEventHandler {
                guard self.operation == operation, self.completion != nil else { return }
                let elapsed = Double(DispatchTime.now().uptimeNanoseconds - start) / 1_000_000_000
                let fraction = min(elapsed / duration, 1)
                let eased = fraction * fraction * (3 - 2 * fraction)
                do {
                    try self.controller.setRestoreProgress(eased)
                    self.deliver(operation: operation) { progress(fraction) }
                    if fraction >= 1 { self.finish(operation: operation, result: .success(())) }
                } catch {
                    self.finish(operation: operation, result: .failure(error))
                }
            }
            self.timer = timer
            timer.resume()
        }
    }

    func cancel(completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async {
            self.operation &+= 1
            let wasRunning = self.completion != nil
            self.completion = nil
            self.stopTimer()
            // An idle cancellation must not restore an unrelated hot-corner session.
            let result: Result<Void, Error> = wasRunning
                ? Result { try self.controller.restore() }
                : .success(())
            DispatchQueue.main.async { completion(result) }
        }
    }

    private func finish(operation: UInt64, result: Result<Void, Error>) {
        guard self.operation == operation, let completion else { return }
        self.completion = nil
        stopTimer()
        var finalResult = result
        do { try controller.restore() }
        catch {
            // Keep the original failure; the engine retains any pending recovery data.
            if case .success = result { finalResult = .failure(error) }
        }
        let deliveredResult = finalResult
        deliver(operation: operation) { completion(deliveredResult) }
    }

    private func stopTimer() {
        timer?.setEventHandler {}
        timer?.cancel()
        timer = nil
    }

    private func deliver(operation: UInt64, _ callback: @escaping () -> Void) {
        DispatchQueue.main.async {
            // Check on the worker so cancellation also suppresses callbacks already queued here.
            guard self.queue.sync(execute: { self.operation == operation }) else { return }
            callback()
        }
    }
}
