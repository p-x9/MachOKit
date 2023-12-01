// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MachOKit",
    products: [
        .library(
            name: "MachOKit",
            targets: ["MachOKit"]
        )
    ],
    targets: [
        .target(
            name: "MachOKit")
        ,
        .testTarget(
            name: "MachOKitTests",
            dependencies: ["MachOKit"]
        )
    ]
)
