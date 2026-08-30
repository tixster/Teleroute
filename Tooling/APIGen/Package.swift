// swift-tools-version: 6.0
// Dev-only mini-package: pins swift-openapi-generator for `Scripts/generate-api.sh`.
// Deliberately outside the main package graph so Teleroute consumers never
// resolve or build the generator.

import PackageDescription

let package = Package(
    name: "APIGen",
    platforms: [
        .macOS(.v14),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", exact: "1.10.3"),
    ]
)
