# RxKakaoSDKShare

RxSwift를 사용하는 카카오톡 공유 모듈입니다.

## Requirements
- Xcode 11.0
- iOS 13.0
- Swift 5.0
- CocoaPods 1.8.0

## Dependencies
- KakaoSDKShare
- RxKakaoSDKCommon

## Installation
```
pod 'RxKakaoSDKShare'
```

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
