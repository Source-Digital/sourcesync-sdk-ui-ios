// swift-tools-version: 5.7
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
    dependencies: [
        .package(url: "https://github.com/divkit/divkit-ios.git", from: "31.14.0"),
    ],
    targets: [
        .target(
            name: "SourceSyncSDK",
            dependencies: [
                .product(name: "DivKit", package: "divkit-ios"),
                .product(name: "DivKitExtensions", package: "divkit-ios" )
            ],
            swiftSettings: [
                .define("SUPPORT_MULTIPLE_ARCHITECTURES")
            ]
        )
    ]
)
