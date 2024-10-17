// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MachOKit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6),
        .tvOS(.v13),
    ],
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
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", "1.0.0" ..< "4.0.0")
    ],
    targets: [
        .target(
            name: "MachOKit",
            dependencies: [
                "MachOKitC",
                .product(name: "Crypto", package: "swift-crypto")
            ],
            swiftSettings: SwiftSetting.allCases + [
                .enableExperimentalFeature("AccessLevelOnImport", .when(configuration: .debug))
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

// https://github.com/treastrain/swift-upcomingfeatureflags-cheatsheet
extension SwiftSetting {
    static let forwardTrailingClosures: Self = .enableUpcomingFeature("ForwardTrailingClosures")              // SE-0286, Swift 5.3,  SwiftPM 5.8+
    static let existentialAny: Self = .enableUpcomingFeature("ExistentialAny")                                // SE-0335, Swift 5.6,  SwiftPM 5.8+
    static let bareSlashRegexLiterals: Self = .enableUpcomingFeature("BareSlashRegexLiterals")                // SE-0354, Swift 5.7,  SwiftPM 5.8+
    static let conciseMagicFile: Self = .enableUpcomingFeature("ConciseMagicFile")                            // SE-0274, Swift 5.8,  SwiftPM 5.8+
    static let importObjcForwardDeclarations: Self = .enableUpcomingFeature("ImportObjcForwardDeclarations")  // SE-0384, Swift 5.9,  SwiftPM 5.9+
    static let disableOutwardActorInference: Self = .enableUpcomingFeature("DisableOutwardActorInference")    // SE-0401, Swift 5.9,  SwiftPM 5.9+
    static let deprecateApplicationMain: Self = .enableUpcomingFeature("DeprecateApplicationMain")            // SE-0383, Swift 5.10, SwiftPM 5.10+
    static let isolatedDefaultValues: Self = .enableUpcomingFeature("IsolatedDefaultValues")                  // SE-0411, Swift 5.10, SwiftPM 5.10+
    static let globalConcurrency: Self = .enableUpcomingFeature("GlobalConcurrency")                          // SE-0412, Swift 5.10, SwiftPM 5.10+
}

extension SwiftSetting: CaseIterable {
    public static var allCases: [Self] {
        [
            .forwardTrailingClosures,
            .existentialAny,
            .bareSlashRegexLiterals,
            .conciseMagicFile,
            .importObjcForwardDeclarations,
            .disableOutwardActorInference,
            .deprecateApplicationMain,
            .isolatedDefaultValues,
            .globalConcurrency
        ]
    }
}
