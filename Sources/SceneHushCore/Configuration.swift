import Foundation

public enum Corner: String, Codable, CaseIterable {
    case leftTop, rightTop, leftBottom, rightBottom

    public func contains(point: CGPoint, in frame: CGRect, tolerance: CGFloat = 3) -> Bool {
        guard tolerance > 0, frame.width > 0, frame.height > 0,
              point.x >= frame.minX, point.x <= frame.maxX,
              point.y >= frame.minY, point.y <= frame.maxY else { return false }
        let horizontal = (self == .leftTop || self == .leftBottom)
            ? point.x <= frame.minX + tolerance : point.x >= frame.maxX - tolerance
        let vertical = (self == .leftTop || self == .rightTop)
            ? point.y >= frame.maxY - tolerance : point.y <= frame.minY + tolerance
        return horizontal && vertical
    }
}

public enum AppLanguage: String, Codable, CaseIterable {
    case system, en, zhHans, ja

    public func resourceCode(preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        switch self {
        case .en: return "en"
        case .zhHans: return "zh-Hans"
        case .ja: return "ja"
        case .system:
            for preference in preferredLanguages {
                let base = preference.replacingOccurrences(of: "_", with: "-").lowercased().split(separator: "-").first
                switch base {
                case "en": return "en"
                case "zh": return "zh-Hans"
                case "ja": return "ja"
                default: continue
                }
            }
            return "en"
        }
    }
}

public struct Configuration: Codable, Equatable {
    public var selectedCorner: Corner
    public var restoreOnExit: Bool
    public var enabled: Bool
    public var language: AppLanguage
    public var onboardingCompleted: Bool
    public var completedOnboardingInstallationID: String?

    public init(selectedCorner: Corner = .rightBottom, restoreOnExit: Bool = true,
                enabled: Bool = true, language: AppLanguage = .system,
                onboardingCompleted: Bool = false,
                completedOnboardingInstallationID: String? = nil) {
        self.selectedCorner = selectedCorner
        self.restoreOnExit = restoreOnExit
        self.enabled = enabled
        self.language = language
        self.onboardingCompleted = onboardingCompleted
        self.completedOnboardingInstallationID = completedOnboardingInstallationID
    }

    private enum CodingKeys: String, CodingKey {
        case selectedCorner, restoreOnExit, enabled, language, onboardingCompleted, completedOnboardingInstallationID
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        selectedCorner = try values.decodeIfPresent(Corner.self, forKey: .selectedCorner) ?? .rightBottom
        restoreOnExit = try values.decodeIfPresent(Bool.self, forKey: .restoreOnExit) ?? true
        enabled = try values.decodeIfPresent(Bool.self, forKey: .enabled) ?? true
        language = try values.decodeIfPresent(AppLanguage.self, forKey: .language) ?? .system
        onboardingCompleted = try values.decodeIfPresent(Bool.self, forKey: .onboardingCompleted) ?? false
        completedOnboardingInstallationID = try values.decodeIfPresent(String.self, forKey: .completedOnboardingInstallationID)
    }

    public func needsOnboarding(for installation: InstallationIdentity?) -> Bool {
        guard onboardingCompleted, let installation else { return true }
        return completedOnboardingInstallationID != installation.rawValue
    }

    public mutating func completeOnboarding(for installation: InstallationIdentity?) {
        onboardingCompleted = true
        if let installation { completedOnboardingInstallationID = installation.rawValue }
    }
}

public struct RuntimePaths {
    public let supportDirectory: URL
    public var configURL: URL { supportDirectory.appendingPathComponent("config.json") }
    public var legacySnapshotURL: URL { supportDirectory.appendingPathComponent("brightness-snapshot.json") }
    public var nativeSnapshotURL: URL { supportDirectory.appendingPathComponent("native-display-snapshot.json") }

    public init(supportDirectory: URL = FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Application Support/SceneHush", isDirectory: true)) {
        self.supportDirectory = supportDirectory
    }

    public func ensureDirectory() throws {
        try FileManager.default.createDirectory(at: supportDirectory, withIntermediateDirectories: true,
                                               attributes: [.posixPermissions: 0o700])
        try FileManager.default.setAttributes([.posixPermissions: 0o700],
                                             ofItemAtPath: supportDirectory.path)
    }

    public func writePrivate(_ data: Data, to url: URL) throws {
        try ensureDirectory()
        try data.write(to: url, options: .atomic)
        try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: url.path)
    }
}

public struct ConfigurationStore {
    public let paths: RuntimePaths

    public init(paths: RuntimePaths = RuntimePaths()) { self.paths = paths }

    public func load() throws -> Configuration {
        guard FileManager.default.fileExists(atPath: paths.configURL.path) else { return Configuration() }
        return try JSONDecoder().decode(Configuration.self, from: Data(contentsOf: paths.configURL))
    }

    public func save(_ configuration: Configuration) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try paths.writePrivate(encoder.encode(configuration), to: paths.configURL)
    }
}
