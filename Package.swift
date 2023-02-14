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
            publicHeadersPath: ".",
			    cSettings: [
				    .headerSearchPath("."),
				    .headerSearchPath("Public"),
			    ])
    ]
)