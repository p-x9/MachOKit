// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MachOKit",
    products: [
        .library(
            name: "MachOKit",
            targets: ["MachOKit"]
        ),
        .library(
            name: "MachOKitC",
            targets: ["MachOKitC"]
        )
    ],
    targets: [
        .target(
            name: "MachOKit",
            dependencies: [
                "MachOKitC"
            ]
        ),
        .target(
            name: "MachOKitC",
            publicHeadersPath: "include"
        ),
        .testTarget(
            name: "MachOKitTests",
            dependencies: ["MachOKit"]
        )
    ]
)
