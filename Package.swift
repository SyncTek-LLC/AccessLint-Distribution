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
            url: "https://github.com/SyncTek-LLC/AccessLint/releases/download/v1.3.1/accesslint-1.3.1.artifactbundle.zip",
            checksum: "b5e33dea791559201a203b28d7a3767bba7b710ac5d551a3b9b890fcb12bb109"
        )
    ]
)
