// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Tr3",
    products: [
        .library(
            name: "Tr3",
            targets: ["Tr3"]),
    ],
    dependencies: [
        .package(url: "https://github.com/musesum/Par.git", from: "0.2.0"),
        //.package(path: "../Par"),
    ],
    targets: [
        .target(
            name: "Tr3",
            dependencies: ["Par"],
            resources: [.process("Resources")]),
        .testTarget(
            name: "Tr3Tests",
            dependencies: ["Tr3"]),
    ]
)
