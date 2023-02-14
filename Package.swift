// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "weipl-checkout-ios",
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
            dependencies: []),
        .testTarget(
            name: "weipl-checkout-iosTests",
            dependencies: ["weipl_checkout"]),
    ]
)