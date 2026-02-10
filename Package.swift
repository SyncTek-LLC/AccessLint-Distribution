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
            url: "https://github.com/SyncTek-LLC/AccessLint/releases/download/v1.3.0/accesslint-1.3.0.artifactbundle.zip",
            checksum: "f1285a2a2d9fa6396d6d16711e41ac758eafe3d1ec02f25b31591668c6cfe7a9"
        )
    ]
)
