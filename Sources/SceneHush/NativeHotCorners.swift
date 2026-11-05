import AppKit
import SceneHushCore

struct NativeCornerBackup: Codable {
    let action: Int?
    let modifier: Int?
}

final class NativeHotCorners {
    let paths: RuntimePaths
    let runner = ProcessCommandRunner()
    var backupURL: URL { paths.supportDirectory.appendingPathComponent("system-corners.json") }
    init(paths: RuntimePaths) { self.paths = paths }

    func prefix(_ corner: Corner) -> String {
        switch corner {
        case .leftTop: return "wvous-tl"
        case .rightTop: return "wvous-tr"
        case .leftBottom: return "wvous-bl"
        case .rightBottom: return "wvous-br"
        }
    }

    private func read(_ key: String) -> Int? {
        guard let output = try? runner.run(executableURL: URL(fileURLWithPath: "/usr/bin/defaults"),
                                          arguments: ["read", "com.apple.dock", key], timeout: 3) else { return nil }
        return Int(output.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    func hasConflict(_ corner: Corner) -> Bool { (read(prefix(corner) + "-corner") ?? 0) > 1 }

    func replace(_ corner: Corner) throws {
        var backup: [String: NativeCornerBackup] = [:]
        if FileManager.default.fileExists(atPath: backupURL.path) {
            backup = try JSONDecoder().decode([String: NativeCornerBackup].self, from: Data(contentsOf: backupURL))
        }
        let key = prefix(corner)
        if backup[corner.rawValue] == nil {
            backup[corner.rawValue] = NativeCornerBackup(action: read(key + "-corner"), modifier: read(key + "-modifier"))
            try paths.writePrivate(JSONEncoder().encode(backup), to: backupURL)
        }
        _ = try runner.run(executableURL: URL(fileURLWithPath: "/usr/bin/defaults"),
                           arguments: ["write", "com.apple.dock", key + "-corner", "-int", "0"], timeout: 3)
        restartDock()
    }

    func restore() throws {
        guard FileManager.default.fileExists(atPath: backupURL.path) else { return }
        let backup = try JSONDecoder().decode([String: NativeCornerBackup].self, from: Data(contentsOf: backupURL))
        for (cornerKey, value) in backup {
            guard let corner = Corner(rawValue: cornerKey) else { continue }
            for (suffix, previous) in [("-corner", value.action), ("-modifier", value.modifier)] {
                let key = prefix(corner) + suffix
                if let previous = previous {
                    _ = try runner.run(executableURL: URL(fileURLWithPath: "/usr/bin/defaults"),
                                       arguments: ["write", "com.apple.dock", key, "-int", String(previous)], timeout: 3)
                } else if read(key) != nil {
                    _ = try runner.run(executableURL: URL(fileURLWithPath: "/usr/bin/defaults"),
                                       arguments: ["delete", "com.apple.dock", key], timeout: 3)
                }
            }
        }
        try FileManager.default.removeItem(at: backupURL)
        restartDock()
    }

    private func restartDock() {
        _ = try? runner.run(executableURL: URL(fileURLWithPath: "/usr/bin/killall"),
                            arguments: ["Dock"], timeout: 3)
    }
}
