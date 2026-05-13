// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let settings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("ExistentialAny"),
]

let name = "Teleroute"

let package = Package(
    name: name,
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(
            name: name,
            targets: [name]
        ),
        .executable(
            name: "TelerouteExample",
            targets: ["TelerouteExample"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log", from: "1.12.0"),
        .package(url: "https://github.com/nerzh/swift-telegram-bot", from: "10.0.0"),
    ],
    targets: [
        .target(
            name: name,
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SwiftTelegramBot", package: "swift-telegram-bot"),
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "TelerouteTests",
            dependencies: [.byName(name: name)],
            swiftSettings: settings
        ),
        .executableTarget(
            name: "TelerouteExample",
            dependencies: [
                .byName(name: name),
            ],
            resources: [
                .copy("README.md"),
            ],
            swiftSettings: settings
        ),
    ]
)
