// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AIKit",
     platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AIKit",
            targets: ["AIKit"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-collections.git",
            from: "1.0.0"),
        .package(
            url: "https://github.com/apple/swift-async-algorithms.git",
            from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
         .target(
            name: "AIKit",
            dependencies: [
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ],
            path: "Sources/AIKit"),
        .testTarget(
            name: "AIKitTests",
            dependencies: ["AIKit"]
        ),
    ]
)
