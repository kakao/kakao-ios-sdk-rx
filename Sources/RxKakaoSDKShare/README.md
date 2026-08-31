# RxKakaoSDKShare

RxSwift를 사용하는 카카오톡 공유 모듈입니다.

## Requirements
- iOS 15.0
- Swift 5.8

## Dependencies
- KakaoSDKShare
- RxKakaoSDKCommon

## Installation
```swift
.package(url: "https://github.com/kakao/kakao-ios-sdk.git", from: "2.0.0")
```
2.x.x 버전을 사용합니다. 타겟의 Dependencies에 `RxKakaoSDKShare`을 추가합니다.

## Import
```
import RxKakaoSDKShare
```

## Usage
[ShareApi](Extensions/Reactive.html) 클래스를 이용하여 각종 카카오톡 공유 API를 호출할 수 있습니다.
```
ShareApi.shared.rx.shareDefault().subscribe()
ShareApi.shared.rx.shareScrap().subscribe()
ShareApi.shared.rx.shareCustom().subscribe()
```
