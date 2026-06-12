// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "KanaCore",
    platforms: [
        .watchOS(.v10),
        .iOS(.v17),
        .macOS(.v13),
    ],
    products: [
        .library(name: "KanaCore", targets: ["KanaCore"]),
    ],
    targets: [
        .target(name: "KanaCore"),
        .testTarget(name: "KanaCoreTests", dependencies: ["KanaCore"]),
    ]
)
