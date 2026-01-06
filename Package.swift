// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KieAIKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "KieAIKit",
            targets: ["KieAIKit"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "KieAIKit",
            dependencies: [],
            path: "Sources/KieAIKit"),
        .testTarget(
            name: "KieAIKitTests",
            dependencies: ["KieAIKit"],
            path: "Tests/KieAIKitTests"),
    ]
)
