# RxKakaoSDKUser

RxSwift를 사용하는 카카오 로그인 및 사용자 관리 API 모듈입니다.

## Requirements
- Xcode 11.0
- iOS 13.0
- Swift 5.0
- CocoaPods 1.8.0

## Dependencies
- KakaoSDKUser
- RxKakaoSDKAuth

## Installation
```
pod 'RxKakaoSDKUser'
```

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
