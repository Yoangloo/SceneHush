import AppKit
import SwiftUI
import SceneHushCore

protocol OnboardingActions: SettingsActions {
    func startDemonstration(progress: @escaping (Double) -> Void, completion: @escaping (Result<Void, Error>) -> Void)
    func cancelDemonstration(completion: @escaping (Result<Void, Error>) -> Void)
    func finishOnboarding()
    func onboardingClosed()
}

enum OnboardingStage { case welcome, permissions, demonstration, complete, failed }

final class OnboardingModel: ObservableObject {
    unowned let actions: OnboardingActions
    @Published var stage: OnboardingStage = .welcome
    @Published var language: AppLanguage
    @Published var progress = 0.0
    @Published var error: String?
    @Published var cancelling = false
    private var cancelCompletions: [() -> Void] = []
    var localizer: Localizer { Localizer(language) }

    init(actions: OnboardingActions) { self.actions = actions; language = actions.configuration.language }
    func refresh() { language = actions.configuration.language }
    func start() {
        guard stage != .demonstration else { return }
        stage = .demonstration; progress = 0; error = nil
        actions.startDemonstration(progress: { [weak self] value in self?.progress = value }) { [weak self] result in
            guard let self, self.stage == .demonstration else { return }
            switch result {
            case .success: self.progress = 1; self.stage = .complete
            case .failure(let error): self.error = error.localizedDescription; self.stage = .failed
            }
        }
    }
    func cancel(completion: @escaping () -> Void = {}) {
        if cancelling { cancelCompletions.append(completion); return }
        guard stage == .demonstration else { completion(); return }
        cancelling = true; cancelCompletions.append(completion)
        actions.cancelDemonstration { [weak self] result in
            guard let self else { return }
            self.cancelling = false
            switch result {
            case .success: self.stage = .permissions
            case .failure(let error): self.error = error.localizedDescription; self.stage = .failed
            }
            let completions = self.cancelCompletions
            self.cancelCompletions.removeAll()
            completions.forEach { $0() }
        }
    }
}

private struct OnboardingView: View {
    @ObservedObject var model: OnboardingModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var l: Localizer { model.localizer }

    var body: some View {
        ZStack {
            SceneBackground()
            VStack(spacing: 0) {
                HStack(spacing: 6) {
                    ForEach(0..<3) { index in
                        Capsule().fill(step >= index ? ScenePalette.accent : Color.primary.opacity(0.08))
                            .frame(width: index == step ? 24 : 7, height: 5)
                    }
                }.padding(.top, 35).accessibilityHidden(true)
                Spacer(minLength: 24)
                content
                    .frame(maxWidth: 470)
                    .transition(reduceMotion ? .identity : .opacity)
                Spacer(minLength: 22)
                controls
                HStack {
                    if model.stage == .permissions {
                        Button(l("onboarding.back")) { model.stage = .welcome }
                    } else { Text("SceneHush").foregroundStyle(.tertiary) }
                    Spacer()
                    Picker(l("language.label"), selection: Binding(get: { model.language }, set: model.actions.setLanguage)) {
                        ForEach(AppLanguage.allCases, id: \.self) { value in Text(l.language(value)).tag(value) }
                    }
                    .labelsHidden().pickerStyle(.menu).tint(.primary).frame(width: 120)
                    .disabled(model.stage == .demonstration)
                }
                .font(.system(size: 11)).buttonStyle(.plain).foregroundStyle(.secondary)
                .padding(.top, 26).padding(.bottom, 28)
            }
            .padding(.horizontal, 40)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.22), value: model.stage)
        }
        .frame(width: 600, height: 650)
        .tint(ScenePalette.accent)
    }

    private var step: Int {
        switch model.stage { case .welcome: return 0; case .permissions: return 1; default: return 2 }
    }

    @ViewBuilder private var content: some View {
        switch model.stage {
        case .welcome:
            VStack(spacing: 24) {
                BrandHeader(subtitle: l("subtitle"))
                VStack(spacing: 13) {
                    Text(l("onboarding.welcome.title")).font(.system(size: 27, weight: .medium, design: .rounded))
                    Text(l("onboarding.welcome.body")).font(.system(size: 13)).foregroundStyle(.secondary)
                        .lineSpacing(5).fixedSize(horizontal: false, vertical: true)
                }.multilineTextAlignment(.center)
                Label(l("onboarding.native"), systemImage: "checkmark.seal")
                    .font(.system(size: 11, weight: .medium)).foregroundStyle(ScenePalette.accent)
                    .padding(.horizontal, 16).padding(.vertical, 9).scenePanel()
            }
        case .permissions:
            VStack(spacing: 22) {
                Image(systemName: "hand.raised.slash").font(.system(size: 36, weight: .ultraLight)).foregroundStyle(ScenePalette.accent)
                heading(l("onboarding.permissions.title"), l("onboarding.permissions.body"))
                VStack(spacing: 18) {
                    permission("display", l("onboarding.permission.display"), l("onboarding.permission.none"))
                    Divider()
                    permission("cursorarrow", l("onboarding.permission.corner"), l("onboarding.permission.none"))
                    Divider()
                    permission("power", l("login"), l("onboarding.permission.optional"))
                }.padding(20).scenePanel()
                Text(l("onboarding.demo.explanation")).font(.system(size: 12)).foregroundStyle(.secondary)
                    .lineSpacing(4).multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            }
        case .demonstration:
            VStack(spacing: 26) {
                DayNightOrb(progress: model.progress)
                heading(l("onboarding.demo.title"), l("onboarding.demo.body"))
                ProgressView(value: model.progress).frame(width: 260).accessibilityLabel(l("onboarding.demo.progress"))
                Text(l("onboarding.demo.progress")).font(.system(size: 11)).foregroundStyle(.secondary)
            }
        case .complete:
            VStack(spacing: 25) {
                DayNightOrb(progress: 1)
                heading(l("onboarding.complete.title"), l("onboarding.complete.body"))
                Label(l("onboarding.complete.restored"), systemImage: "checkmark.circle.fill")
                    .font(.system(size: 12, weight: .medium)).foregroundStyle(ScenePalette.accent)
                    .padding(.horizontal, 16).padding(.vertical, 10).scenePanel()
                Text(l("onboarding.complete.note")).font(.system(size: 11)).foregroundStyle(.secondary)
                    .lineSpacing(4).multilineTextAlignment(.center).fixedSize(horizontal: false, vertical: true)
            }
        case .failed:
            VStack(spacing: 20) {
                Image(systemName: "sun.max.trianglebadge.exclamationmark").font(.system(size: 36)).foregroundStyle(.orange)
                heading(l("onboarding.failed.title"), l("onboarding.failed.body"))
                if let error = model.error {
                    Text(error).font(.system(size: 11)).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center).textSelection(.enabled)
                }
            }
        }
    }

    @ViewBuilder private var controls: some View {
        VStack(spacing: 12) {
            switch model.stage {
            case .welcome:
                SceneButton(l("onboarding.continue"), symbol: "arrow.right", prominent: true) { model.stage = .permissions }
                    .accessibilityIdentifier("onboarding.continue")
            case .permissions:
                SceneButton(l("onboarding.demo.start"), symbol: "play.fill", prominent: true, action: model.start)
                    .accessibilityIdentifier("onboarding.start")
                Button(l("onboarding.skip"), action: model.actions.finishOnboarding)
                    .accessibilityIdentifier("onboarding.skip")
            case .demonstration:
                SceneButton(l("onboarding.demo.cancel"), symbol: "escape") { model.cancel() }
                    .accessibilityIdentifier("onboarding.cancel")
            case .complete:
                SceneButton(l("onboarding.finish"), symbol: "arrow.right", prominent: true, action: model.actions.finishOnboarding)
                    .accessibilityIdentifier("onboarding.finish")
            case .failed:
                SceneButton(l("onboarding.retry"), symbol: "arrow.clockwise", prominent: true, action: model.start)
                Button(l("onboarding.skip"), action: model.actions.finishOnboarding)
            }
        }.font(.system(size: 11)).buttonStyle(.plain).disabled(model.cancelling)
    }

    private func heading(_ title: String, _ detail: String) -> some View {
        VStack(spacing: 14) {
            Text(title).font(.system(size: 26, weight: .medium, design: .rounded))
            Text(detail).font(.system(size: 13)).foregroundStyle(.secondary).lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }.multilineTextAlignment(.center)
    }

    private func permission(_ symbol: String, _ title: String, _ detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol).font(.system(size: 16)).foregroundStyle(ScenePalette.accent).frame(width: 22)
            Text(title).font(.system(size: 12, weight: .medium))
            Spacer()
            Text(detail).font(.system(size: 11)).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
        }
    }
}

private struct DayNightOrb: View {
    let progress: Double
    var body: some View {
        ZStack {
            Circle().fill(LinearGradient(colors: [ScenePalette.dusk.opacity(0.2), ScenePalette.dawn.opacity(0.2)],
                                        startPoint: .leading, endPoint: .trailing))
                .frame(width: 150, height: 150)
            Circle().strokeBorder(.primary.opacity(0.05)).frame(width: 188, height: 188)
            HStack(spacing: 20) {
                Image(systemName: "moon.stars.fill").opacity(1 - progress * 0.7)
                Image(systemName: "sun.max.fill").foregroundStyle(ScenePalette.dawn).opacity(0.3 + progress * 0.7)
            }.font(.system(size: 28, weight: .light))
        }
        .frame(height: 188).accessibilityHidden(true)
    }
}

private final class OnboardingWindow: NSWindow {
    var escape: (() -> Void)?
    override func cancelOperation(_ sender: Any?) { escape?() }
}

final class OnboardingWindowController: NSWindowController, NSWindowDelegate {
    let model: OnboardingModel
    private var closingAfterRestore = false
    private var closeRequested = false
    private var finishing = false
    init(actions: OnboardingActions) {
        model = OnboardingModel(actions: actions)
        let window = OnboardingWindow(contentRect: NSRect(x: 0, y: 0, width: 600, height: 650),
                                      styleMask: [.titled, .closable, .fullSizeContentView], backing: .buffered, defer: false)
        window.title = "SceneHush"; window.titleVisibility = .hidden; window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        super.init(window: window)
        window.delegate = self
        let hostingView = NSHostingView(rootView: OnboardingView(model: model))
        hostingView.sizingOptions = []
        window.contentView = hostingView
        window.escape = { [weak self] in
            guard let self else { return }
            if self.model.stage == .demonstration { self.model.cancel() }
            else { self.window?.performClose(nil) }
        }
        window.center()
    }
    required init?(coder: NSCoder) { nil }
    func rebuild() { model.refresh() }
    func show() { showWindow(nil); NSApp.activate(ignoringOtherApps: true) }
    func finish() { finishing = true; close() }
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if model.stage == .demonstration && !closingAfterRestore {
            guard !closeRequested else { return false }
            closeRequested = true
            model.cancel { [weak self] in self?.closingAfterRestore = true; self?.window?.performClose(nil) }
            return false
        }
        return true
    }
    func windowWillClose(_ notification: Notification) {
        if !finishing { model.actions.onboardingClosed() }
    }
}
