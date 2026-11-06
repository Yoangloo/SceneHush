import AppKit
import SwiftUI
import SceneHushCore

protocol SettingsActions: AnyObject {
    var configuration: Configuration { get }
    var localizer: Localizer { get }
    var loginEnabled: Bool { get }
    var lastIssue: String? { get }
    func setCorner(_ corner: Corner)
    func setLanguage(_ language: AppLanguage)
    func setRestoreOnExit(_ value: Bool)
    func setEnabled(_ value: Bool)
    func setLoginEnabled(_ value: Bool)
    func restoreNow()
    func restoreSystemCorners()
    func showOnboarding()
}

final class SettingsModel: ObservableObject {
    unowned let actions: SettingsActions
    @Published var configuration: Configuration
    @Published var loginEnabled: Bool
    @Published var issue: String?
    var localizer: Localizer { Localizer(configuration.language) }
    init(_ actions: SettingsActions) {
        self.actions = actions
        configuration = actions.configuration; loginEnabled = actions.loginEnabled; issue = actions.lastIssue
    }
    func refresh() {
        configuration = actions.configuration; loginEnabled = actions.loginEnabled; issue = actions.lastIssue
    }
}

private struct SettingsView: View {
    @ObservedObject var model: SettingsModel
    private var l: Localizer { model.localizer }
    var body: some View {
        ZStack {
            SceneBackground()
            ScrollView {
                VStack(spacing: 22) {
                    BrandHeader(subtitle: l("subtitle")).padding(.top, 22)
                    VStack(spacing: 0) {
                        settingRow(l("enabled"), detail: l("enabled.detail")) {
                            Toggle(l("enabled"), isOn: Binding(get: { model.configuration.enabled }, set: model.actions.setEnabled))
                                .labelsHidden().toggleStyle(.switch).accessibilityIdentifier("settings.enabled")
                        }
                        rowDivider
                        settingRow(l("corner.label"), detail: l("corner.detail")) {
                            CornerSelector(selected: model.configuration.selectedCorner, localizer: l, choose: model.actions.setCorner)
                        }
                        rowDivider
                        settingRow(l("restore.label")) {
                            Picker(l("restore.label"), selection: Binding(get: { model.configuration.restoreOnExit }, set: model.actions.setRestoreOnExit)) {
                                Text(l("restore.onExit")).tag(true)
                                Text(l("restore.onReentry")).tag(false)
                            }
                            .labelsHidden().pickerStyle(.menu).tint(.primary).frame(width: 256, alignment: .trailing).accessibilityIdentifier("settings.restore")
                        }
                    }.padding(.horizontal, 22).scenePanel()
                    VStack(spacing: 0) {
                        settingRow(l("login")) {
                            Toggle(l("login"), isOn: Binding(get: { model.loginEnabled }, set: model.actions.setLoginEnabled))
                                .labelsHidden().toggleStyle(.switch).accessibilityIdentifier("settings.login")
                        }
                        rowDivider
                        settingRow(l("language.label")) {
                            Picker(l("language.label"), selection: Binding(get: { model.configuration.language }, set: model.actions.setLanguage)) {
                                ForEach(AppLanguage.allCases, id: \.self) { language in Text(l.language(language)).tag(language) }
                            }
                            .labelsHidden().pickerStyle(.menu).tint(.primary).frame(width: 256, alignment: .trailing).accessibilityIdentifier("settings.language")
                        }
                    }.padding(.horizontal, 22).scenePanel()
                    HStack(spacing: 12) {
                        SceneButton(l("onboarding.replay"), symbol: "play.circle", prominent: true, fillsWidth: true, action: model.actions.showOnboarding)
                            .accessibilityIdentifier("settings.replay")
                        SceneButton(l("restore.now"), symbol: "sun.max", prominent: true, fillsWidth: true, action: model.actions.restoreNow)
                            .accessibilityIdentifier("settings.restoreNow")
                    }
                    if let issue = model.issue {
                        Label(issue, systemImage: "exclamationmark.triangle").font(.system(size: 12)).foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(14).scenePanel().accessibilityIdentifier("settings.error")
                    }
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "lock.open").font(.system(size: 14))
                        Text(l("risk.short")).font(.system(size: 11.5)).lineSpacing(3)
                    }
                    .foregroundStyle(.secondary).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 5)
                    VStack(spacing: 14) {
                        HStack {
                            Button(l("system.restore"), action: model.actions.restoreSystemCorners)
                            Spacer()
                            Text("SceneHush \(appVersion)").foregroundStyle(.tertiary)
                        }
                        .font(.system(size: 11)).buttonStyle(.plain).foregroundStyle(.secondary)
                        Divider().opacity(0.5)
                        Link(destination: URL(string: "https://github.com/Yoangloo/SceneHush")!) {
                            VStack(spacing: 6) {
                                Label(l("footer.github.support"), systemImage: "star")
                                    .font(.system(size: 12, weight: .medium)).foregroundStyle(.primary)
                                Text("github.com/Yoangloo/SceneHush")
                                    .font(.system(size: 11)).foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 6).frame(maxWidth: .infinity).contentShape(Rectangle())
                        }
                        .buttonStyle(.plain).accessibilityLabel(l("footer.github.open"))
                        .accessibilityIdentifier("settings.github")
                    }.padding(.bottom, 20)
                }.padding(.horizontal, 32).frame(maxWidth: 620).frame(maxWidth: .infinity)
            }
        }.tint(ScenePalette.accent)
    }
    private var appVersion: String { Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.2.1" }
    private var rowDivider: some View { Divider().opacity(0.5) }
    private func settingRow<Control: View>(_ title: String, detail: String? = nil, @ViewBuilder control: () -> Control) -> some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.system(size: 13, weight: .medium))
                if let detail { Text(detail).font(.system(size: 10.5)).foregroundStyle(.secondary) }
            }.frame(width: 154, alignment: .leading)
            Spacer(minLength: 0)
            control()
        }.padding(.vertical, 16).frame(minHeight: 54)
    }
}

private struct CornerSelector: View {
    let selected: Corner
    let localizer: Localizer
    let choose: (Corner) -> Void
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12).fill(ScenePalette.accent.opacity(0.045))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(.primary.opacity(0.1)))
            Image(systemName: "display").font(.system(size: 25, weight: .ultraLight)).foregroundStyle(.tertiary)
            VStack {
                HStack { corner(.leftTop, "arrow.up.left"); Spacer(); corner(.rightTop, "arrow.up.right") }
                Spacer(minLength: 6)
                HStack { corner(.leftBottom, "arrow.down.left"); Spacer(); corner(.rightBottom, "arrow.down.right") }
            }.padding(6)
        }.frame(width: 256, height: 76)
    }
    private func corner(_ value: Corner, _ symbol: String) -> some View {
        Button { choose(value) } label: {
            Image(systemName: symbol).font(.system(size: 11, weight: .semibold))
                .foregroundStyle(selected == value ? Color.white : Color.primary.opacity(0.45))
                .frame(width: 36, height: 25)
                .background(selected == value ? ScenePalette.accent : Color.primary.opacity(0.04), in: Capsule())
        }
        .buttonStyle(.plain).help(localizer.corner(value)).accessibilityLabel(localizer.corner(value))
        .accessibilityValue(selected == value ? localizer("selected") : "").accessibilityIdentifier("corner.\(value.rawValue)")
    }
}

final class SettingsWindowController: NSWindowController {
    private let model: SettingsModel
    init(actions: SettingsActions) {
        model = SettingsModel(actions)
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 620, height: 840),
                              styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView], backing: .buffered, defer: false)
        window.title = "SceneHush"; window.titleVisibility = .hidden; window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false; window.contentMinSize = NSSize(width: 560, height: 700)
        super.init(window: window)
        window.contentView = NSHostingView(rootView: SettingsView(model: model))
        window.center()
    }
    required init?(coder: NSCoder) { nil }
    func rebuild() { model.refresh() }
    func show() { showWindow(nil); NSApp.activate(ignoringOtherApps: true) }
}
