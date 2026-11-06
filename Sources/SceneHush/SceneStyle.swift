import AppKit
import SwiftUI

enum SceneAppInfo {
    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.2.5"
    }
}

enum ScenePalette {
    static let accent = Color(red: 0.28, green: 0.39, blue: 0.70)
    static let dawn = Color(red: 0.94, green: 0.73, blue: 0.43)
    static let dusk = Color(red: 0.39, green: 0.47, blue: 0.72)
}

struct SceneBackground: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
            LinearGradient(colors: [ScenePalette.dawn.opacity(scheme == .dark ? 0.06 : 0.11),
                                    .clear, ScenePalette.dusk.opacity(scheme == .dark ? 0.12 : 0.08)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            Canvas { context, size in
                for y in stride(from: 0.0, to: size.height, by: 6) {
                    for x in stride(from: 0.0, to: size.width, by: 6) {
                        let offset = Int(y) % 12 == 0 ? 0.0 : 3.0
                        context.fill(Path(ellipseIn: CGRect(x: x + offset, y: y, width: 0.7, height: 0.7)),
                                     with: .color(.primary.opacity(scheme == .dark ? 0.035 : 0.05)))
                    }
                }
            }
            .allowsHitTesting(false).accessibilityHidden(true)
        }
        .ignoresSafeArea()
    }
}

struct BrandHeader: View {
    let subtitle: String
    var compact = false
    var body: some View {
        VStack(spacing: compact ? 10 : 12) {
            Image(nsImage: icon)
                .resizable().interpolation(.high)
                .frame(width: compact ? 70 : 84, height: compact ? 70 : 84)
                .accessibilityHidden(true)
            Text("SceneHush").font(.system(size: compact ? 30 : 34, weight: .semibold, design: .rounded))
                .tracking(-1)
            Text(subtitle).font(.system(size: 14)).foregroundStyle(.secondary)
                .multilineTextAlignment(.center).lineSpacing(4)
        }
        .frame(maxWidth: .infinity)
    }
    private var icon: NSImage {
        if let url = Bundle.main.url(forResource: "SceneHush-DayNight", withExtension: "icns"),
           let image = NSImage(contentsOf: url) { return image }
        return NSImage(named: NSImage.applicationIconName) ?? NSImage()
    }
}

private struct ScenePanel: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    func body(content: Content) -> some View {
        content
            .background(reduceTransparency ? AnyShapeStyle(Color(nsColor: .controlBackgroundColor))
                                          : AnyShapeStyle(.regularMaterial),
                        in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.white.opacity(0.35), lineWidth: 0.7))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.primary.opacity(0.035), lineWidth: 0.5))
    }
}

extension View {
    func scenePanel() -> some View { modifier(ScenePanel()) }
}

struct SceneButton: View {
    let title: String
    var symbol: String?
    var prominent = false
    var fillsWidth = false
    let action: () -> Void
    init(_ title: String, symbol: String? = nil, prominent: Bool = false, fillsWidth: Bool = false, action: @escaping () -> Void) {
        self.title = title; self.symbol = symbol; self.prominent = prominent; self.fillsWidth = fillsWidth; self.action = action
    }
    private var button: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                if let symbol { Image(systemName: symbol) }
                Text(title)
            }
            .font(.system(size: 12, weight: .semibold))
            .lineLimit(1)
            .padding(.horizontal, 12).frame(maxWidth: fillsWidth ? .infinity : nil, minHeight: 28)
        }
        .controlSize(.large)
    }
    @ViewBuilder private var shapedButton: some View {
        if #available(macOS 14.0, *) { button.buttonBorderShape(.capsule) }
        else { button }
    }
    @ViewBuilder var body: some View {
        if #available(macOS 26.0, *) {
            if prominent { shapedButton.buttonStyle(.glassProminent) }
            else { shapedButton.foregroundStyle(.primary).buttonStyle(.glass) }
        } else {
            if prominent { shapedButton.buttonStyle(.borderedProminent) }
            else { shapedButton.foregroundStyle(.primary).buttonStyle(.bordered) }
        }
    }
}
