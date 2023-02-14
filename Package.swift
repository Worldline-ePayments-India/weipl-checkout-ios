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
    targets: [
        .target(
            name: "weipl_checkout",
            dependencies: [],
            path: "weipl_checkout/weipl_checkout.framework",
            exclude: ["Info.plist"],
            resources: [
            ]
            publicHeadersPath: "weipl_checkout/**/*.{h,m,swift}"
        )
    ]
)