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
            name: "TelegramBotAPI",
            targets: ["TelegramBotAPI"]
        ),
        .library(
            name: "TelegramBotKit",
            targets: ["TelegramBotKit"]
        ),
        .library(
            name: "TelerouteMacros",
            targets: ["TelerouteMacros"]
        ),
        .library(
            name: "TelerouteTestSupport",
            targets: ["TelerouteTestSupport"]
        ),
        .library(
            name: "TelerouteHummingbird",
            targets: ["TelerouteHummingbird"]
        ),
        .executable(
            name: "TelerouteExample",
            targets: ["TelerouteExample"]
        ),
        .executable(
            name: "TelerouteBenchmarks",
            targets: ["TelerouteBenchmarks"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.12.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.8.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-async-http-client", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-http-types", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle", from: "2.6.0"),
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-metrics", from: "2.5.0"),
    ],
    targets: [
        // Generated Telegram Bot API types and client (committed output of
        // Scripts/generate-api.sh). Compiled with minimal settings on purpose:
        // the package's upcoming-feature flags are not applied to generated code.
        .target(
            name: "TelegramBotAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        // Hand-written client layer plus committed flat convenience wrappers for
        // every Bot API operation (output of Scripts/generate-client.py).
        // Deliberately compiled without the package's upcoming-feature flags.
        .target(
            name: "TelegramBotKit",
            dependencies: [
                .target(name: "TelegramBotAPI"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .target(
            name: name,
            dependencies: [
                .target(name: "TelegramBotKit"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                .product(name: "HeapModule", package: "swift-collections"),
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
                .product(name: "Metrics", package: "swift-metrics"),
            ],
            swiftSettings: settings
        ),
        .target(
            name: "TelerouteMacros",
            dependencies: [
                .byName(name: name),
                .target(name: "TelerouteMacroPlugin"),
            ],
            swiftSettings: settings
        ),
        .macro(
            name: "TelerouteMacroPlugin",
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
                .byName(name: "TelerouteMacros"),
                .byName(name: "TelerouteHummingbird"),
                .product(name: "HummingbirdTesting", package: "hummingbird"),
            ],
            swiftSettings: settings
        ),
        .target(
            name: "TelerouteTestSupport",
            dependencies: [
                .byName(name: name),
                .target(name: "TelegramBotAPI"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "HTTPTypes", package: "swift-http-types"),
            ],
            swiftSettings: settings
        ),
        // Webhook integration for Hummingbird 2 applications. Compiled without
        // the package's upcoming-feature flags to avoid conformance friction
        // with Hummingbird's own protocols.
        .target(
            name: "TelerouteHummingbird",
            dependencies: [
                .byName(name: name),
                .product(name: "Hummingbird", package: "hummingbird"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ]
        ),
        .executableTarget(
            name: "TelerouteExample",
            dependencies: [
                .byName(name: name),
                .byName(name: "TelerouteMacros"),
            ],
            resources: [
                .copy("README.md"),
            ],
            swiftSettings: settings
        ),
        .executableTarget(
            name: "TelerouteBenchmarks",
            dependencies: [
                .byName(name: name),
                .byName(name: "TelerouteTestSupport"),
            ],
            swiftSettings: settings
        ),
    ]
)
