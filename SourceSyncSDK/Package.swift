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
        .package(url: "https://github.com/divkit/divkit-ios.git", from: "32.1.0"),
    ],
    targets: [
        .target(
            name: "SourceSyncSDK",
            dependencies: [
                .product(name: "DivKit", package: "divkit-ios"),
                .product(name: "DivKitExtensions", package: "divkit-ios")
            ],
            cSettings: [
                .define("SWIFT_PACKAGE"),
                .headerSearchPath("include")
            ],
            swiftSettings: [
                .define("SWIFT_PACKAGE"),
                .unsafeFlags([
                    "-Xfrontend", "-enable-library-evolution"
                ], .when(configuration: .release))
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit")
            ]
        )
    ],
    swiftLanguageVersions: [.v5],
    cxxLanguageStandard: .cxx17
)
