// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "postgreshelper",
    dependencies: [
        .package(name: "swift-argument-parser", url: "https://github.com/apple/swift-argument-parser", .exact("0.3.1"))
    ],
    targets: [
        .target(
            name: "postgreshelper",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            resources: [
                .copy("Resources/close-terminal.applescript")
            ]
        ),
        .testTarget(
            name: "postgreshelperTests",
            dependencies: ["postgreshelper"]),
    ]
)
