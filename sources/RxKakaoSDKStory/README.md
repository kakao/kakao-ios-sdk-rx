# RxKakaoSDKStory

RxSwift를 사용하는 카카오스토리 API 모듈입니다. 로그인 기반 API를 제공하므로 `RxKakaoSDKAuth` 모듈에 의존합니다.

## Requirements
- Xcode 11.0
- iOS 11.0
- Swift 5.0
- CocoaPods 1.8.0

## Dependencies
- KakaoSDKStory
- RxKakaoSDKUser

## Installation
```
pod 'RxKakaoSDKStory'
```

## Import
```
import RxKakaoSDKStory
```

## Usage
[StoryApi](Extensions/Reactive.html) 클래스를 이용하여 각종 카카오스토리 API를 호출할 수 있습니다.
```
StoryApi.shard.rx.profile().subscribe()
```
