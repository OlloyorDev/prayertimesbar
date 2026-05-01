// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PrayerTimesBar",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/batoulapps/adhan-swift", from: "1.4.0")
    ],
    targets: [
        .executableTarget(
            name: "PrayerTimesBar",
            dependencies: [
                .product(name: "Adhan", package: "adhan-swift")
            ]
        )
    ]
)
