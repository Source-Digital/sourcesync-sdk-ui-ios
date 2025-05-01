// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SourceSyncSDK",
    platforms: [
        .iOS(.v14)  // iOS only now
    ],
    products: [
        .library(
            name: "SourceSyncSDK",
            targets: ["SourceSyncSDK"]),
    ],
    targets: [
        .target(
            name: "SourceSyncSDK",
            dependencies: [],
            swiftSettings: [
                .define("SUPPORT_MULTIPLE_ARCHITECTURES")
            ]
        )
    ]
)