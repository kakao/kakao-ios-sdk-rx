# RxKakaoSDKAuth

RxSwift를 사용하는 사용자 인증 및 토큰 관리 모듈입니다.

## Requirements
- iOS 15.0
- Swift 5.8

## Dependencies
- KakaoSDKAuth
- RxKakaoSDKCommon

## Installation
```swift
.package(url: "https://github.com/kakao/kakao-ios-sdk.git", from: "2.0.0")
```
2.x.x 버전을 사용합니다. 타겟의 Dependencies에 `RxKakaoSDKAuth`을 추가합니다.

## Import
```
import RxKakaoSDKAuth
```

## Usage
[AuthController](Extensions/Reactive.html) 클래스를 이용하여 카카오 로그인을 적용할 수 있습니다.
