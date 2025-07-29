// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

// sdk-version:2.24.6
import PackageDescription

let package = Package(
    name: "RxKakaoOpenSDK",
    defaultLocalization: "ko",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "RxKakaoSDK",
            targets: ["RxKakaoSDKCommon", "RxKakaoSDKAuth", "RxKakaoSDKUser", "RxKakaoSDKCert", "RxKakaoSDKTalk", "RxKakaoSDKFriend", "RxKakaoSDKShare"]),
        .library(
            name: "RxKakaoSDKCommon",
            targets: ["RxKakaoSDKCommon"]),
        .library(
            name: "RxKakaoSDKAuth",
            targets: ["RxKakaoSDKAuth"]),
        .library(
            name: "RxKakaoSDKUser",
            targets: ["RxKakaoSDKUser"]),
        .library(
            name: "RxKakaoSDKCert",
            targets: ["RxKakaoSDKCert"]),
        .library(
            name: "RxKakaoSDKTalk",
            targets: ["RxKakaoSDKTalk"]),
        .library(
            name: "RxKakaoSDKFriend",
            targets: ["RxKakaoSDKFriend"]),
        .library(
            name: "RxKakaoSDKShare",
            targets: ["RxKakaoSDKShare"])
    ],
    dependencies: [
        .package(name: "KakaoOpenSDK",
                 url: "https://github.com/kakao/kakao-ios-sdk.git",
                 .exact("2.24.6")
                ),
        
        .package(name: "RxAlamofire",
                  url: "https://github.com/RxSwiftCommunity/RxAlamofire.git",
                  Version(6,0,0)..<Version(7,0,0)),
        
        .package(name: "RxSwift",
                  url: "https://github.com/ReactiveX/RxSwift.git",
                  Version(6,0,0)..<Version(7,0,0))
    ],
    targets: [
        .target(
            name: "RxKakaoSDKCommon",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxAlamofire", package: "RxAlamofire"),
                .product(name: "KakaoSDKCommon", package: "KakaoOpenSDK")
            ],
            exclude: ["Info.plist", "README.md"]
        ),
        .target(
            name: "RxKakaoSDKAuth",
            dependencies: [
                .target(name: "RxKakaoSDKCommon"),
                .product(name: "KakaoSDKAuth", package: "KakaoOpenSDK")
            ],
            exclude: ["Info.plist", "README.md"]
        ),
        .target(
            name: "RxKakaoSDKUser",
            dependencies: [
                .target(name: "RxKakaoSDKAuth"),
                .product(name: "KakaoSDKUser", package: "KakaoOpenSDK")
            ],
            exclude: ["Info.plist", "README.md"]
        ),
        .target(
            name: "RxKakaoSDKCert",
            dependencies: [
                .target(name: "RxKakaoSDKUser"),
                .product(name: "KakaoSDKCert", package: "KakaoOpenSDK")
            ],
            exclude: ["Info.plist", "README.md"]
        ),
        .target(
            name: "RxKakaoSDKTalk",
            dependencies: [
                .target(name: "RxKakaoSDKUser"),
                .product(name: "KakaoSDKTalk", package: "KakaoOpenSDK"),
                .product(name: "KakaoSDKTemplate", package: "KakaoOpenSDK")
            ],
            exclude: ["Info.plist", "README.md"]
        ),
        .target(
            name: "RxKakaoSDKFriend",
            dependencies: [
                .target(name: "RxKakaoSDKUser"),
                .product(name: "KakaoSDKFriend", package: "KakaoOpenSDK")
            ],
            exclude: ["Info.plist", "README.md"]
        ),        
        .target(
            name: "RxKakaoSDKShare",
            dependencies: [
                .target(name: "RxKakaoSDKCommon"),
                .product(name: "KakaoSDKShare", package: "KakaoOpenSDK")
            ],
            exclude: ["Info.plist", "README.md"]
        ),

    ],
    swiftLanguageVersions: [
        .v5
    ]
)
