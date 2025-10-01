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

import KakaoSDKTalk
import KakaoSDKTemplate
import UIKit

extension TalkApi: ReactiveCompatible {}

/// [카카오톡 채널](https://developers.kakao.com/docs/latest/ko/kakaotalk-channel/common), [카카오톡 소셜](https://developers.kakao.com/docs/latest/ko/kakaotalk-social/common), [카카오톡 메시지](https://developers.kakao.com/docs/latest/ko/kakaotalk-message/common) API 클래스 \
/// Class for the [Kakao Talk Channel](https://developers.kakao.com/docs/latest/en/kakaotalk-channel/common), [Kakao Talk Social](https://developers.kakao.com/docs/latest/en/kakaotalk-social/common), [Kakao Talk Message](https://developers.kakao.com/docs/latest/en/kakaotalk-message/common) APIs
extension Reactive where Base: TalkApi {
   
    // MARK: Profile
    
    /// 카카오톡 프로필 조회 \
    /// Retrieve Kakao Talk profile
    /// ## SeeAlso
    /// - ``TalkProfile``
    /// - [프로필 조회](https://developers.kakao.com/docs/latest/ko/kakaotalk-social/ios#get-profile) \
    ///   [Retrieve Kakao Talk profile](https://developers.kakao.com/docs/latest/en/kakaotalk-social/ios#get-profile)
    public func profile() -> Single<TalkProfile> {
        return AUTH_API.rx.responseData(.get, Urls.compose(path:Paths.talkProfile))
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.custom, response, data)
            })
            .compose(API.rx.decodeDataComposeTransformer())
            
//            .map({ (response, data) -> TalkProfile in
//                return try SdkJSONDecoder.custom.decode(TalkProfile.self, from: data)
//            })
            .asSingle()
    }
    
    // MARK: Memo

    /// 나에게 사용자 정의 템플릿으로 메시지 발송 \
    /// Send message with custom template to me
    /// - parameters:
    ///    - templateId: 메시지 템플릿 ID \
    ///                  Message template ID
    ///    - templateArgs: 사용자 인자 \
    ///                    User arguments
    public func sendCustomMemo(templateId: Int64, templateArgs: [String:String]? = nil) -> Completable {
        return AUTH_API.rx.responseData(.post, Urls.compose(path:Paths.customMemo), parameters: ["template_id":templateId, "template_args":templateArgs?.toJsonString()].filterNil())
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .do (
                onNext: { _ in
                    SdkLog.i("completable:\n success\n\n" )
                }
            )
            .ignoreElements()
            .asCompletable()
    }

    /// 나에게 기본 템플릿으로 메시지 발송 \
    /// Send message with default template to me
    /// - parameters:
    ///    - templatable: 메시지 템플릿 객체 \
    ///                   An object of a message template
    /// ## SeeAlso
    /// - [`Templatable`](https://developers.kakao.com/sdk/reference/ios/release/KakaoSDKTemplate/documentation/kakaosdktemplate/templatable)
    public func sendDefaultMemo(templatable: Templatable) -> Completable {
        return AUTH_API.rx.responseData(.post, Urls.compose(path:Paths.defaultMemo), parameters: ["template_object":templatable.toJsonObject()?.toJsonString()].filterNil())
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .do (
                onNext: { _ in
                    SdkLog.i("completable:\n success\n\n" )
                }
            )
            .ignoreElements()
            .asCompletable()
    }
    
//    public func defaultMemo(templateObject: [String:Any]) -> Completable {
//        return self.responseData(.post, Urls.defaultMemo, parameters: ["template_object":templateObject.toJsonString()].filterNil())
//            .compose(composeTransformerCheckApiErrorForKApi)
//            .ignoreElements()
//    }

    /// 나에게 스크랩 메시지 발송 \
    /// Send scrape message to me
    ///  - parameters:
    ///     - requestUrl: 스크랩할 URL \
    ///                   URL to scrape
    ///     - templateId: 메시지 템플릿 ID \
    ///                   Message template ID
    ///     - templateArgs: 사용자 인자 \
    ///                     User arguments
    public func sendScrapMemo(requestUrl: String, templateId: Int64? = nil, templateArgs: [String:String]? = nil) -> Completable {
        return AUTH_API.rx.responseData(.post, Urls.compose(path:Paths.scrapMemo), parameters: ["request_url":requestUrl,"template_id":templateId, "template_args":templateArgs?.toJsonString()].filterNil())
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .do (
                onNext: { _ in
                    SdkLog.i("completable:\n success\n\n" )
                }
            )
            .ignoreElements()
            .asCompletable()
    }
    
    
    // MARK: Friends
    
    /// 친구 목록 조회 \
    /// Retrieve list of friends
    /// - parameters:
    ///   - offset: 친구 목록 시작 지점 \
    ///             Start point of the friend list
    ///   - limit: 페이지당 결과 수 \
    ///            Number of results in a page
    ///   - order: 정렬 방식 \
    ///            Sorting method
    ///   - friendOrder: 친구 정렬 방식 \
    ///                  Method to sort the friend list
    /// ## SeeAlso
    /// - ``Friends``
    public func friends(offset: Int? = nil,
                        limit: Int? = nil,
                        order: Order? = nil,
                        friendOrder: FriendOrder? = nil) -> Single<Friends<Friend>> {
        return AUTH_API.rx.responseData(.get, Urls.compose(path:Paths.friends), parameters: ["offset": offset,
                                                                                         "limit": limit,
                                                                                         "order": order?.rawValue,
                                                                                         "friend_order": friendOrder?.rawValue].filterNil())
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.custom, response, data)
            })
            .compose(API.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
    
    // MARK: Message
    
    /// 친구에게 기본 템플릿으로 메시지 발송 \
    /// Send message with default template to friends
    ///  - parameters:
    ///     - templatable: 메시지 템플릿 객체 \
    ///                    An object of a message template
    ///     - receiverUuids: 수신자 UUID \
    ///                      Receiver UUIDs
    /// ## SeeAlso
    /// - [`Templatable`](https://developers.kakao.com/sdk/reference/ios/release/KakaoSDKTemplate/documentation/kakaosdktemplate/templatable)
    /// - ``MessageSendResult``
    public func sendDefaultMessage(templatable:Templatable, receiverUuids:[String]) -> Single<MessageSendResult> {
        return AUTH_API.rx.responseData(.post,
                                 Urls.compose(path:Paths.defaultMessage),
                                 parameters: ["template_object":templatable.toJsonObject()?.toJsonString(), "receiver_uuids":receiverUuids.toJsonString()].filterNil())
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.custom, response, data)
            })
            .compose(API.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
//    public func sendDefaultMessage(templateObject:[String:Any], receiverUuids:[String]) -> Single<MessageSendResult> {
//        return self.responseData(.post, Urls.defaultMessage, parameters: ["template_object":templateObject.toJsonString(), "receiver_uuids":receiverUuids.toJsonString()].filterNil())
//            .compose(composeTransformerCheckApiErrorForKApi)
//            .map({ (response, data) -> MessageSendResult in
//                return try SdkJSONDecoder.custom.decode(MessageSendResult.self, from: data)
//            })
//            .asSingle()
//    }
    
    /// 친구에게 사용자 정의 템플릿으로 메시지 발송 \
    /// Send message with custom template
    /// - parameters:
    ///    - templateId: 메시지 템플릿 ID \
    ///                  Message template ID
    ///    - templateArgs: 사용자 인자 \
    ///                    User arguments
    ///    - receiverUuids: 수신자 UUID \
    ///                     Receiver UUIDs
    /// ## SeeAlso
    /// - ``MessageSendResult``
    public func sendCustomMessage(templateId: Int64, templateArgs:[String:String]? = nil, receiverUuids:[String]) -> Single<MessageSendResult> {
        return AUTH_API.rx.responseData(.post, Urls.compose(path:Paths.customMessage), parameters: ["receiver_uuids":receiverUuids.toJsonString(), "template_id":templateId, "template_args":templateArgs?.toJsonString()].filterNil())
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.custom, response, data)
            })
            .compose(API.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
    /// 친구에게 스크랩 메시지 발송 \
    /// Send scrape message to friends
    /// - parameters:
    ///    - requestUrl: 스크랩할 URL \
    ///                   URL to scrape
    ///    - templateId: 메시지 템플릿 ID \
    ///                  Message template ID
    ///    - templateArgs: 사용자 인자 \
    ///                    User arguments
    ///    - receiverUuids: 수신자 UUID \
    ///                     Receiver UUIDs
    /// ## SeeAlso
    /// - ``MessageSendResult``
    public func sendScrapMessage(requestUrl: String, templateId: Int64? = nil, templateArgs:[String:String]? = nil, receiverUuids:[String]) -> Single<MessageSendResult> {
        return AUTH_API.rx.responseData(.post, Urls.compose(path:Paths.scrapMessage),
                                        parameters: ["receiver_uuids":receiverUuids.toJsonString(), "request_url": requestUrl, "template_id":templateId, "template_args":templateArgs?.toJsonString()].filterNil())
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.custom, response, data)
            })
            .compose(API.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
    
    // MARK: Kakaotalk Channel
    
    /// 카카오톡 채널 관계 조회 \
    /// Check Kakao Talk Channel relationship
    /// - parameters:
    ///    - publicIds: 카카오톡 채널 프로필 ID 목록 \
    ///                 A list of Kakao Talk Channel profile IDs
    /// ## SeeAlso
    /// - ``Channel``
    public func channels(publicIds: [String]? = nil) -> Single<Channels> {
        return AUTH_API.rx.responseData(.get, Urls.compose(path:Paths.channels),
                                    parameters: ["channel_public_ids":publicIds?.toJsonString()].filterNil())
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.customIso8601Date, response, data)
            })
            .compose(API.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
    private func validateChannel(validatePathUri: String, channelPublicId: String) -> Observable<(HTTPURLResponse, Data)> {
        return API.rx.responseData(.post, Urls.compose(path: Paths.channelValidate),
                                   parameters: ["quota_properties": ["uri": validatePathUri, "channel_public_id": channelPublicId].toJsonString()].filterNil(),
                                   headers: ["Authorization": "KakaoAK \(try! KakaoSDK.shared.appKey())"],
                                   sessionType: .Api)
        .compose(API.rx.checkKApiErrorComposeTransformer())
    }

    /// 카카오톡 채널 친구 추가 \
    /// Add Kakao Talk Channel
    /// - parameters:
    ///    - channelPublicId: 카카오톡 채널 프로필 ID \
    ///                       Kakao Talk Channel profile ID
    public func addChannel(channelPublicId: String) -> Completable {
        return Observable.from {
            if !TalkApi.isKakaoTalkChannelAvailable(path: "plusfriend/home/\(channelPublicId)/add") {
                throw SdkError(reason: .IllegalState, message: "KakaoTalk is not available")
            }
            return validateChannel(validatePathUri: "/sdk/channel/add", channelPublicId: channelPublicId)
        }
        .ignoreElements()
        .asCompletable()
        .do(onCompleted: {
            UIApplication.shared.open(URL(string: Urls.compose(.PlusFriend, path: "plusfriend/home/\(channelPublicId)/add"))!)
        })
    }
    
    /// 카카오톡 채널 채팅 \
    /// Start Kakao Talk Channel chat
    /// - parameters:
    ///    - channelPublicId: 카카오톡 채널 프로필 ID \
    ///                       Kakao Talk Channel profile ID
    public func chatChannel(channelPublicId: String) -> Completable {
        return Observable.from {
            if !TalkApi.isKakaoTalkChannelAvailable(path: "plusfriend/talk/chat/\(channelPublicId)") {
                throw SdkError(reason: .IllegalState, message: "KakaoTalk is not available")
            }
            
            return validateChannel(validatePathUri: "/sdk/channel/chat", channelPublicId: channelPublicId)
        }
        .ignoreElements()
        .asCompletable()
        .do(onCompleted: {
            UIApplication.shared.open(URL(string: Urls.compose(.PlusFriend, path: "plusfriend/talk/chat/\(channelPublicId)"))!)
        })
    }
    
    /// 카카오톡 채널 간편 추가 \
    /// Follow Kakao Talk Channel
    /// - parameters:
    ///    - channelPublicId: 카카오톡 채널 프로필 ID \
    ///                       Kakao Talk Channel's profile ID
    public func followChannel(channelPublicId: String) -> Single<FollowChannelResult> {
        return Observable<FollowChannelResult>.create { observer in
            TalkApi.shared.followChannel(channelPublicId: channelPublicId, completion: { followChannelResult, error in
                if let error = error {
                    observer.onError(error)
                }
                else {
                    if let followChannelResult = followChannelResult {
                        observer.onNext(followChannelResult)
                        observer.onCompleted()
                    }
                    else {
                        observer.onError(SdkError(reason: .IllegalState))
                    }
                }
            })
            return Disposables.create()
        }
        .asSingle()
    }
}
