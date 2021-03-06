// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "Pouch",
    platforms: [.macOS(.v10_11)],
    products: [
        .executable(name: "pouch", targets: ["Pouch"]),
        .library(name: "PouchFramework", targets: ["PouchFramework"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .exact("0.3.2")),
        .package(url: "https://github.com/jpsim/Yams", .exact("4.0.4"))
    ],
    targets: [
        .target(
            name: "Pouch",
            dependencies: [
                .target(name: "PouchFramework"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yams", package: "Yams")
            ]),
        .target(
            name: "PouchFramework",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yams", package: "Yams")
            ]),
        .testTarget(name: "PouchTests", dependencies: ["PouchFramework"]),
    ]
)
