import CryptoKit
import Darwin
import Foundation

public struct InstallationIdentity: Equatable {
    public let rawValue: String

    public init(bundleURL: URL, executableURL: URL, version: String, buildVersion: String) throws {
        let installation = Components(version: version, buildVersion: buildVersion,
                                      bundle: try FileIdentity(url: bundleURL, includeChanges: false),
                                      executable: try FileIdentity(url: executableURL, includeChanges: true))
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        rawValue = SHA256.hash(data: try encoder.encode(installation))
            .map { String(format: "%02x", $0) }.joined()
    }

    public static func current(bundle: Bundle = .main) throws -> InstallationIdentity {
        guard let executableURL = bundle.executableURL else { throw CocoaError(.fileReadNoSuchFile) }
        return try InstallationIdentity(
            bundleURL: bundle.bundleURL, executableURL: executableURL,
            version: bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "development",
            buildVersion: bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "development")
    }

    private struct Components: Encodable {
        let schema = 1
        let version: String
        let buildVersion: String
        let bundle: FileIdentity
        let executable: FileIdentity
    }

    private struct FileIdentity: Encodable {
        let volumeUUID: String
        let inode: UInt64
        let birthSeconds: Int64
        let birthNanoseconds: Int64
        let changeSeconds: Int64?
        let changeNanoseconds: Int64?

        init(url: URL, includeChanges: Bool) throws {
            let fileURL = url.resolvingSymlinksInPath()
            guard let volumeUUID = try fileURL.resourceValues(forKeys: [.volumeUUIDStringKey]).volumeUUIDString,
                  !volumeUUID.isEmpty else { throw CocoaError(.fileReadUnknown) }
            var metadata = stat()
            let result = fileURL.withUnsafeFileSystemRepresentation { path in
                guard let path else { return Int32(-1) }
                return Darwin.lstat(path, &metadata)
            }
            guard result == 0 else { throw CocoaError(.fileReadUnknown) }
            self.volumeUUID = volumeUUID
            inode = UInt64(metadata.st_ino)
            birthSeconds = Int64(metadata.st_birthtimespec.tv_sec)
            birthNanoseconds = Int64(metadata.st_birthtimespec.tv_nsec)
            // An installer can overwrite the executable without replacing its inode.
            // Its ctime detects that copy even when the source mtime is preserved.
            changeSeconds = includeChanges ? Int64(metadata.st_ctimespec.tv_sec) : nil
            changeNanoseconds = includeChanges ? Int64(metadata.st_ctimespec.tv_nsec) : nil
        }
    }
}
