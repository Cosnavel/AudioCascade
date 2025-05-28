// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AudioCascade",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v12)
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
            exclude: [],
            resources: [
                .copy("../Resources/Assets.xcassets"),
                .copy("../Resources/Base.lproj"),
                .copy("../Resources/en.lproj"),
                .copy("../Resources/de.lproj"),
                .copy("../Resources/fr.lproj")
            ],
            linkerSettings: [
                .linkedFramework("CoreAudio"),
                .linkedFramework("AVFoundation"),
                .linkedFramework("AppKit"),
                .linkedFramework("Carbon")
            ]
        ),
        .testTarget(
            name: "AudioCascadeTests",
            dependencies: ["AudioCascade"],
            path: "AudioCascade/Tests"
        )
    ]
)
