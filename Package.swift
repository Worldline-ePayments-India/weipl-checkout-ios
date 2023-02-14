// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "weipl_checkout",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12)
    ],
    
    dependencies: [
        .package(url: "https://github.com/Worldline-ePayments-India/weipl-checkout-ios.git", .exact("1.1.5")),
    ],
    targets: [
        .target(
            name: "weipl_checkout",
            dependencies: ["weipl_checkout.framework"],
            path: "weipl_checkout/weipl_checkout.framework",
            exclude: ["Info.plist"])
    ]
)