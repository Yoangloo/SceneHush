import Foundation
import SceneHushCore

struct Localizer {
    let code: String
    private let strings: [String: String]

    static var resourceBundle: Bundle {
        if let url = Bundle.main.url(forResource: "SceneHush_SceneHush", withExtension: "bundle"),
           let bundle = Bundle(url: url) { return bundle }
        return Bundle.module
    }

    init(_ language: AppLanguage) {
        switch language {
        case .en: code = "en"
        case .zhHans: code = "zh-Hans"
        case .ja: code = "ja"
        case .system:
            let preferred = Locale.preferredLanguages.first ?? "en"
            code = preferred.hasPrefix("zh") ? "zh-Hans" : preferred.hasPrefix("ja") ? "ja" : "en"
        }
        strings = Self.load(code)
    }

    static func load(_ code: String) -> [String: String] {
        guard let url = resourceBundle.url(forResource: code, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let dictionary = try? JSONDecoder().decode([String: String].self, from: data) else { return [:] }
        return dictionary
    }

    func callAsFunction(_ key: String) -> String { strings[key] ?? Self.load("en")[key] ?? key }
    func corner(_ corner: Corner) -> String { self("corner.\(corner.rawValue)") }
    func language(_ language: AppLanguage) -> String {
        switch language {
        case .system: return self("language.system")
        case .en: return "English"
        case .zhHans: return "简体中文"
        case .ja: return "日本語"
        }
    }
}
