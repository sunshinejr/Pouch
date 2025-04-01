// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "Pouch",
    platforms: [.macOS("13")],
    products: [
        .executable(name: "pouch", targets: ["Pouch"]),
        .library(name: "PouchFramework", targets: ["PouchFramework"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", exact: "1.5.0"),
        .package(url: "https://github.com/jpsim/Yams", exact: "4.0.4"),
        .package(url: "https://github.com/sunshinejr/firebase-ios-sdk", branch: "fork")
    ],
    targets: [
        .executableTarget(
            name: "Pouch",
            dependencies: [
                .target(name: "PouchFramework"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yams", package: "Yams")
            ]),
        .target(
            name: "PouchFramework",
            dependencies: [
                .product(name: "FirebaseRemoteConfig", package: "firebase-ios-sdk"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(name: "PouchTests", dependencies: ["PouchFramework", "Yams"]),
    ]
)
