// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AudioCascade",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "AudioCascade",
            targets: ["AudioCascade"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.5.0")
    ],
    targets: [
        .executableTarget(
            name: "AudioCascade",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "AudioCascade/Sources",
            resources: [
                .process("../Resources")
            ]
        ),
        .testTarget(
            name: "AudioCascadeTests",
            dependencies: ["AudioCascade"],
            path: "AudioCascade/Tests"
        )
    ]
)
