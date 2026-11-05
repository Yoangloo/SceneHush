import Foundation
import Testing
@testable import SceneHushCore

@Suite final class SceneHushCoreTests {
    private let directory: URL
    private let paths: RuntimePaths

    init() {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("SceneHush-tests-\(UUID().uuidString)", isDirectory: true)
        paths = RuntimePaths(supportDirectory: directory)
    }

    deinit { try? FileManager.default.removeItem(at: directory) }

    private func controller(_ runner: FakeRunner) -> BrightnessController {
        BrightnessController(paths: paths, executableURL: URL(fileURLWithPath: "/usr/bin/true"),
                             runner: runner)
    }

    @Test func fourCornersUseFullScreenCoordinatesWithNegativeOrigin() {
        let frame = CGRect(x: -455, y: 956, width: 1920, height: 1080)
        let points: [Corner: CGPoint] = [
            .leftTop: CGPoint(x: -454, y: 2035),
            .rightTop: CGPoint(x: 1464, y: 2035),
            .leftBottom: CGPoint(x: -454, y: 957),
            .rightBottom: CGPoint(x: 1464, y: 957)
        ]
        for corner in Corner.allCases {
            for (candidate, point) in points {
                #expect(corner.contains(point: point, in: frame) == (candidate == corner))
            }
            #expect(!corner.contains(point: CGPoint(x: 0, y: 1500), in: frame))
            #expect(!corner.contains(point: CGPoint(x: 1464, y: 955), in: frame))
        }
        #expect(!Corner.rightBottom.contains(point: CGPoint(x: 1466, y: 957), in: frame))
        #expect(!Corner.rightBottom.contains(point: points[.rightBottom]!, in: frame, tolerance: 0))
    }

    @Test func configurationDecodesOldPartialFileAndRoundTripsNewSettings() throws {
        let old = try JSONDecoder().decode(Configuration.self, from: Data("{\"restoreOnExit\":false}".utf8))
        #expect(old.selectedCorner == .rightBottom)
        #expect(!old.restoreOnExit)
        #expect(old.enabled)
        #expect(old.language == .system)

        let configuration = Configuration(selectedCorner: .leftTop, restoreOnExit: false,
                                          enabled: false, language: .ja)
        let store = ConfigurationStore(paths: paths)
        #expect(try store.load() == Configuration())
        try store.save(configuration)
        #expect(try store.load() == configuration)
        let permissions = try FileManager.default.attributesOfItem(atPath: paths.configURL.path)[.posixPermissions] as? Int
        #expect(permissions == 0o600)
    }

    @Test func malformedConfigurationIsNotSilentlyReplaced() throws {
        try paths.writePrivate(Data("invalid-json".utf8), to: paths.configURL)
        #expect(throws: DecodingError.self) { try ConfigurationStore(paths: paths).load() }
        #expect(try String(contentsOf: paths.configURL, encoding: .utf8) == "invalid-json")
    }

    @Test func dimTargetsConnectedDisplaysAndRestoreAppliesAutoBrightnessFirst() throws {
        let fake = FakeRunner(displays: [
            FakeDisplay(uuid: "A", brightness: 0.125, automatic: "on"),
            FakeDisplay(uuid: "B", brightness: 0.29),
            FakeDisplay(uuid: "C", brightness: 0.9, connected: false)
        ])
        let subject = controller(fake)
        try subject.dim()
        #expect(fake.display("A").brightness == 0)
        #expect(fake.display("B").brightness == 0)
        #expect(fake.display("C").brightness == 0.9)
        #expect(fake.display("A").automatic == "off")
        #expect(subject.hasPendingSnapshot)

        fake.commands.removeAll()
        try subject.restore()
        #expect(fake.display("A").brightness == 0.125)
        #expect(fake.display("B").brightness == 0.29)
        #expect(fake.display("A").automatic == "on")
        let autoIndex = try #require(fake.commands.firstIndex(of: ["set", "-UUID=A", "-autoBrightness=on"]))
        let brightnessIndex = try #require(fake.commands.firstIndex(of: ["set", "-UUID=A", "-brightness=0.125"]))
        #expect(autoIndex < brightnessIndex)
        #expect(!subject.hasPendingSnapshot)
    }

    @Test func disconnectedSnapshotSurvivesNewTriggerAndRestoresAfterReconnect() throws {
        let fake = FakeRunner(displays: [FakeDisplay(uuid: "A", brightness: 0.4),
                                         FakeDisplay(uuid: "B", brightness: 0.7)])
        let subject = controller(fake)
        try subject.dim()
        fake.update("B") { $0.connected = false }
        #expect(throws: BrightnessError.restorePending(count: 1)) { try subject.restore() }
        #expect(fake.display("A").brightness == 0.4)
        var snapshot = try JSONDecoder().decode([DisplayState].self, from: Data(contentsOf: paths.snapshotURL))
        #expect(snapshot.map(\.uuid) == ["B"])
        #expect(snapshot.first?.brightness == 0.7)

        try subject.dim()
        snapshot = try JSONDecoder().decode([DisplayState].self, from: Data(contentsOf: paths.snapshotURL))
        #expect(Set(snapshot.map(\.uuid)) == ["A", "B"])
        #expect(snapshot.first(where: { $0.uuid == "B" })?.brightness == 0.7)
        fake.update("B") { $0.connected = true }
        try subject.restore()
        #expect(fake.display("A").brightness == 0.4)
        #expect(fake.display("B").brightness == 0.7)
        #expect(!subject.hasPendingSnapshot)
    }

    @Test func existingOriginalValueWinsOverAlreadyDimmedCapture() throws {
        let fake = FakeRunner(displays: [FakeDisplay(uuid: "A", brightness: 0)])
        let subject = controller(fake)
        try subject.save([DisplayState(uuid: "A", name: "A", brightness: 0.6)])
        try subject.dim()
        try subject.restore()
        #expect(fake.display("A").brightness == 0.6)
    }

    @Test func commandFailureRollsBackDisplaysAlreadyDimmed() throws {
        let fake = FakeRunner(displays: [FakeDisplay(uuid: "A", brightness: 0.4, automatic: "on"),
                                         FakeDisplay(uuid: "B", brightness: 0.7)])
        fake.failNextZeroForUUID = "B"
        let subject = controller(fake)
        #expect(throws: BrightnessError.commandFailed(operation: "set")) { try subject.dim() }
        #expect(fake.display("A").brightness == 0.4)
        #expect(fake.display("A").automatic == "on")
        #expect(fake.display("B").brightness == 0.7)
        #expect(!subject.hasPendingSnapshot)
    }

    @Test func badCaptureLeavesDisplaysAndExistingSnapshotUntouched() throws {
        let fake = FakeRunner(displays: [FakeDisplay(uuid: "A", brightness: 0.4)])
        let subject = controller(fake)
        try subject.save([DisplayState(uuid: "B", name: "B", brightness: 0.7)])
        let original = try Data(contentsOf: paths.snapshotURL)
        fake.invalidBrightness = true
        #expect(throws: BrightnessError.invalidBrightness) { try subject.dim() }
        #expect(fake.display("A").brightness == 0.4)
        #expect(try Data(contentsOf: paths.snapshotURL) == original)
        #expect(!fake.commands.contains(where: { $0.first == "set" }))
    }

    @Test func processRunnerDrainsOutputAndReportsTimeout() throws {
        let runner = ProcessCommandRunner()
        let expected = String(repeating: "x", count: 100_000)
        let output = try runner.run(executableURL: URL(fileURLWithPath: "/usr/bin/printf"),
                                    arguments: ["%s", expected], timeout: 2)
        #expect(output == expected)
        #expect(throws: BrightnessError.commandTimedOut) {
            try runner.run(executableURL: URL(fileURLWithPath: "/bin/sleep"),
                           arguments: ["2"], timeout: 0.05)
        }
    }
}

private struct FakeDisplay {
    let uuid: String
    var brightness: Double
    var automatic = "off"
    var connected = true
}

private final class FakeRunner: CommandRunning {
    var displays: [FakeDisplay]
    var commands: [[String]] = []
    var failNextZeroForUUID: String?
    var invalidBrightness = false

    init(displays: [FakeDisplay]) { self.displays = displays }

    func display(_ uuid: String) -> FakeDisplay { displays.first { $0.uuid == uuid }! }

    func update(_ uuid: String, _ body: (inout FakeDisplay) -> Void) {
        body(&displays[displays.firstIndex { $0.uuid == uuid }!])
    }

    func run(executableURL: URL, arguments: [String], timeout: TimeInterval) throws -> String {
        commands.append(arguments)
        if arguments == ["get", "-type=Display", "-identifiers"] {
            let objects = try displays.map {
                try String(data: JSONSerialization.data(withJSONObject: ["UUID": $0.uuid, "name": $0.uuid]),
                           encoding: .utf8)!
            }
            return objects.joined(separator: ",")
        }
        guard arguments.count == 3, arguments[1].hasPrefix("-UUID="),
              let index = displays.firstIndex(where: { "-UUID=\($0.uuid)" == arguments[1] }) else {
            throw BrightnessError.commandFailed(operation: arguments.first ?? "unknown")
        }
        let feature = arguments[2]
        if arguments[0] == "get" {
            switch feature {
            case "-connected": return displays[index].connected ? "on" : "off"
            case "-brightness": return invalidBrightness ? "nan" : String(displays[index].brightness)
            case "-autoBrightness": return displays[index].automatic
            default: throw BrightnessError.commandFailed(operation: "get")
            }
        }
        if feature == "-brightness=0", failNextZeroForUUID == displays[index].uuid {
            failNextZeroForUUID = nil
            throw BrightnessError.commandFailed(operation: "set")
        }
        if feature.hasPrefix("-brightness="), let value = Double(feature.dropFirst("-brightness=".count)) {
            displays[index].brightness = value
        } else if feature.hasPrefix("-autoBrightness=") {
            displays[index].automatic = String(feature.dropFirst("-autoBrightness=".count))
            if displays[index].automatic == "on" { displays[index].brightness = 0.9 }
        } else {
            throw BrightnessError.commandFailed(operation: "set")
        }
        return ""
    }
}
