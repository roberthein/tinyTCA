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
    ],
    targets: [
        .target(
            name: "tinyTCA",
            exclude: ["SVG"],
            swiftSettings: [
                // Strict concurrency checking (recommended for Swift 6)
                .enableExperimentalFeature("StrictConcurrency")
            ]
        )
    ]
)
