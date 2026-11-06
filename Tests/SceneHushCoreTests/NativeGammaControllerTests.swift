import Foundation
import Testing
@testable import SceneHushCore

@Suite final class NativeGammaControllerTests {
    private let directory: URL
    private let paths: RuntimePaths

    init() {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("SceneHush-native-tests-\(UUID().uuidString)", isDirectory: true)
        paths = RuntimePaths(supportDirectory: directory)
    }

    deinit { try? FileManager.default.removeItem(at: directory) }

    private func controller(_ driver: FakeGammaDriver) -> NativeGammaController {
        NativeGammaController(paths: paths, driver: driver)
    }

    private func save(_ states: [GammaDisplayState]) throws {
        try paths.writePrivate(JSONEncoder().encode(states), to: paths.nativeSnapshotURL)
    }

    private func snapshot() throws -> [GammaDisplayState] {
        try JSONDecoder().decode([GammaDisplayState].self, from: Data(contentsOf: paths.nativeSnapshotURL))
    }

    @Test func captureOnlyReadsConnectedDisplays() throws {
        let driver = FakeGammaDriver(displays: [
            FakeGammaDisplay(uuid: "A", displayID: 1, table: curve(0.4)),
            FakeGammaDisplay(uuid: "B", displayID: 2, table: curve(0.8)),
            FakeGammaDisplay(uuid: "C", displayID: 3, table: curve(0.9), connected: false)
        ])
        let subject = controller(driver)
        let states = try subject.capture()
        #expect(states.map(\.uuid) == ["A", "B"])
        #expect(states.map(\.table) == [curve(0.4), curve(0.8)])
        #expect(driver.writes.isEmpty)
        #expect(!subject.hasPendingSnapshot)
    }

    @Test func captureFailureLeavesScreensAndOriginalSnapshotUntouched() throws {
        let driver = FakeGammaDriver(displays: [
            FakeGammaDisplay(uuid: "A", displayID: 1, table: curve(0.4)),
            FakeGammaDisplay(uuid: "B", displayID: 2, table: curve(0.8))
        ])
        let subject = controller(driver)
        try save([GammaDisplayState(uuid: "A", name: "A", table: curve(0.6))])
        let original = try Data(contentsOf: paths.nativeSnapshotURL)
        driver.readFailureUUID = "B"
        #expect(throws: NativeGammaError.unsupportedDisplay) { try subject.dim() }
        #expect(driver.writes.isEmpty)
        #expect(driver.display("A").table == curve(0.4))
        #expect(driver.display("B").table == curve(0.8))
        #expect(try Data(contentsOf: paths.nativeSnapshotURL) == original)
    }

    @Test func snapshotIsPrivateAndCompleteBeforeFirstWriteAndSecondFailureRollsBack() throws {
        let driver = FakeGammaDriver(displays: [
            FakeGammaDisplay(uuid: "A", displayID: 1, table: curve(0.4)),
            FakeGammaDisplay(uuid: "B", displayID: 2, table: curve(0.8))
        ])
        let subject = controller(driver)
        driver.beforeWrite = { [paths] _, _ in
            #expect(FileManager.default.fileExists(atPath: paths.nativeSnapshotURL.path))
            let saved = try JSONDecoder().decode([GammaDisplayState].self, from: Data(contentsOf: paths.nativeSnapshotURL))
            #expect(saved.map(\.table) == [curve(0.4), curve(0.8)])
            let mode = try FileManager.default.attributesOfItem(atPath: paths.nativeSnapshotURL.path)[.posixPermissions] as? Int
            #expect(mode == 0o600)
        }
        driver.failNextBlackUUID = "B"
        #expect(throws: NativeGammaError.operationFailed(operation: "fake write", status: -1)) { try subject.dim() }
        #expect(driver.display("A").table == curve(0.4))
        #expect(driver.display("B").table == curve(0.8))
        #expect(driver.writes.contains { $0.uuid == "A" && $0.table.isBlack })
        #expect(driver.writes.contains { $0.uuid == "B" && $0.table == curve(0.8) })
        #expect(!subject.hasPendingSnapshot)
    }

    @Test func successfulWriteWithUnchangedReadbackIsRejectedAndRolledBack() throws {
        let driver = FakeGammaDriver(displays: [
            FakeGammaDisplay(uuid: "A", displayID: 1, table: curve(0.4)),
            FakeGammaDisplay(uuid: "B", displayID: 2, table: curve(0.8))
        ])
        let subject = controller(driver)
        driver.ignoreBlackUUID = "B"
        #expect(throws: NativeGammaError.verificationFailed) { try subject.dim() }
        #expect(driver.display("A").table == curve(0.4))
        #expect(driver.display("B").table == curve(0.8))
        #expect(!subject.hasPendingSnapshot)
    }

    @Test func disconnectedOriginalSurvivesAnotherDimAndRestoresUsingNewDisplayID() throws {
        let driver = FakeGammaDriver(displays: [
            FakeGammaDisplay(uuid: "A", displayID: 1, table: curve(0.4)),
            FakeGammaDisplay(uuid: "B", displayID: 2, table: curve(0.8))
        ])
        let subject = controller(driver)
        try subject.dim()
        try subject.verifyDark()
        driver.update("B") { $0.connected = false }
        #expect(throws: NativeGammaError.restorePending(count: 1)) { try subject.restore() }
        #expect(try snapshot().map(\.uuid) == ["B"])
        #expect(driver.display("A").table == curve(0.4))

        try subject.dim()
        let pending = try snapshot()
        #expect(Set(pending.map(\.uuid)) == ["A", "B"])
        #expect(pending.first(where: { $0.uuid == "B" })?.table == curve(0.8))
        driver.update("B") { $0.connected = true; $0.displayID = 99 }
        driver.writes.removeAll()
        try subject.restore()
        #expect(driver.writes.contains { $0.uuid == "B" && $0.displayID == 99 && $0.table == curve(0.8) })
        #expect(driver.display("A").table == curve(0.4))
        #expect(driver.display("B").table == curve(0.8))
        #expect(!subject.hasPendingSnapshot)
    }

    @Test func existingOriginalTableWinsOverAlreadyBlackCapture() throws {
        let driver = FakeGammaDriver(displays: [FakeGammaDisplay(uuid: "A", displayID: 1, table: curve(0))])
        let subject = controller(driver)
        let original = GammaDisplayState(uuid: "A", name: "A", table: curve(0.6))
        try save([original])
        try subject.dim()
        #expect(try snapshot() == [original])
        try subject.restore()
        try subject.verifyRestored([original])
        #expect(driver.display("A").table == curve(0.6))
    }

    @Test func gradualRestorationUsesPersistedOriginalsAndRetainsSnapshotUntilFinalRestore() throws {
        let original = GammaTable(red: [0.1, 0.4, 0.8], green: [0.2, 0.6, 1], blue: [0, 0.3, 0.6])
        let second = GammaTable(red: [0, 0.2, 0.6], green: [0, 0.4, 0.8], blue: [0.2, 0.6, 1])
        let driver = FakeGammaDriver(displays: [
            FakeGammaDisplay(uuid: "A", displayID: 1, table: original),
            FakeGammaDisplay(uuid: "B", displayID: 2, table: second)
        ])
        let subject = controller(driver)
        let before = try subject.capture()
        try subject.dim()
        let saved = try Data(contentsOf: paths.nativeSnapshotURL)
        try subject.setRestoreProgress(0)
        try subject.verifyDark()
        try subject.setRestoreProgress(0.5)
        #expect(driver.display("A").table == GammaTable(red: [0.05, 0.2, 0.4],
                                                        green: [0.1, 0.3, 0.5], blue: [0, 0.15, 0.3]))
        #expect(driver.display("B").table == GammaTable(red: [0, 0.1, 0.3],
                                                        green: [0, 0.2, 0.4], blue: [0.1, 0.3, 0.5]))
        try subject.setRestoreProgress(0.5)
        #expect(driver.display("A").table.red == [0.05, 0.2, 0.4])
        #expect(try Data(contentsOf: paths.nativeSnapshotURL) == saved)

        let restarted = controller(driver)
        try restarted.setRestoreProgress(1)
        try restarted.verifyRestored(before)
        #expect(restarted.hasPendingSnapshot)
        #expect(try Data(contentsOf: paths.nativeSnapshotURL) == saved)
        try restarted.restore()
        try restarted.verifyRestored(before)
        #expect(!restarted.hasPendingSnapshot)
    }

    @Test func gradualRestorationRejectsInvalidProgressWithoutTouchingDisplaysOrSnapshot() throws {
        let driver = FakeGammaDriver(displays: [FakeGammaDisplay(uuid: "A", displayID: 1, table: curve(0.8))])
        let subject = controller(driver)
        try subject.dim()
        let saved = try Data(contentsOf: paths.nativeSnapshotURL)
        driver.writes.removeAll()
        for value: Double in [-0.001, 1.001, .nan, .infinity, -.infinity] {
            #expect(throws: NativeGammaError.invalidProgress) { try subject.setRestoreProgress(value) }
        }
        #expect(driver.writes.isEmpty)
        #expect(driver.display("A").table.isBlack)
        #expect(try Data(contentsOf: paths.nativeSnapshotURL) == saved)
    }

    @Test func gradualRestorationRequiresSavedOriginals() throws {
        let driver = FakeGammaDriver(displays: [FakeGammaDisplay(uuid: "A", displayID: 1, table: curve(0.8))])
        let subject = controller(driver)
        #expect(throws: NativeGammaError.missingSnapshot) { try subject.setRestoreProgress(0.5) }
        #expect(driver.writes.isEmpty)
        #expect(driver.display("A").table == curve(0.8))
        #expect(!subject.hasPendingSnapshot)
    }

    @Test func partialProgressWriteFailureRollsBackAllDisplaysToOriginals() throws {
        let driver = FakeGammaDriver(displays: [
            FakeGammaDisplay(uuid: "A", displayID: 1, table: curve(0.4)),
            FakeGammaDisplay(uuid: "B", displayID: 2, table: curve(0.8))
        ])
        let subject = controller(driver)
        try subject.dim()
        driver.failNextWriteUUID = "B"
        #expect(throws: NativeGammaError.operationFailed(operation: "fake write", status: -1)) {
            try subject.setRestoreProgress(0.5)
        }
        #expect(driver.display("A").table == curve(0.4))
        #expect(driver.display("B").table == curve(0.8))
        #expect(!subject.hasPendingSnapshot)
    }

    @Test func progressReadbackMismatchIsRejectedAndRolledBack() throws {
        let driver = FakeGammaDriver(displays: [
            FakeGammaDisplay(uuid: "A", displayID: 1, table: curve(0.4)),
            FakeGammaDisplay(uuid: "B", displayID: 2, table: curve(0.8))
        ])
        let subject = controller(driver)
        try subject.dim()
        driver.ignoreNextWriteUUID = "B"
        #expect(throws: NativeGammaError.verificationFailed) { try subject.setRestoreProgress(0.5) }
        #expect(driver.display("A").table == curve(0.4))
        #expect(driver.display("B").table == curve(0.8))
        #expect(!subject.hasPendingSnapshot)
    }

    @Test func failedProgressReadbackRetainsFailedOriginalForRetry() throws {
        let driver = FakeGammaDriver(displays: [
            FakeGammaDisplay(uuid: "A", displayID: 1, table: curve(0.4)),
            FakeGammaDisplay(uuid: "B", displayID: 2, table: curve(0.8))
        ])
        let subject = controller(driver)
        try subject.dim()
        driver.readFailureUUID = "B"
        #expect(throws: NativeGammaError.unsupportedDisplay) { try subject.setRestoreProgress(0.5) }
        #expect(driver.display("A").table == curve(0.4))
        #expect(try snapshot() == [GammaDisplayState(uuid: "B", name: "B", table: curve(0.8))])
        driver.readFailureUUID = nil
        try subject.restore()
        #expect(driver.display("B").table == curve(0.8))
        #expect(!subject.hasPendingSnapshot)
    }

    @Test func disconnectionDuringGradualRestorationPreservesOriginalForReconnection() throws {
        let driver = FakeGammaDriver(displays: [
            FakeGammaDisplay(uuid: "A", displayID: 1, table: curve(0.4)),
            FakeGammaDisplay(uuid: "B", displayID: 2, table: curve(0.8))
        ])
        let subject = controller(driver)
        try subject.dim()
        try subject.setRestoreProgress(0.5)
        driver.update("B") { $0.connected = false }
        #expect(throws: NativeGammaError.displayUnavailable) { try subject.setRestoreProgress(0.75) }
        #expect(driver.display("A").table == curve(0.4))
        #expect(try snapshot() == [GammaDisplayState(uuid: "B", name: "B", table: curve(0.8))])
        driver.update("B") { $0.connected = true; $0.displayID = 99 }
        try subject.restore()
        #expect(driver.writes.contains { $0.uuid == "B" && $0.displayID == 99 && $0.table == curve(0.8) })
        #expect(!subject.hasPendingSnapshot)
    }

    @Test func failedRestoreKeepsOnlyFailedStateAndAllowsExplicitRetry() throws {
        let driver = FakeGammaDriver(displays: [
            FakeGammaDisplay(uuid: "A", displayID: 1, table: curve(0.4)),
            FakeGammaDisplay(uuid: "B", displayID: 2, table: curve(0.8))
        ])
        let subject = controller(driver)
        try subject.dim()
        driver.failRestoreUUID = "B"
        #expect(throws: NativeGammaError.restorePending(count: 1)) { try subject.restore() }
        #expect(driver.display("A").table == curve(0.4))
        #expect(driver.display("B").table.isBlack)
        #expect(try snapshot().map(\.uuid) == ["B"])
        driver.failRestoreUUID = nil
        try subject.restore()
        #expect(driver.display("B").table == curve(0.8))
        #expect(!subject.hasPendingSnapshot)
    }

    @Test func malformedOrAmbiguousSnapshotsNeverWriteToDisplays() throws {
        let driver = FakeGammaDriver(displays: [FakeGammaDisplay(uuid: "A", displayID: 1, table: curve(0.4))])
        let subject = controller(driver)
        let valid = GammaDisplayState(uuid: "A", name: "A", table: curve(0.6))
        let invalidTable = GammaTable(red: [0, 1], green: [0], blue: [0, 1])
        let outOfRange = GammaTable(red: [0, 2], green: [0, 1], blue: [0, 1])
        let inputs: [Data] = [
            Data("invalid-json".utf8),
            try JSONEncoder().encode([valid, valid]),
            try JSONEncoder().encode([GammaDisplayState(uuid: "A", name: "A", table: invalidTable)]),
            try JSONEncoder().encode([GammaDisplayState(uuid: "A", name: "A", table: outOfRange)]),
            Data("[{\"uuid\":\"A\",\"name\":\"A\",\"table\":{\"red\":[0,NaN],\"green\":[0,1],\"blue\":[0,1]}}]".utf8)
        ]
        for input in inputs {
            try paths.writePrivate(input, to: paths.nativeSnapshotURL)
            #expect(throws: NativeGammaError.invalidSnapshot) { try subject.restore() }
            #expect(throws: NativeGammaError.invalidSnapshot) { try subject.dim() }
            #expect(throws: NativeGammaError.invalidSnapshot) { try subject.setRestoreProgress(0.5) }
            #expect(try Data(contentsOf: paths.nativeSnapshotURL) == input)
            #expect(driver.writes.isEmpty)
            #expect(driver.display("A").table == curve(0.4))
        }
    }

    @Test func invalidLiveTablesAreRejectedBeforeSnapshotOrWrite() throws {
        let invalid = GammaTable(red: [0, .infinity], green: [0, 1], blue: [0, 1])
        let driver = FakeGammaDriver(displays: [FakeGammaDisplay(uuid: "A", displayID: 1, table: invalid)])
        let subject = controller(driver)
        #expect(throws: NativeGammaError.invalidTable) { try subject.dim() }
        #expect(driver.writes.isEmpty)
        #expect(!subject.hasPendingSnapshot)
    }

    @Test func restoringAcrossGammaCapacityChangeAcceptsInterpolatedReadback() throws {
        let original = GammaTable(red: [0, 0.4, 0.8], green: [0, 0.3, 0.6], blue: [0, 0.2, 0.4])
        let driver = FakeGammaDriver(displays: [FakeGammaDisplay(uuid: "A", displayID: 1, table: original)])
        let subject = controller(driver)
        let before = try subject.capture()
        try subject.dim()
        driver.resampleRestore = true
        try subject.restore()
        #expect(driver.display("A").table.red.count == 2)
        try subject.verifyRestored(before)
        #expect(!subject.hasPendingSnapshot)
    }

    @Test func oldRecoveryLeaseCannotRestoreAReplacementSession() throws {
        let driver = FakeGammaDriver(displays: [FakeGammaDisplay(uuid: "A", displayID: 1, table: curve(0.4))])
        let subject = controller(driver)
        let firstToken = UUID().uuidString
        let replacementToken = UUID().uuidString
        try subject.claimRecoveryLease(firstToken)
        try subject.dim()
        try subject.claimRecoveryLease(replacementToken)
        driver.writes.removeAll()
        #expect(try !subject.restore(ifRecoveryLease: firstToken))
        #expect(driver.writes.isEmpty)
        #expect(driver.display("A").table.isBlack)
        #expect(subject.hasPendingSnapshot)
        #expect(try subject.restore(ifRecoveryLease: replacementToken))
        #expect(driver.display("A").table == curve(0.4))
        #expect(!subject.hasPendingSnapshot)
        let mode = try FileManager.default.attributesOfItem(atPath: subject.recoveryLeaseURL.path)[.posixPermissions] as? Int
        #expect(mode == 0o600)
    }

    @Test func oldRecoveryLeaseDoesNotReadOrReplaceCorruptSnapshot() throws {
        let driver = FakeGammaDriver(displays: [FakeGammaDisplay(uuid: "A", displayID: 1, table: curve(0.4))])
        let subject = controller(driver)
        let firstToken = UUID().uuidString
        try subject.claimRecoveryLease(UUID().uuidString)
        let corrupt = Data("invalid-json".utf8)
        try paths.writePrivate(corrupt, to: paths.nativeSnapshotURL)
        #expect(try !subject.restore(ifRecoveryLease: firstToken))
        #expect(driver.writes.isEmpty)
        #expect(try Data(contentsOf: paths.nativeSnapshotURL) == corrupt)
    }

    @Test func snapshotWriteFailureDoesNotDimAnyDisplay() throws {
        let driver = FakeGammaDriver(displays: [FakeGammaDisplay(uuid: "A", displayID: 1, table: curve(0.4))])
        let subject = controller(driver)
        #expect(FileManager.default.createFile(atPath: directory.path, contents: Data()))
        #expect(throws: (any Error).self) { try subject.dim() }
        #expect(driver.writes.isEmpty)
        #expect(driver.display("A").table == curve(0.4))
    }
}

private func curve(_ maximum: Float) -> GammaTable {
    GammaTable(red: [0, maximum / 2, maximum], green: [0, maximum / 3, maximum / 2],
               blue: [0, maximum / 4, maximum / 3])
}

private struct FakeGammaDisplay {
    let uuid: String
    var displayID: Int
    var table: GammaTable
    var connected = true
}

private final class FakeGammaDriver: GammaDisplayDriving {
    struct Write {
        let uuid: String
        let displayID: Int
        let table: GammaTable
    }

    var displays: [FakeGammaDisplay]
    var writes: [Write] = []
    var readFailureUUID: String?
    var failNextBlackUUID: String?
    var ignoreBlackUUID: String?
    var failRestoreUUID: String?
    var failNextWriteUUID: String?
    var ignoreNextWriteUUID: String?
    var resampleRestore = false
    var beforeWrite: ((GammaTable, String) throws -> Void)?

    init(displays: [FakeGammaDisplay]) { self.displays = displays }

    func display(_ uuid: String) -> FakeGammaDisplay { displays.first { $0.uuid == uuid }! }
    func update(_ uuid: String, _ body: (inout FakeGammaDisplay) -> Void) {
        body(&displays[displays.firstIndex { $0.uuid == uuid }!])
    }

    func connectedDisplays() throws -> [GammaDisplay] {
        displays.filter(\.connected).map { GammaDisplay(uuid: $0.uuid, name: $0.uuid) }
    }

    func read(uuid: String) throws -> GammaTable {
        guard let display = displays.first(where: { $0.uuid == uuid && $0.connected }) else {
            throw NativeGammaError.displayUnavailable
        }
        if readFailureUUID == uuid { throw NativeGammaError.unsupportedDisplay }
        return display.table
    }

    func write(_ table: GammaTable, uuid: String) throws {
        guard let index = displays.firstIndex(where: { $0.uuid == uuid && $0.connected }) else {
            throw NativeGammaError.displayUnavailable
        }
        try beforeWrite?(table, uuid)
        writes.append(Write(uuid: uuid, displayID: displays[index].displayID, table: table))
        if failNextWriteUUID == uuid {
            failNextWriteUUID = nil
            throw NativeGammaError.operationFailed(operation: "fake write", status: -1)
        }
        if ignoreNextWriteUUID == uuid { ignoreNextWriteUUID = nil; return }
        if table.isBlack && failNextBlackUUID == uuid {
            failNextBlackUUID = nil
            throw NativeGammaError.operationFailed(operation: "fake write", status: -1)
        }
        if !table.isBlack && failRestoreUUID == uuid {
            throw NativeGammaError.operationFailed(operation: "fake write", status: -1)
        }
        if table.isBlack && ignoreBlackUUID == uuid { return }
        if !table.isBlack && resampleRestore {
            displays[index].table = GammaTable(red: [table.red.first!, table.red.last!],
                                               green: [table.green.first!, table.green.last!],
                                               blue: [table.blue.first!, table.blue.last!])
        } else { displays[index].table = table }
    }
}
