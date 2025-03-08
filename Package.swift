// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "iBubble",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "iBubble",
            targets: ["iBubble"]
        ),
    ],
    targets: [
        .target(
            name: "iBubble"
        ),
    ]
)
