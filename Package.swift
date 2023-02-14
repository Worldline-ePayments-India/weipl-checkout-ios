// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "weipl_checkout",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    swiftLanguageVersions: [
        .v5
    ]
    products: [
            .executable(name: "weipl_checkout", targets: [ "weipl_checkout.framework" ]),

    ],
    dependencies: [
        .package(url: "https://github.com/Worldline-ePayments-India/weipl-checkout-ios.git", .exact("1.1.5")),

    ],
    targets: [
        .target(
            name: "weipl_checkout",
            dependencies: [],
            path: "weipl_checkout/weipl_checkout.framework",
            exclude: ["Info.plist"])
    ]
)