// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "weipl-checkout-ios",
    products:[
        .library(
            name: "weipl-checkout-ios"
            type: .dynamic,
            targets :["weipl-checkout-ios"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/Worldline-ePayments-India/weipl-checkout-ios.git", from: "1.1.5")

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "weipl-checkout-ios",
            dependencies: []
        ),
        .binaryTarget(
            name: "weipl_checkout",
            path: "weipl_checkout/weipl_checkout.framework"
        )
        .testTarget(
            name: "weipl-checkout-iosTests",
            dependencies: ["weipl-checkout-ios"]
        ),
    ]
)
