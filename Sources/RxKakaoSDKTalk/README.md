# RxKakaoSDKTalk

RxSwift를 사용하는 카카오톡 API 모듈입니다.

## Requirements
- iOS 15.0
- Swift 5.8

## Dependencies
- KakaoSDKTalk
- RxKakaoSDKUser

## Installation
```swift
.package(url: "https://github.com/kakao/kakao-ios-sdk.git", from: "2.0.0")
```
2.x.x 버전을 사용합니다. 타겟의 Dependencies에 `RxKakaoSDKTalk`을 추가합니다.

## Import
```
import RxKakaoSDKTalk
```

## Usage
[TalkApi](Extensions/Reactive.html) 클래스를 이용하여 각종 카카오톡 API를 호출할 수 있습니다.
```
TalkApi.shared.rx.profile().subscribe()
TalkApi.shared.rx.friends().subscribe()
```
