//  Copyright 2019 Kakao Corp.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import Foundation
import RxSwift

import KakaoSDKCommon
import RxKakaoSDKCommon

import KakaoSDKAuth
import RxKakaoSDKAuth

import KakaoSDKFriend

extension PickerApi: ReactiveCompatible {}

/// [피커](https://developers.kakao.com/docs/latest/ko/kakaotalk-social/common) API 클래스 \
/// Class for the [picker](https://developers.kakao.com/docs/latest/en/kakaotalk-social/common) APIs
extension Reactive where Base: PickerApi  {
    
    /// 풀 스크린 형태의 멀티 피커 요청 \
    /// Requests a multi-picker in full-screen view
    /// ## SeeAlso
    /// - [`OpenPickerFriendRequestParams`](https://developers.kakao.com/sdk/reference/ios/release/KakaoSDKFriendCore/documentation/kakaosdkfriendcore/openpickerfriendrequestparams)
    public func selectFriends(params:OpenPickerFriendRequestParams) -> Observable<SelectedUsers> {
        return Observable<SelectedUsers>.create { observer in            
            PickerApi.shared.selectFriends(params: params) { (selectedUsers, error) in
                if let error = error {
                    observer.onError(error)
                }
                else {
                    if let selectedUsers = selectedUsers {
                        observer.onNext(selectedUsers)
                    }
                    else {
                        observer.onError(SdkError(reason: .Unknown, message: "Unknown Error."))
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    /// 팝업 형태의 멀티 피커 요청 \
    /// Requests a multi-picker in pop-up view
    /// ## SeeAlso
    /// - [`OpenPickerFriendRequestParams`](https://developers.kakao.com/sdk/reference/ios/release/KakaoSDKFriendCore/documentation/kakaosdkfriendcore/openpickerfriendrequestparams)
    public func selectFriendsPopup(params:OpenPickerFriendRequestParams) -> Observable<SelectedUsers> {
        return Observable<SelectedUsers>.create { observer in
            PickerApi.shared.selectFriendsPopup(params: params) { (selectedUsers, error) in
                if let error = error {
                    observer.onError(error)
                }
                else {
                    if let selectedUsers = selectedUsers {
                        observer.onNext(selectedUsers)
                    }
                    else {
                        observer.onError(SdkError(reason: .Unknown, message: "Unknown Error."))
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    /// 풀 스크린 형태의 싱글 피커 요청 \
    /// Requests a single picker in full-screen view
    /// ## SeeAlso
    /// - [`OpenPickerFriendRequestParams`](https://developers.kakao.com/sdk/reference/ios/release/KakaoSDKFriendCore/documentation/kakaosdkfriendcore/openpickerfriendrequestparams)
    public func selectFriend(params:OpenPickerFriendRequestParams) -> Observable<SelectedUsers> {
        return Observable<SelectedUsers>.create { observer in
            PickerApi.shared.selectFriend(params: params) { (selectedUsers, error) in
                if let error = error {
                    observer.onError(error)
                }
                else {
                    if let selectedUsers = selectedUsers {
                        observer.onNext(selectedUsers)
                    }
                    else {
                        observer.onError(SdkError(reason: .Unknown, message: "Unknown Error."))
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    /// 팝업 형태의 싱글 피커 요청 \
    /// Requests a single picker in pop-up view
    /// ## SeeAlso
    /// - [`OpenPickerFriendRequestParams`](https://developers.kakao.com/sdk/reference/ios/release/KakaoSDKFriendCore/documentation/kakaosdkfriendcore/openpickerfriendrequestparams)
    public func selectFriendPopup(params:OpenPickerFriendRequestParams) -> Observable<SelectedUsers> {
        return Observable<SelectedUsers>.create { observer in
            PickerApi.shared.selectFriendPopup(params: params) { (selectedUsers, error) in
                if let error = error {
                    observer.onError(error)
                }
                else {
                    if let selectedUsers = selectedUsers {
                        observer.onNext(selectedUsers)
                    }
                    else {
                        observer.onError(SdkError(reason: .Unknown, message: "Unknown Error."))
                    }
                }
            }
            return Disposables.create()
        }
    }
}

