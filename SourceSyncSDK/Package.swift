// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "SourceSyncSDK",
    platforms: [
        .iOS(.v14)
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
                .product(name: "DivKitExtensions", package: "divkit-ios")
            ]
        )
    ]
)