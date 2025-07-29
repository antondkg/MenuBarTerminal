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
        .package(url: "https://github.com/migueldeicaza/SwiftTerm", from: "1.2.3")
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
