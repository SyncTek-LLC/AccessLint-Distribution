// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "AccessLint",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "accesslint", targets: ["accesslint"])
    ],
    targets: [
        .binaryTarget(
            name: "accesslint",
            url: "https://github.com/mauricecarrier7/AccessLint/releases/download/v1.2.0/accesslint-1.2.0.artifactbundle.zip",
            checksum: "6a52f64ad9eb54bf50019691e2745964988a39a683684e272a1c47cac692a677"
        )
    ]
)
