// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "eleph",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(name: "ElephApp", targets: ["ElephApp"]),
        .library(name: "ElephCore", targets: ["ElephCore"]),
        .library(name: "ElephMarkdown", targets: ["ElephMarkdown"]),
        .library(name: "ElephThemes", targets: ["ElephThemes"]),
        .executable(name: "ElephIOS", targets: ["ElephIOS"]),
        .executable(name: "ElephMacOS", targets: ["ElephMacOS"])
    ],
    dependencies: [
        // CommonMark parsing
        .package(url: "https://github.com/apple/swift-markdown.git", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: "ElephApp",
            dependencies: [
                "ElephCore",
                "ElephMarkdown",
                "ElephThemes"
            ],
            path: "Sources/ElephApp"
        ),
        .executableTarget(
            name: "ElephMacOS",
            dependencies: ["ElephApp", "ElephCore", "ElephMarkdown", "ElephThemes"],
            path: "App/macOS",
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "ElephIOS",
            dependencies: ["ElephApp", "ElephCore", "ElephMarkdown", "ElephThemes"],
            path: "App/iOS",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "ElephCore",
            dependencies: []
        ),
        .target(
            name: "ElephMarkdown",
            dependencies: [
                .product(name: "Markdown", package: "swift-markdown"),
                "ElephThemes"
            ]
        ),
        .target(
            name: "ElephThemes",
            dependencies: []
        ),
        .testTarget(
            name: "ElephTests",
            dependencies: ["ElephCore", "ElephMarkdown", "ElephThemes"],
            path: "Tests/ElephTests"
        )
    ]
)
