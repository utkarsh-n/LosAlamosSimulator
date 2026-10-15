// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LosAlamosCore",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "LosAlamosCore", targets: ["LosAlamosCore"])
    ],
    targets: [
        .target(name: "LosAlamosCore"),
        .testTarget(name: "LosAlamosCoreTests", dependencies: ["LosAlamosCore"])
    ]
)
