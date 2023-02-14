// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "weipl_checkout",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "weipl_checkout",
            targets: ["weipl_checkout"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Worldline-ePayments-India/weipl-checkout-ios.git", from: "1.1.5"),
    ],
    
    targets: [
        .target(
            name: "weipl_checkout",
            dependencies: [],
            path: "weipl_checkout/weipl_checkout.framework",
            exclude: ["Info.plist"],
            resources: [
            ]
        )
        .binaryTarget(
            name: "weipl_checkout",
            url: "https://customers.pspdfkit.com/pspdfkit/xcframework/10.0.0.zip",
            checksum: "bfb412ada4d291e22542c2d06b3e9f811616fb043fbd12660b0108541eb33a3c"),
    ]
)