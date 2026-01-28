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
            url: "https://github.com/mauricecarrier7/AccessLint/releases/download/v1.1.0/accesslint-1.1.0.artifactbundle.zip",
            checksum: "7267448f24fd5be6066a6a9f3d7fcda6f1bc9821ae568d3f273c5fd71255464b"
        )
    ]
)
