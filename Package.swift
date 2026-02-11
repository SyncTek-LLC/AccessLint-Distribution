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
            url: "https://github.com/SyncTek-LLC/AccessLint-Distribution/releases/download/v1.3.1/accesslint-1.3.1.artifactbundle.zip",
            checksum: "dd33b21efe1f72da20814022a8f91d243d83081da71c64728cc9b4348f06801d"
        )
    ]
)
