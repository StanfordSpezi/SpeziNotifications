// swift-tools-version:6.0

//
// This source file is part of the SpeziNotifications open source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import class Foundation.ProcessInfo
import PackageDescription


let package = Package(
    name: "SpeziNotifications",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1),
        .tvOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "SpeziNotifications", targets: ["SpeziNotifications"]),
        .library(name: "XCTSpeziNotifications", targets: ["XCTSpeziNotifications"]),
        .library(name: "XCTSpeziNotificationsUI", targets: ["XCTSpeziNotificationsUI"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/Spezi.git", from: "1.8.0"),
        .package(url: "https://github.com/StanfordSpezi/SpeziViews.git", from: "1.7.1")
    ] + swiftLintPackage(),
    targets: [
        .target(
            name: "SpeziNotifications",
            dependencies: [
                .product(name: "Spezi", package: "Spezi")
            ],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")],
            plugins: [] + swiftLintPlugin()
        ),
        .target(
            name: "XCTSpeziNotifications",
            dependencies: [
                .target(name: "SpeziNotifications")
            ],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")],
            plugins: [] + swiftLintPlugin()
        ),
        .target(
            name: "XCTSpeziNotificationsUI",
            dependencies: [
                .target(name: "SpeziNotifications"),
                .product(name: "SpeziViews", package: "SpeziViews")
            ],
            resources: [.process("Resources")],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")],
            plugins: [] + swiftLintPlugin()
        ),
        .testTarget(
            name: "SpeziNotificationsTests",
            dependencies: [
                .target(name: "SpeziNotifications"),
                .product(name: "Spezi", package: "Spezi"),
                .product(name: "XCTSpezi", package: "Spezi")
            ],
            swiftSettings: [.enableUpcomingFeature("ExistentialAny")],
            plugins: [] + swiftLintPlugin()
        )
    ]
)


func swiftLintPlugin() -> [Target.PluginUsage] {
    // Fully quit Xcode and open again with `open --env SPEZI_DEVELOPMENT_SWIFTLINT /Applications/Xcode.app`
    if ProcessInfo.processInfo.environment["SPEZI_DEVELOPMENT_SWIFTLINT"] != nil {
        [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
    } else {
        []
    }
}

func swiftLintPackage() -> [PackageDescription.Package.Dependency] {
    if ProcessInfo.processInfo.environment["SPEZI_DEVELOPMENT_SWIFTLINT"] != nil {
        [.package(url: "https://github.com/realm/SwiftLint.git", from: "0.55.1")]
    } else {
        []
    }
}
