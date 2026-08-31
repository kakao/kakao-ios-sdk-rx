# RxKakaoSDKUser

RxSwift를 사용하는 카카오 로그인 및 사용자 관리 API 모듈입니다.

## Requirements
- iOS 15.0
- Swift 5.8

## Dependencies
- KakaoSDKUser
- RxKakaoSDKAuth

## Installation
```swift
.package(url: "https://github.com/kakao/kakao-ios-sdk.git", from: "2.0.0")
```
2.x.x 버전을 사용합니다. 타겟의 Dependencies에 `RxKakaoSDKUser`을 추가합니다.

## Import
```
import RxKakaoSDKUser
```

## Usage
[UserApi](Extensions/Reactive.html) 클래스를 이용하여 각종 사용자관리 API를 호출할 수 있습니다.
```
UserApi.shared.rx.me().subscribe()
UserApi.shared.rx.accessTokenInfo().subscribe()
```
