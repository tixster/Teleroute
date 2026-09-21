// swift-tools-version: 6.4
// The Telegram Bot API documentation → Swift generator.
//
// A package of its own, deliberately outside the main graph. Not because the
// sources are large — a consumer clones the whole repository either way — but
// so the library's manifest declares only what the library needs. swift-crypto
// is here to checksum the documentation snapshot; it has no business in the
// dependency list of a Telegram bot framework.

import PackageDescription

let package = Package(
    name: "BotAPIGen",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "BotAPIGen", targets: ["BotAPIGen"]),
    ],
    dependencies: [
        // Snapshot integrity only. Pinned exactly so a regeneration run is
        // reproducible; the version matches what the main package resolves, so
        // a checkout caches one copy rather than two.
        .package(url: "https://github.com/apple/swift-crypto.git", exact: "4.5.2"),
    ],
    targets: [
        .executableTarget(
            name: "BotAPIGen",
            dependencies: [.product(name: "Crypto", package: "swift-crypto")],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "BotAPIGenTests",
            dependencies: ["BotAPIGen"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
