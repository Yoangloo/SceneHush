// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SceneHush",
    defaultLocalization: "en",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "SceneHush", targets: ["SceneHush"])],
    targets: [
        .target(name: "SceneHushCore"),
        .executableTarget(
            name: "SceneHush",
            dependencies: ["SceneHushCore"],
            resources: [.process("Resources")]
        ),
        .testTarget(name: "SceneHushCoreTests", dependencies: ["SceneHushCore"])
    ]
)
