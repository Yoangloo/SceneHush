import AppKit
import ServiceManagement
import SceneHushCore

func liveTest() throws {
    let controller = BrightnessController()
    guard !controller.hasPendingSnapshot else { throw BrightnessError.commandFailed(operation: "Restore existing snapshot before testing") }
    let before = try controller.capture()
    try controller.dim()
    defer { try? controller.restore() }
    for display in before {
        guard Double(try controller.value(display.uuid, "brightness")) == 0 else {
            throw BrightnessError.commandFailed(operation: "A display did not reach zero")
        }
        print("\(display.name): \(display.brightness) → 0")
    }
    Thread.sleep(forTimeInterval: 1)
    try controller.restore()
    Thread.sleep(forTimeInterval: 1)
    for display in before {
        guard let actual = Double(try controller.value(display.uuid, "brightness")),
              abs(actual - display.brightness) < 0.005 else {
            throw BrightnessError.commandFailed(operation: "A display did not restore its saved brightness")
        }
        print("\(display.name): restored \(display.brightness)")
    }
}

final class PreviewActions: SettingsActions {
    var configuration = Configuration()
    var localizer: Localizer { Localizer(configuration.language) }
    let backendAvailable = true
    let loginEnabled = true
    let lastIssue: String? = nil
    func setCorner(_ corner: Corner) { configuration.selectedCorner = corner }
    func setLanguage(_ language: AppLanguage) { configuration.language = language }
    func setRestoreOnExit(_ value: Bool) { configuration.restoreOnExit = value }
    func setEnabled(_ value: Bool) { configuration.enabled = value }
    func setLoginEnabled(_ value: Bool) {}
    func restoreNow() {}
    func restoreSystemCorners() {}
}

func renderPreviews(at directory: String) throws {
    let actions = PreviewActions()
    let output = URL(fileURLWithPath: directory, isDirectory: true)
    try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
    for language: AppLanguage in [.en, .zhHans, .ja] {
        actions.setLanguage(language)
        let controller = SettingsWindowController(actions: actions)
        guard let view = controller.window?.contentView else { continue }
        view.layoutSubtreeIfNeeded()
        guard let bitmap = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { continue }
        view.cacheDisplay(in: view.bounds, to: bitmap)
        if let data = bitmap.representation(using: .png, properties: [:]) {
            try data.write(to: output.appendingPathComponent("settings-\(actions.localizer.code).png"))
        }
        controller.close()
    }
}

do {
    let args = CommandLine.arguments
    if args.contains("--check-localizations") {
        let english = Localizer.load("en")
        guard !english.isEmpty else { throw BrightnessError.commandFailed(operation: "Missing English resources") }
        for code in ["en", "zh-Hans", "ja"] {
            let strings = Localizer.load(code)
            guard Set(strings.keys) == Set(english.keys), strings.values.allSatisfy({ !$0.isEmpty }) else {
                throw BrightnessError.commandFailed(operation: "Incomplete localization: \(code)")
            }
            print("PASS \(code): \(strings.count) strings")
        }
    } else if args.contains("--enable-login") {
        try SMAppService.mainApp.register()
        print("Launch at login status: \(SMAppService.mainApp.status.rawValue)")
    } else if args.contains("--disable-login") {
        try SMAppService.mainApp.unregister()
    } else if args.contains("--restore") {
        DistributedNotificationCenter.default().postNotificationName(restoreNotification, object: nil, userInfo: nil, deliverImmediately: true)
    } else if args.contains("--recover") {
        try BrightnessController().restore()
    } else if args.contains("--live-test") {
        try liveTest()
    } else if let index = args.firstIndex(of: "--render-previews"), args.count > index + 1 {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        app.appearance = NSAppearance(named: .aqua)
        try renderPreviews(at: args[index + 1])
    } else {
        let app = NSApplication.shared
        let other = NSRunningApplication.runningApplications(withBundleIdentifier: "io.github.yoangloo.SceneHush")
            .first { $0.processIdentifier != ProcessInfo.processInfo.processIdentifier }
        if let other = other {
            other.activate(options: .activateIgnoringOtherApps)
        } else {
            let delegate = AppDelegate()
            app.setActivationPolicy(.accessory)
            app.delegate = delegate
            app.run()
        }
    }
} catch {
    fputs("SceneHush: \(error.localizedDescription)\n", stderr)
    exit(1)
}
