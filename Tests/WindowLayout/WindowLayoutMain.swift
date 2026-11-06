import AppKit
import SwiftUI
import SceneHushCore

extension Bundle { static var module: Bundle { .main } }

private final class WindowActions: OnboardingActions {
    var configuration = Configuration(language: .en, onboardingCompleted: true)
    var localizer: Localizer { Localizer(configuration.language) }
    let loginEnabled = false
    let lastIssue: String? = nil
    func setCorner(_ value: Corner) { configuration.selectedCorner = value }
    func setLanguage(_ value: AppLanguage) { configuration.language = value }
    func setRestoreOnExit(_ value: Bool) { configuration.restoreOnExit = value }
    func setEnabled(_ value: Bool) { configuration.enabled = value }
    func setLoginEnabled(_ value: Bool) {}
    func showOnboarding() {}
    func finishOnboarding() {}
    func onboardingClosed() {}
    func restoreNow() { fatalError("Display operations are excluded from this check.") }
    func restoreSystemCorners() { fatalError("User settings must not be changed.") }
    func startDemonstration(progress: @escaping (Double) -> Void, completion: @escaping (Result<Void, Error>) -> Void) {
        fatalError("Display operations are excluded from this check.")
    }
    func cancelDemonstration(completion: @escaping (Result<Void, Error>) -> Void) {
        fatalError("Display operations are excluded from this check.")
    }
}

@main private struct WindowLayoutCheck {
    static func rect(_ value: NSRect) -> [Double] { [value.minX, value.minY, value.width, value.height] }
    static func same(_ lhs: NSRect, _ rhs: NSRect) -> Bool {
        zip(rect(lhs), rect(rhs)).allSatisfy { abs($0 - $1) < 0.6 }
    }
    static func settle(_ seconds: Double) { RunLoop.current.run(until: Date().addingTimeInterval(seconds)) }
    static func main() throws {
        NSApplication.shared.setActivationPolicy(.accessory)
        let actions = WindowActions()
        let settings = SettingsWindowController(actions: actions)
        let onboarding = OnboardingWindowController(actions: actions)
        let screens = NSScreen.screens
        guard !screens.isEmpty else { throw CocoaError(.featureUnsupported) }
        var records: [[String: Any]] = []
        var passed = true
        for (name, controller) in [("settings", settings as NSWindowController), ("onboarding", onboarding)] {
            guard let window = controller.window, let view = window.contentView else { throw CocoaError(.featureUnsupported) }
            window.orderBack(nil)
            settle(0.2)
            let originalSize = window.frame.size
            let centers = screens.map { NSPoint(x: $0.visibleFrame.midX - originalSize.width / 2,
                                                y: $0.visibleFrame.midY - originalSize.height / 2) }
            var points = centers
            if centers.count > 1 {
                for step in 1...8 {
                    let amount = Double(step) / 8
                    points.append(NSPoint(x: centers[0].x + (centers[1].x - centers[0].x) * amount,
                                          y: centers[0].y + (centers[1].y - centers[0].y) * amount))
                }
            }
            for (index, language) in [AppLanguage.en, .zhHans, .ja].enumerated() {
                for point in points {
                    window.setFrameOrigin(point)
                    let acceptedFrame = window.frame // AppKit may constrain requests to its visible area.
                    actions.configuration.language = language
                    settings.rebuild(); onboarding.rebuild()
                    if name == "onboarding" { onboarding.model.stage = index == 0 ? .welcome : .permissions }
                    window.appearance = NSAppearance(named: index % 2 == 0 ? .aqua : .darkAqua)
                    view.layoutSubtreeIfNeeded(); window.displayIfNeeded()
                    settle(0.25)
                    let stable = same(window.frame, acceptedFrame) && window.frame.size == originalSize
                    let minimumFits = name != "settings" || (view.fittingSize.width >= 559.5 && view.fittingSize.height >= 699.5)
                    passed = passed && stable && minimumFits
                    records.append(["window": name, "language": actions.localizer.code,
                                    "acceptedFrame": rect(acceptedFrame), "settledFrame": rect(window.frame),
                                    "frameStable": stable, "minimumFits": minimumFits,
                                    "screen": window.screen?.localizedName ?? "none", "scale": window.backingScaleFactor])
                }
            }
            window.close()
        }
        let report: [String: Any] = ["result": passed ? "PASS" : "FAIL", "records": records,
                                    "connectedDisplays": screens.count, "gammaOperations": 0,
                                    "mouseDragSynthesized": false, "usesFakeActions": true]
        let data = try JSONSerialization.data(withJSONObject: report, options: [.prettyPrinted, .sortedKeys])
        try data.write(to: URL(fileURLWithPath: CommandLine.arguments[1]), options: .atomic)
        print("\(passed ? "PASS" : "FAIL"): \(records.count) window-frame checks on \(screens.count) connected display(s). No display control or user settings changed.")
        exit(passed ? 0 : 1)
    }
}
