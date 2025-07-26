// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "tinyTCA",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "tinyTCA",
            targets: ["tinyTCA"]
        ),
        .library(
            name: "tinyTCATestUtils",
            targets: ["tinyTCATestUtils"]
        )
    ],
    targets: [
        .target(
            name: "tinyTCA",
            swiftSettings: [
                // Strict concurrency checking (recommended for Swift 6)
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "tinyTCATestUtils",
            dependencies: ["tinyTCA"]
        ),
        .testTarget(
            name: "tinyTCATests",
            dependencies: ["tinyTCA", "tinyTCATestUtils"]
        )
    ]
)
