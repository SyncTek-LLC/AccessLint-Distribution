// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
            url: "https://github.com/mauricecarrier7/AccessLint-Distribution/releases/download/1.0.0/accesslint-1.0.0.artifactbundle.zip",
            checksum: "45bc79dd087541e9241f0224ae2cb6fca78ef94d1980af9c035d1e41b34d9df3"
        )
    ]
)
