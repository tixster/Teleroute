// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

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
        .library(
            name: "TelerouteTestSupport",
            targets: ["TelerouteTestSupport"]
        ),
        .executable(
            name: "TelerouteExample",
            targets: ["TelerouteExample"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.12.0"),
        .package(url: "https://github.com/nerzh/swift-telegram-bot", from: "10.0.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.0"),
    ],
    targets: [
        .target(
            name: name,
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "HeapModule", package: "swift-collections"),
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "SwiftTelegramBot", package: "swift-telegram-bot"),
                .target(name: "TelerouteMacros"),
            ],
            swiftSettings: settings
        ),
        .macro(
            name: "TelerouteMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "TelerouteTests",
            dependencies: [
                .byName(name: name),
                .byName(name: "TelerouteTestSupport"),
                .target(name: "TelerouteMacros"),
            ],
            swiftSettings: settings
        ),
        .target(
            name: "TelerouteTestSupport",
            dependencies: [
                .byName(name: name),
                .product(name: "SwiftTelegramBot", package: "swift-telegram-bot"),
            ],
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
