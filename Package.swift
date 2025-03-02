// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AO3Scraper",
    platforms: [.macOS(.v13), .iOS(.v16), .watchOS(.v9)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AO3Scraper",
            targets: ["AO3Scraper"]),
    ],
    dependencies: [
        .package(url: "git@github.com:scinfu/SwiftSoup.git", from: "2.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AO3Scraper",
            dependencies: [
                .product(name: "SwiftSoup", package: "SwiftSoup")
            ]),
        .testTarget(
            name: "AO3ScraperTests",
            dependencies: ["AO3Scraper"]
        ),
    ]
)
