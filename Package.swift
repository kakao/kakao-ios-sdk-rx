// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

// sdk-version:2.18.0
import PackageDescription

let package = Package(
    name: "RxKakaoOpenSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "RxKakaoSDK",
            targets: ["RxKakaoSDKCommon", "RxKakaoSDKAuth", "RxKakaoSDKUser", "RxKakaoSDKTalk", "RxKakaoSDKFriend", "RxKakaoSDKStory", "RxKakaoSDKShare"]),
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
            name: "RxKakaoSDKTalk",
            targets: ["RxKakaoSDKTalk"]),
        .library(
            name: "RxKakaoSDKFriend",
            targets: ["RxKakaoSDKFriend"]),
        .library(
            name: "RxKakaoSDKStory",
            targets: ["RxKakaoSDKStory"]),
        .library(
            name: "RxKakaoSDKShare",
            targets: ["RxKakaoSDKShare"])
    ],
    dependencies: [
        .package(name: "KakaoOpenSDK",
                 url: "https://github.com/kakao/kakao-ios-sdk.git",
                 .exact("2.18.0")
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
            name: "RxKakaoSDKStory",
            dependencies: [
                .target(name: "RxKakaoSDKUser"),
                .product(name: "KakaoSDKStory", package: "KakaoOpenSDK")
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
