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
        .package(url: "https://github.com/apple/swift-collections.git",
                 .upToNextMajor(from: "1.0.0") // or `.upToNextMinor
        )
    ],

    targets: [
        .target(name: "Tr3",
                dependencies: [
                    .product(name: "Collections", package: "swift-collections"),
                    .product(name: "Par", package: "Par")],
                resources: [.process("Resources")]),
        .testTarget(name: "Tr3Tests", dependencies: ["Tr3"]),
    ]
)
