// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ConstraintsHolder",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ConstraintsHolder",
            targets: ["ConstraintsHolder"]),
    ],
    dependencies: [
        .package(url: "https://github.com/leofriskey/UIViewID.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ConstraintsHolder",
            dependencies: ["UIViewID"]),
        .testTarget(
            name: "ConstraintsHolderTests",
            dependencies: ["ConstraintsHolder"]),
    ]
)
