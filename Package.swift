// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DailyApp",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .executable(
            name: "DailyApp",
            targets: ["DailyApp"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey", from: "0.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "DailyApp",
            dependencies: ["HotKey"]),
    ]
)
