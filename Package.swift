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
            checksum: "0b6e53c5b77b97381540e4a6f6dd2b61e237441f7c97d724077adf1d27d6e6f2"
        )
    ]
)
