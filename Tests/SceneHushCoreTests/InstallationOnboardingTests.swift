import Darwin
import Foundation
import Testing
@testable import SceneHushCore

@Suite final class InstallationOnboardingTests {
    private let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("SceneHush-installation-tests-\(UUID().uuidString)", isDirectory: true)

    deinit { try? FileManager.default.removeItem(at: directory) }

    private func makeInstallation(_ name: String = "SceneHush.app") throws -> URL {
        let app = directory.appendingPathComponent(name, isDirectory: true)
        let executable = app.appendingPathComponent("Contents/MacOS/SceneHush")
        try FileManager.default.createDirectory(at: executable.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("temporary test executable".utf8).write(to: executable)
        return app
    }

    private func identity(_ app: URL, version: String = "1.2.5", build: String = "1.2.5") throws -> InstallationIdentity {
        try InstallationIdentity(bundleURL: app, executableURL: app.appendingPathComponent("Contents/MacOS/SceneHush"),
                                 version: version, buildVersion: build)
    }

    @Test func legacyCompletedFlagCannotSkipThisInstallAndKeepsPreferences() throws {
        let original = Data("""
            {"selectedCorner":"leftTop","restoreOnExit":false,"enabled":false,
             "language":"ja","onboardingCompleted":true}
            """.utf8)
        let migrated = try JSONDecoder().decode(Configuration.self, from: original)
        let installation = try identity(makeInstallation())
        #expect(migrated.onboardingCompleted)
        #expect(migrated.completedOnboardingInstallationID == nil)
        #expect(migrated.needsOnboarding(for: installation))
        #expect(migrated.selectedCorner == .leftTop)
        #expect(!migrated.restoreOnExit)
        #expect(!migrated.enabled)
        #expect(migrated.language == .ja)
    }

    @Test func completionSurvivesRelaunchWithoutRewritingTheAppOrPreferences() throws {
        let app = try makeInstallation()
        let first = try identity(app)
        var configuration = Configuration(selectedCorner: .rightTop, restoreOnExit: false, language: .zhHans)
        #expect(configuration.needsOnboarding(for: first))
        configuration.completeOnboarding(for: first)
        let paths = RuntimePaths(supportDirectory: directory.appendingPathComponent("preferences"))
        let store = ConfigurationStore(paths: paths)
        try store.save(configuration)
        let originalFile = try Data(contentsOf: paths.configURL)

        let relaunched = try store.load()
        let relaunchedIdentity = try identity(app)
        #expect(relaunchedIdentity == first)
        #expect(!relaunched.needsOnboarding(for: relaunchedIdentity))
        #expect(relaunched == configuration)
        #expect(try Data(contentsOf: paths.configURL) == originalFile)
        #expect(first.rawValue.count == 64)
    }

    @Test func sameVersionNewCopyNeedsOnboardingDespitePreviousCompletion() throws {
        let original = try makeInstallation()
        let originalIdentity = try identity(original)
        var configuration = Configuration(selectedCorner: .leftBottom, language: .ja)
        configuration.completeOnboarding(for: originalIdentity)
        let replacement = directory.appendingPathComponent("Reinstalled.app")
        try FileManager.default.copyItem(at: original, to: replacement)
        let replacementIdentity = try identity(replacement)
        #expect(replacementIdentity != originalIdentity)
        #expect(configuration.needsOnboarding(for: replacementIdentity))
        #expect(configuration.completedOnboardingInstallationID == originalIdentity.rawValue)
        #expect(configuration.selectedCorner == .leftBottom)
        #expect(configuration.language == .ja)

        configuration.completeOnboarding(for: replacementIdentity)
        #expect(!configuration.needsOnboarding(for: replacementIdentity))
    }

    @Test func replacingAtTheSamePathAndVersionNeedsOnboarding() throws {
        let installed = try makeInstallation()
        let first = try identity(installed)
        var configuration = Configuration()
        configuration.completeOnboarding(for: first)
        let backup = directory.appendingPathComponent("Previous.app")
        try FileManager.default.moveItem(at: installed, to: backup)
        try FileManager.default.copyItem(at: backup, to: installed)
        let replacement = try identity(installed)
        #expect(configuration.needsOnboarding(for: replacement))
        #expect(replacement != first)
    }

    @Test func inPlaceExecutableCopyIsDetectedEvenWhenMtimeIsPreserved() throws {
        let app = try makeInstallation()
        let executable = app.appendingPathComponent("Contents/MacOS/SceneHush")
        let before = try identity(app)
        let handle = try FileHandle(forWritingTo: executable)
        defer { try? handle.close() }
        var originalMetadata = stat()
        #expect(fstat(handle.fileDescriptor, &originalMetadata) == 0)
        let attributes = try FileManager.default.attributesOfItem(atPath: executable.path)
        let originalModificationDate = try #require(attributes[.modificationDate] as? Date)
        let originalBytes = try Data(contentsOf: executable)
        Thread.sleep(forTimeInterval: 0.01)
        try handle.seek(toOffset: 0)
        try handle.write(contentsOf: originalBytes)
        try FileManager.default.setAttributes([.modificationDate: originalModificationDate], ofItemAtPath: executable.path)
        var overwrittenMetadata = stat()
        #expect(fstat(handle.fileDescriptor, &overwrittenMetadata) == 0)
        #expect(originalMetadata.st_ino == overwrittenMetadata.st_ino)
        #expect(try Data(contentsOf: executable) == originalBytes)
        #expect(try identity(app) != before)
    }

    @Test func sameVolumeBundleRenameDoesNotCreateANewInstallation() throws {
        let original = try makeInstallation()
        let volumeUUID = try #require(original.resourceValues(forKeys: [.volumeUUIDStringKey]).volumeUUIDString)
        #expect(!volumeUUID.isEmpty)
        let before = try identity(original)
        let renamed = directory.appendingPathComponent("Renamed.app")
        try FileManager.default.moveItem(at: original, to: renamed)
        #expect(try renamed.resourceValues(forKeys: [.volumeUUIDStringKey]).volumeUUIDString == volumeUUID)
        #expect(try identity(renamed) == before)
    }

    @Test func versionOrBuildChangeRequiresIntroductionAgain() throws {
        let app = try makeInstallation()
        var configuration = Configuration()
        let before = try identity(app)
        configuration.completeOnboarding(for: before)
        let newVersion = try identity(app, version: "1.2.6")
        let newBuild = try identity(app, build: "1.2.5.1")
        #expect(configuration.needsOnboarding(for: newVersion))
        #expect(configuration.needsOnboarding(for: newBuild))
    }

    @Test func unreadableIdentityRequiresOnboardingWithoutErasingPreviousMarker() throws {
        let installation = try identity(makeInstallation())
        var configuration = Configuration(language: .ja)
        configuration.completeOnboarding(for: installation)
        let before = configuration
        #expect(configuration.needsOnboarding(for: nil))
        let missing = directory.appendingPathComponent("Missing.app")
        #expect(throws: CocoaError.self) { try identity(missing) }
        configuration.completeOnboarding(for: nil)
        #expect(configuration == before)
        #expect(configuration.needsOnboarding(for: nil))
    }

    @Test func matchingMarkerStillNeedsExplicitCompletion() throws {
        let installation = try identity(makeInstallation())
        let configuration = Configuration(onboardingCompleted: false,
                                          completedOnboardingInstallationID: installation.rawValue)
        #expect(configuration.needsOnboarding(for: installation))
    }
}
