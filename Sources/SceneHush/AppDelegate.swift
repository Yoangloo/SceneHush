import AppKit
import ServiceManagement
import SceneHushCore

let restoreNotification = Notification.Name("io.github.yoangloo.SceneHush.restore")

final class AppDelegate: NSObject, NSApplicationDelegate, SettingsActions {
    enum Phase { case idle, dimming, dark, restoring }
    let paths = RuntimePaths()
    lazy var store = ConfigurationStore(paths: paths)
    lazy var nativeCorners = NativeHotCorners(paths: paths)
    lazy var controller = BrightnessController(paths: paths, logger: { [weak self] in self?.log($0) })
    let worker = DispatchQueue(label: "io.github.yoangloo.SceneHush.brightness")
    var configuration = Configuration()
    var localizer: Localizer { Localizer(configuration.language) }
    var backendAvailable: Bool { controller.isAvailable }
    var loginEnabled: Bool { SMAppService.mainApp.status == .enabled }
    var lastIssue: String?
    var item: NSStatusItem!
    var settings: SettingsWindowController?
    var timer: Timer?
    var phase: Phase = .idle
    var previousInside: Bool?
    var wantDim = false
    var recoveryRequested = false
    var quitting = false
    var cornerConflict = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        let firstLaunch = !FileManager.default.fileExists(atPath: paths.configURL.path)
        do { try paths.ensureDirectory(); configuration = try store.load() }
        catch { lastIssue = localizer("error.config"); log(error.localizedDescription); configuration.enabled = false }
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.title = ""
        item.button?.imagePosition = .imageOnly
        cornerConflict = nativeCorners.hasConflict(configuration.selectedCorner)
        refresh()
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(restoreNow),
                                                           name: restoreNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displaysChanged),
                                               name: NSApplication.didChangeScreenParametersNotification, object: nil)
        for name in [NSWorkspace.willSleepNotification, NSWorkspace.didWakeNotification, NSWorkspace.sessionDidResignActiveNotification] {
            NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(displaysChanged), name: name, object: nil)
        }
        if controller.hasPendingSnapshot { recoveryRequested = true; reconcile() }
        timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in self?.tick() }
        timer?.tolerance = 0.025
        RunLoop.main.add(timer!, forMode: .common)
        if firstLaunch || !backendAvailable || CommandLine.arguments.contains("--settings") {
            showSettings()
        }
        if cornerConflict { DispatchQueue.main.async { self.resolveInitialConflict() } }
        log("Started SceneHush")
    }

    func log(_ message: String) {
        let line = "\(ISO8601DateFormatter().string(from: Date())) \(message)\n"
        let url = paths.supportDirectory.appendingPathComponent("events.log")
        guard let data = line.data(using: .utf8) else { return }
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: [.posixPermissions: 0o600])
        }
        if let handle = try? FileHandle(forWritingTo: url) {
            defer { try? handle.close() }
            _ = try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
        }
    }

    func refresh() {
        let l = localizer
        item?.button?.image = NSImage(systemSymbolName: phase == .dark ? "moon.fill" : "sun.min", accessibilityDescription: "SceneHush")
        item?.button?.toolTip = "SceneHush — " + l("subtitle")
        let menu = NSMenu()
        @discardableResult func add(_ title: String, _ action: Selector?, to parent: NSMenu? = nil, tag: Int = 0, selected: Bool = false) -> NSMenuItem {
            let entry = NSMenuItem(title: title, action: action, keyEquivalent: "")
            entry.target = self; entry.tag = tag; entry.state = selected ? .on : .off
            (parent ?? menu).addItem(entry)
            return entry
        }
        add("SceneHush", nil)
        add(l("enabled"), #selector(toggleEnabled), selected: configuration.enabled)
        let cornerMenu = NSMenu()
        for (index, corner) in Corner.allCases.enumerated() {
            _ = add(l.corner(corner), #selector(chooseCorner), to: cornerMenu, tag: index, selected: corner == configuration.selectedCorner)
        }
        add(l("corner.label") + ": " + l.corner(configuration.selectedCorner), nil).submenu = cornerMenu
        let restoreMenu = NSMenu()
        add(l("restore.onExit"), #selector(chooseRestore), to: restoreMenu, tag: 0, selected: configuration.restoreOnExit)
        add(l("restore.onReentry"), #selector(chooseRestore), to: restoreMenu, tag: 1, selected: !configuration.restoreOnExit)
        add(l("restore.label"), nil).submenu = restoreMenu
        let languages = NSMenu()
        for (index, language) in AppLanguage.allCases.enumerated() {
            add(l.language(language), #selector(chooseLanguage), to: languages, tag: index, selected: language == configuration.language)
        }
        add(l("language.label"), nil).submenu = languages
        add(l("login"), #selector(toggleLogin), selected: loginEnabled)
        menu.addItem(.separator())
        add(l("restore.now"), #selector(restoreNow))
        add(l("settings"), #selector(showSettings))
        add(l("about"), #selector(about))
        menu.addItem(.separator())
        add(l("quit"), #selector(quit))
        item?.menu = menu
        settings?.rebuild()
    }

    func tick() {
        let inside = NSScreen.screens.contains { configuration.selectedCorner.contains(point: NSEvent.mouseLocation, in: $0.frame) }
        defer { previousInside = inside }
        guard configuration.enabled, !quitting, !cornerConflict else { return }
        guard let previous = previousInside else { return }
        if configuration.restoreOnExit {
            if inside != previous { wantDim = inside; reconcile() }
        } else if inside && !previous {
            wantDim.toggle(); reconcile()
        }
    }

    func reconcile() {
        guard phase != .dimming && phase != .restoring else { return }
        if (phase == .dark && !wantDim) || recoveryRequested {
            phase = .restoring; recoveryRequested = false
            worker.async {
                let result = Result { try self.controller.restore() }
                DispatchQueue.main.async {
                    self.phase = .idle
                    if case .failure(let error) = result { self.lastIssue = self.localizer("error.restore"); self.log(error.localizedDescription) }
                    self.refresh()
                    if self.quitting { NSApp.reply(toApplicationShouldTerminate: true) }
                    else { self.reconcile() }
                }
            }
        } else if phase == .idle && wantDim && !quitting {
            phase = .dimming
            worker.async {
                let result = Result { try self.controller.dim() }
                DispatchQueue.main.async {
                    switch result {
                    case .success: self.phase = .dark; self.lastIssue = nil
                    case .failure(let error):
                        self.phase = .idle; self.wantDim = false
                        self.lastIssue = self.localizer("error.dim"); self.log(error.localizedDescription)
                        self.showSettings()
                    }
                    self.refresh(); self.reconcile()
                }
            }
        } else if quitting { NSApp.reply(toApplicationShouldTerminate: true) }
    }

    func persist() {
        do { try store.save(configuration) }
        catch { lastIssue = localizer("error.config"); log(error.localizedDescription) }
        refresh()
    }

    func setCorner(_ corner: Corner) {
        if nativeCorners.hasConflict(corner) && !confirmReplacingCorner() { refresh(); return }
        if nativeCorners.hasConflict(corner) {
            do { try nativeCorners.replace(corner) }
            catch { showError(error); return }
        }
        wantDim = false; recoveryRequested = true; reconcile()
        configuration.selectedCorner = corner; previousInside = nil; cornerConflict = false; persist()
    }
    func setLanguage(_ language: AppLanguage) { configuration.language = language; lastIssue = nil; persist() }
    func setRestoreOnExit(_ value: Bool) {
        configuration.restoreOnExit = value
        if value && previousInside != true { wantDim = false; reconcile() }
        persist()
    }
    func setEnabled(_ value: Bool) {
        configuration.enabled = value
        if !value { restoreNow() }
        previousInside = nil; persist()
    }
    func setLoginEnabled(_ value: Bool) {
        do {
            if value { try SMAppService.mainApp.register() }
            else { try SMAppService.mainApp.unregister() }
            if SMAppService.mainApp.status == .requiresApproval { SMAppService.openSystemSettingsLoginItems() }
        } catch { showError(error) }
        refresh()
    }

    @objc func restoreNow() { wantDim = false; recoveryRequested = true; reconcile() }
    @objc func displaysChanged() {
        previousInside = nil
        cornerConflict = nativeCorners.hasConflict(configuration.selectedCorner)
        restoreNow()
    }
    @objc func showSettings() {
        if settings == nil { settings = SettingsWindowController(actions: self) }
        settings?.rebuild(); settings?.show()
    }
    @objc func toggleEnabled() { setEnabled(!configuration.enabled) }
    @objc func chooseCorner(_ sender: NSMenuItem) { setCorner(Corner.allCases[sender.tag]) }
    @objc func chooseLanguage(_ sender: NSMenuItem) { setLanguage(AppLanguage.allCases[sender.tag]) }
    @objc func chooseRestore(_ sender: NSMenuItem) { setRestoreOnExit(sender.tag == 0) }
    @objc func toggleLogin() { setLoginEnabled(!loginEnabled) }
    @objc func quit() { NSApp.terminate(nil) }
    @objc func about() {
        let alert = NSAlert()
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Development"
        alert.messageText = "SceneHush " + version
        alert.informativeText = localizer("purpose") + "\n\n" + localizer("risk") + "\n\nMIT · © 2026 Yoangloo"
        alert.runModal()
    }
    func showError(_ error: Error) {
        log(error.localizedDescription)
        lastIssue = localizer("error.generic")
        let alert = NSAlert(); alert.messageText = "SceneHush"
        alert.informativeText = localizer("error.generic") + "\n\n" + error.localizedDescription
        alert.runModal()
    }
    func confirmReplacingCorner() -> Bool {
        let alert = NSAlert()
        alert.messageText = localizer("system.conflict")
        alert.informativeText = localizer("system.explanation")
        alert.addButton(withTitle: localizer("system.replace"))
        alert.addButton(withTitle: localizer("cancel"))
        return alert.runModal() == .alertFirstButtonReturn
    }
    func resolveInitialConflict() {
        if confirmReplacingCorner() {
            do { try nativeCorners.replace(configuration.selectedCorner); cornerConflict = false }
            catch { showError(error) }
        } else { configuration.enabled = false }
        persist()
    }
    func restoreSystemCorners() {
        let alert = NSAlert(); alert.messageText = localizer("system.restore")
        alert.informativeText = localizer("system.restoreExplanation")
        alert.addButton(withTitle: localizer("system.restore")); alert.addButton(withTitle: localizer("cancel"))
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        setEnabled(false)
        do { try nativeCorners.restore() }
        catch { showError(error) }
        cornerConflict = nativeCorners.hasConflict(configuration.selectedCorner)
        refresh()
    }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool { showSettings(); return true }
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        quitting = true; wantDim = false; recoveryRequested = true; reconcile(); return .terminateLater
    }
}
