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

    @Test func olderPartialConfigurationRetainsPreferencesAndNeedsOnboarding() throws {
        let old = try JSONDecoder().decode(Configuration.self, from: Data("{\"restoreOnExit\":false}".utf8))
        #expect(old.selectedCorner == .rightBottom)
        #expect(!old.restoreOnExit)
        #expect(old.enabled)
        #expect(old.language == .system)
        #expect(!old.onboardingCompleted)
    }

    @Test func removedDisplayMethodIsIgnoredWhenMigratingExistingConfiguration() throws {
        let legacy = Data("""
            {"selectedCorner":"rightTop","restoreOnExit":false,"enabled":false,
             "language":"ja","dimmingMethod":"betterDisplay"}
            """.utf8)
        let migrated = try JSONDecoder().decode(Configuration.self, from: legacy)
        #expect(migrated == Configuration(selectedCorner: .rightTop, restoreOnExit: false,
                                          enabled: false, language: .ja))
        let encoded = try JSONSerialization.jsonObject(with: JSONEncoder().encode(migrated)) as? [String: Any]
        #expect(encoded?["dimmingMethod"] == nil)
        #expect(encoded?["onboardingCompleted"] as? Bool == false)
    }

    @Test func configurationRoundTripsCompletedOnboardingAndPrivatePreferences() throws {
        let configuration = Configuration(selectedCorner: .leftTop, restoreOnExit: false,
                                          enabled: false, language: .ja, onboardingCompleted: true)
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

    @Test func legacyRecoveryDataIsRetainedAndBlocksANewSession() throws {
        let data = Data("previous display recovery data".utf8)
        try paths.writePrivate(data, to: paths.legacySnapshotURL)
        let subject = DisplayDimmingController(paths: paths)
        #expect(subject.hasLegacySnapshot)
        #expect(!subject.hasPendingSnapshot)
        #expect(throws: NativeGammaError.legacyRestorationRequired) { try subject.dim() }
        try subject.restore()
        #expect(try Data(contentsOf: paths.legacySnapshotURL) == data)
        #expect(!FileManager.default.fileExists(atPath: paths.nativeSnapshotURL.path))
    }

    @Test func localRunnerDrainsOutputLargerThanPipeCapacity() throws {
        let expected = String(repeating: "x", count: 100_000)
        let output = try ProcessCommandRunner().run(executableURL: URL(fileURLWithPath: "/usr/bin/printf"),
                                                    arguments: ["%s", expected], timeout: 2)
        #expect(output == expected)
    }

    @Test func localRunnerReportsTimeoutInsteadOfWaitingForSleepingCommand() {
        #expect(throws: LocalCommandError.timeout) {
            try ProcessCommandRunner().run(executableURL: URL(fileURLWithPath: "/bin/sleep"),
                                           arguments: ["2"], timeout: 0.05)
        }
    }

    @Test func localRunnerReportsNonzeroExitAsCommandFailure() {
        #expect(throws: LocalCommandError.failed(operation: "false")) {
            try ProcessCommandRunner().run(executableURL: URL(fileURLWithPath: "/usr/bin/false"),
                                           arguments: [], timeout: 2)
        }
    }
}
