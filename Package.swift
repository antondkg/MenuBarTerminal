// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MenuBarTerminal",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MenuBarTerminal", targets: ["MenuBarTerminal"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/antondkg/SwiftTerm",
            revision: "728e8bed7b106187f2a781229bc1117ca35d7c5c"
        )
    ],
    targets: [
        .executableTarget(
            name: "MenuBarTerminal",
            dependencies: [
                "SwiftTerm"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "MenuBarTerminalTests",
            dependencies: ["MenuBarTerminal"]
        )
    ]
)
