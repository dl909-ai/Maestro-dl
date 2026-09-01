// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppleSecurity",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(name: "AppleSecurity", targets: ["AppleSecurity"])
    ],
    targets: [
        .target(name: "AppleSecurity"),
        .testTarget(name: "AppleSecurityTests", dependencies: ["AppleSecurity"])
    ]
)
