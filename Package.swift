// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Tr3",
    products: [
        .library(
            name: "Tr3",
            targets: ["Tr3"]),
    ],
    dependencies: [
        .package(url: "https://github.com/musesum/Par.git", from: "0.1.2"),
        //.package(path: "../Par"),
        //.package(path: "../Resources"),
    ],
    targets: [
        .target(
            name: "Tr3",
            dependencies: ["Par"]),
        .testTarget(
            name: "Tr3Tests",
            dependencies: ["Tr3"]),
    ]
)
