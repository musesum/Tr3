// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Tr3",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Tr3",
            targets: ["Tr3"]),
    ],
    dependencies: [
        .package(url: "https://github.com/musesum/Par.git", from: "0.2.0"),
        .package(url: "https://github.com/musesum/MuSkyTr3.git", from: "0.3.0"),
        .package(url: "https://github.com/apple/swift-collections.git",
                 .upToNextMajor(from: "1.0.0") // or `.upToNextMinor
        )
    ],

    targets: [
        .target(name: "Tr3",
                dependencies: [
                    .product(name: "Collections", package: "swift-collections"),
                    .product(name: "MuSkyTr3", package: "MuSkyTr3"),
                    .product(name: "Par", package: "Par")],
                resources: [.process("Resources")]),
        .testTarget(name: "Tr3Tests", dependencies: ["MuSkyTr3","Tr3"]),
    ]
)
