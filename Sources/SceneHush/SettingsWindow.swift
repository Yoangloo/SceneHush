import AppKit
import SceneHushCore

protocol SettingsActions: AnyObject {
    var configuration: Configuration { get }
    var localizer: Localizer { get }
    var backendAvailable: Bool { get }
    var loginEnabled: Bool { get }
    var lastIssue: String? { get }
    func setCorner(_ corner: Corner)
    func setLanguage(_ language: AppLanguage)
    func setDimmingMethod(_ method: DimmingMethod)
    func setRestoreOnExit(_ value: Bool)
    func setEnabled(_ value: Bool)
    func setLoginEnabled(_ value: Bool)
    func restoreNow()
    func restoreSystemCorners()
}

private final class SettingsContentView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        NSColor.windowBackgroundColor.setFill()
        dirtyRect.fill()
    }
}

final class SettingsWindowController: NSWindowController {
    unowned let actions: SettingsActions

    init(actions: SettingsActions) {
        self.actions = actions
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 600, height: 700),
                              styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
        window.title = "SceneHush"
        window.isReleasedWhenClosed = false
        super.init(window: window)
        window.center()
        rebuild()
    }

    required init?(coder: NSCoder) { nil }

    private func label(_ text: String, size: CGFloat = 13, color: NSColor = .labelColor) -> NSTextField {
        let view = NSTextField(wrappingLabelWithString: text)
        view.font = .systemFont(ofSize: size)
        view.textColor = color
        view.maximumNumberOfLines = 0
        return view
    }

    private func row(_ title: String, _ control: NSView) -> NSStackView {
        let text = label(title)
        text.widthAnchor.constraint(equalToConstant: 180).isActive = true
        let row = NSStackView(views: [text, control])
        row.orientation = .horizontal
        row.spacing = 20
        row.alignment = .centerY
        return row
    }

    func rebuild() {
        let l = actions.localizer
        let content = SettingsContentView()
        window?.contentView = content
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 30),
            stack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -30),
            stack.topAnchor.constraint(equalTo: content.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: content.bottomAnchor, constant: -20)
        ])
        let title = label("SceneHush", size: 30)
        title.font = .systemFont(ofSize: 30, weight: .semibold)
        stack.addArrangedSubview(title)
        let subtitle = label(l("subtitle"), size: 14, color: .secondaryLabelColor)
        stack.addArrangedSubview(subtitle)
        subtitle.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true

        let readyKey = actions.configuration.dimmingMethod == .native ? "backend.nativeReady" : "backend.ready"
        let status = label(actions.backendAvailable ? l(readyKey) : l("backend.missing"),
                           color: actions.backendAvailable ? .systemGreen : .systemOrange)
        stack.addArrangedSubview(status)
        status.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        let enable = NSButton(checkboxWithTitle: l("enabled"), target: self, action: #selector(enabledChanged))
        enable.state = actions.configuration.enabled ? .on : .off
        stack.addArrangedSubview(enable)

        let methods = NSPopUpButton()
        methods.addItems(withTitles: DimmingMethod.allCases.map { l("method." + $0.rawValue) })
        methods.selectItem(at: DimmingMethod.allCases.firstIndex(of: actions.configuration.dimmingMethod) ?? 0)
        methods.target = self
        methods.action = #selector(methodChanged)
        stack.addArrangedSubview(row(l("method.label"), methods))
        if actions.configuration.dimmingMethod == .native {
            let explanation = label(l("native.explanation"), size: 12, color: .secondaryLabelColor)
            stack.addArrangedSubview(explanation)
            explanation.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        }

        let corners = NSPopUpButton()
        corners.addItems(withTitles: Corner.allCases.map(l.corner))
        corners.selectItem(at: Corner.allCases.firstIndex(of: actions.configuration.selectedCorner) ?? 3)
        corners.target = self
        corners.action = #selector(cornerChanged)
        stack.addArrangedSubview(row(l("corner.label"), corners))

        let restore = NSPopUpButton()
        restore.addItems(withTitles: [l("restore.onExit"), l("restore.onReentry")])
        restore.selectItem(at: actions.configuration.restoreOnExit ? 0 : 1)
        restore.target = self
        restore.action = #selector(restoreChanged)
        stack.addArrangedSubview(row(l("restore.label"), restore))

        let languages = NSPopUpButton()
        languages.addItems(withTitles: AppLanguage.allCases.map(l.language))
        languages.selectItem(at: AppLanguage.allCases.firstIndex(of: actions.configuration.language) ?? 0)
        languages.target = self
        languages.action = #selector(languageChanged)
        stack.addArrangedSubview(row(l("language.label"), languages))

        let login = NSButton(checkboxWithTitle: l("login"), target: self, action: #selector(loginChanged))
        login.state = actions.loginEnabled ? .on : .off
        stack.addArrangedSubview(login)

        let buttons = NSStackView(views: [NSButton(title: l("restore.now"), target: self, action: #selector(restoreNow))])
        if actions.configuration.dimmingMethod == .betterDisplay {
            buttons.addArrangedSubview(NSButton(title: l("backend.open"), target: self, action: #selector(openBetterDisplay)))
        }
        buttons.spacing = 10
        stack.addArrangedSubview(buttons)

        let purpose = label(l("purpose"), size: 12, color: .secondaryLabelColor)
        stack.addArrangedSubview(purpose)
        purpose.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        let risk = label(l("risk"), size: 12, color: .systemOrange)
        stack.addArrangedSubview(risk)
        risk.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        if let issue = actions.lastIssue {
            let error = label(issue, size: 12, color: .systemRed)
            stack.addArrangedSubview(error)
            error.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        }
        let footer = NSStackView(views: [
            NSButton(title: l("system.restore"), target: self, action: #selector(restoreSystem)),
            NSButton(title: "GitHub", target: self, action: #selector(openProject))
        ])
        footer.spacing = 12
        stack.addArrangedSubview(footer)
        content.layoutSubtreeIfNeeded()
    }

    func show() { showWindow(nil); NSApp.activate(ignoringOtherApps: true) }
    @objc private func enabledChanged(_ sender: NSButton) { actions.setEnabled(sender.state == .on) }
    @objc private func cornerChanged(_ sender: NSPopUpButton) { actions.setCorner(Corner.allCases[sender.indexOfSelectedItem]) }
    @objc private func restoreChanged(_ sender: NSPopUpButton) { actions.setRestoreOnExit(sender.indexOfSelectedItem == 0) }
    @objc private func languageChanged(_ sender: NSPopUpButton) { actions.setLanguage(AppLanguage.allCases[sender.indexOfSelectedItem]) }
    @objc private func methodChanged(_ sender: NSPopUpButton) { actions.setDimmingMethod(DimmingMethod.allCases[sender.indexOfSelectedItem]) }
    @objc private func loginChanged(_ sender: NSButton) { actions.setLoginEnabled(sender.state == .on) }
    @objc private func restoreNow() { actions.restoreNow() }
    @objc private func restoreSystem() { actions.restoreSystemCorners() }
    @objc private func openBetterDisplay() { NSWorkspace.shared.open(URL(string: "https://betterdisplay.pro")!) }
    @objc private func openProject() { NSWorkspace.shared.open(URL(string: "https://github.com/Yoangloo/SceneHush")!) }
}
