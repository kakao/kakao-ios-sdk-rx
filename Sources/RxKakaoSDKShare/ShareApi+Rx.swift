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
import UIKit
import RxSwift

import KakaoSDKCommon
import RxKakaoSDKCommon

import KakaoSDKShare
import KakaoSDKTemplate

extension ShareApi: ReactiveCompatible {}

/// [카카오톡 공유](https://developers.kakao.com/docs/latest/ko/kakaotalk-share/common) API 클래스 \
/// Class for the [Kakao Talk Sharing](https://developers.kakao.com/docs/latest/en/kakaotalk-share/common) APIs
extension Reactive where Base: ShareApi {
    
    // MARK: Fields
    
#if swift(>=5.8)
@_documentation(visibility: private)
#endif
    /// 템플릿 조회 API 응답을 카카오톡 공유 URL로 변환합니다.
    /// ## SeeAlso
    /// - ``SharingResult``
    public func createSharingResultComposeTransformer(targetAppKey:String? = nil) -> ComposeTransformer<(ValidationResult, [String:Any]?), SharingResult> {
        return ComposeTransformer<(ValidationResult, [String:Any]?), SharingResult> { (observable) in
            
            return observable.flatMap { (validationResult, serverCallbackArgs) -> Observable<SharingResult> in
                SdkLog.d("--------------------------------- validationResult \(validationResult)")
                
                return Observable<SharingResult>.create { (observer) in
                    let extraParameters = ["KA":Constants.kaHeader,
                                           "iosBundleId":Bundle.main.bundleIdentifier,
                                           "lcba":serverCallbackArgs?.toJsonString()
                        ].filterNil()
                    
                    let linkParameters = ["appkey" : (targetAppKey != nil) ? targetAppKey! : try! KakaoSDK.shared.appKey(),
                                          "appver" : Constants.appVersion(),
                                          "linkver" : "4.0",
                                          "template_json" : validationResult.templateMsg.toJsonString(),
                                          "template_id" : validationResult.templateId,
                                          "template_args" : validationResult.templateArgs?.toJsonString(),
                                          "extras" : extraParameters?.toJsonString(),
                                          "list": validationResult.schemeParams?["list"],
                                          "limit": validationResult.schemeParams?["limit"]
                        ].filterNil()
                    
                    if let url = SdkUtils.makeUrlWithParameters(Urls.compose(.TalkLink, path:Paths.talkLink), parameters: linkParameters) {
                        SdkLog.d("--------------------------------url \(url)")
                        
                        if ShareApi.isExceededLimit(linkParameters: linkParameters, validationResult: validationResult, extras: extraParameters) {
                            observer.onError(SdkError(reason: .ExceedKakaoLinkSizeLimit))
                        } else {
                            observer.onNext(SharingResult(url: url, warningMsg: validationResult.warningMsg, argumentMsg: validationResult.argumentMsg))
                            observer.onCompleted()
                        }
                    }
                    else {
                        observer.onError(SdkError(reason:.BadParameter, message: "Invalid Url."))
                    }
                    return Disposables.create()
                }
            }
        }
    }
    
    // MARK: Using KakaoTalk
    
    /// 기본 템플릿으로 메시지 발송 \
    /// Send message with default template
    /// - parameters:
    ///   - templateObjectJsonString: 기본 템플릿 객체를 JSON 형식으로 변환한 문자열 \
    ///                               String converted in JSON format from a default template
    ///   - serverCallbackArgs: 카카오톡 공유 전송 성공 알림에 포함할 키와 값 \
    ///                          Keys and values for the Kakao Talk Sharing success callback
    ///   - shareType: 카카오톡 공유 대상 선택 화면 유형 \
    ///                Type of share target selection screen in Kakao Talk.
    ///   - limit: 공유할 대상의 최대 선택 개수 \
    ///            Maximum number of share targets that can be selected.
    func shareDefault(templateObjectJsonString:String?,
                      shareType: ShareType? = nil,
                      limit: Int? = nil,
                      serverCallbackArgs:[String:String]? = nil ) -> Single<SharingResult> {
        return API.rx.responseData(.post,
                                   Urls.compose(path:Paths.shareDefalutValidate),
                                   parameters: ["link_ver":"4.0",
                                                "template_object":templateObjectJsonString,
                                                "scheme_params": ShareApi._createSchemeParams(list: shareType, limit: limit)].filterNil(),
                                   headers: ["Authorization":"KakaoAK \(try! KakaoSDK.shared.appKey())"],
                                   sessionType: .Api
            )
            .compose(API.rx.checkKApiErrorComposeTransformer())
            .map({ (response, data) -> (ValidationResult, [String:Any]?) in
                return (try SdkJSONDecoder.default.decode(ValidationResult.self, from: data), serverCallbackArgs)
            })
            .compose(createSharingResultComposeTransformer())
            .do (
                onNext: { ( decoded ) in
                    SdkLog.i("decoded model:\n \(String(describing: decoded))\n\n" )
                }
            )
            .asSingle()
    }
    
    /// 기본 템플릿으로 메시지 발송 \
    /// Send message with default template
    /// - parameters:
    ///   - templatable: 기본 템플릿으로 변환 가능한 객체 \
    ///                  Object to convert to a default template
    ///   - serverCallbackArgs: 카카오톡 공유 전송 성공 알림에 포함할 키와 값 \
    ///                         Keys and values for the Kakao Talk Sharing success callback
    ///   - shareType: 카카오톡 공유 대상 선택 화면 유형 \
    ///                Type of share target selection screen in Kakao Talk.
    ///   - limit: 공유할 대상의 최대 선택 개수 \
    ///            Maximum number of share targets that can be selected.
    /// ## SeeAlso
    /// - ``Template``
    /// - ``SharingResult``
    public func shareDefault(templatable: Templatable,
                             shareType: ShareType? = nil,
                             limit: Int? = nil,
                             serverCallbackArgs:[String:String]? = nil ) -> Single<SharingResult> {
        return self.shareDefault(templateObjectJsonString: templatable.toJsonObject()?.toJsonString(), shareType: shareType, limit: limit, serverCallbackArgs:serverCallbackArgs)
    }
    
    /// 기본 템플릿으로 메시지 발송 \
    /// Send message with default template
    /// - parameters:
    ///   - templateObject: 기본 템플릿 객체 \
    ///                     Default template object
    ///   - serverCallbackArgs: 카카오톡 공유 전송 성공 알림에 포함할 키와 값 \
    ///                         Keys and values for the Kakao Talk Sharing success callback
    ///   - shareType: 카카오톡 공유 대상 선택 화면 유형 \
    ///                Type of share target selection screen in Kakao Talk.
    ///   - limit: 공유할 대상의 최대 선택 개수 \
    ///            Maximum number of share targets that can be selected.
    /// ## SeeAlso
    /// - ``SharingResult``
    public func shareDefault(templateObject:[String:Any],
                             shareType: ShareType? = nil,
                             limit: Int? = nil,
                             serverCallbackArgs:[String:String]? = nil ) -> Single<SharingResult> {
        return self.shareDefault(templateObjectJsonString: templateObject.toJsonString(), shareType: shareType, limit: limit,serverCallbackArgs:serverCallbackArgs)
    }
    
    /// 스크랩 메시지 발송 \
    /// Send scrape message
    ///  - parameters:
    ///    - requestUrl: 스크랩할 URL \
    ///                  URL to scrape
    ///    - templateId: 사용자 정의 템플릿 ID \
    ///                  Custom template ID
    ///    - templateArgs: 사용자 인자 키와 값 \
    ///                    Keys and values of the user argument
    ///    - serverCallbackArgs: 카카오톡 공유 전송 성공 알림에 포함할 키와 값 \
    ///                          Keys and values for the Kakao Talk Sharing success callback
    ///    - shareType: 카카오톡 공유 대상 선택 화면 유형 \
    ///                 Type of share target selection screen in Kakao Talk.
    ///    - limit: 공유할 대상의 최대 선택 개수 \
    ///             Maximum number of share targets that can be selected.
    /// ## SeeAlso
    /// - ``SharingResult``
    public func shareScrap(requestUrl:String,
                           shareType: ShareType? = nil,
                           limit: Int? = nil,
                           templateId:Int64? = nil,
                           templateArgs:[String:String]? = nil,
                           serverCallbackArgs:[String:String]? = nil ) -> Single<SharingResult> {
        return API.rx.responseData(.post,
                                Urls.compose(path:Paths.shareScrapValidate),
                                parameters: ["link_ver":"4.0",
                                             "request_url":requestUrl,
                                             "template_id":templateId,
                                             "template_args":templateArgs?.toJsonString(),
                                             "scheme_params": ShareApi._createSchemeParams(list: shareType, limit: limit) ].filterNil(),
                                headers: ["Authorization":"KakaoAK \(try! KakaoSDK.shared.appKey())"],
                                sessionType: .Api
            )
            .compose(API.rx.checkKApiErrorComposeTransformer())
            .map({ (response, data) -> (ValidationResult, [String:Any]?) in
                return (try SdkJSONDecoder.default.decode(ValidationResult.self, from: data), serverCallbackArgs)
            })
            .compose(createSharingResultComposeTransformer())
            .do (
                onNext: { ( decoded ) in
                    SdkLog.i("decoded model:\n \(String(describing: decoded))\n\n" )
                }
            )
            .asSingle()
    }
    
    /// 사용자 정의 템플릿으로 메시지 발송 \
    /// Send message with custom template
    /// - parameters:
    ///   - templateId: 사용자 정의 템플릿 ID \
    ///                 Custom template ID
    ///   - templateArgs: 사용자 인자 키와 값 \
    ///                   Keys and values of the user argument
    ///   - serverCallbackArgs: 카카오톡 공유 전송 성공 알림에 포함할 키와 값 \
    ///                         Keys and values for the Kakao Talk Sharing success callback
    ///   - shareType: 카카오톡 공유 대상 선택 화면 유형 \
    ///                Type of share target selection screen in Kakao Talk.
    ///   - limit: 공유할 대상의 최대 선택 개수 \
    ///            Maximum number of share targets that can be selected.
    /// ## SeeAlso
    /// - ``SharingResult``
    public func shareCustom(templateId:Int64,
                            shareType: ShareType? = nil,
                            limit: Int? = nil,
                            templateArgs:[String:String]? = nil,
                            serverCallbackArgs:[String:String]? = nil) -> Single<SharingResult> {
        return API.rx.responseData(.post,
                                Urls.compose(path:Paths.shareCustomValidate),
                                parameters: ["link_ver":"4.0",
                                             "template_id":templateId,
                                             "template_args":templateArgs?.toJsonString(),
                                             "scheme_params": ShareApi._createSchemeParams(list: shareType, limit: limit) ]
                                    .filterNil(),
                                headers: ["Authorization":"KakaoAK \(try! KakaoSDK.shared.appKey())"],
                                sessionType: .Api
            )
            .compose(API.rx.checkKApiErrorComposeTransformer())
            .map({ (response, data) -> (ValidationResult, [String:Any]?) in
                return (try SdkJSONDecoder.default.decode(ValidationResult.self, from: data), serverCallbackArgs)
            })
            .compose(createSharingResultComposeTransformer())
            .do (
                onNext: { ( decoded ) in
                    SdkLog.i("decoded model:\n \(String(describing: decoded))\n\n" )
                }
            )
            .asSingle()
    }
 
    // MARK: Image Upload
    
    /// 이미지 업로드 \
    /// Upload image
    /// - parameters:
    ///   - image: 이미지 파일 \
    ///            Image file
    ///   - secureResource: 이미지 URL을 HTTPS로 설정 \
    ///                     Whether to use HTTPS for the image URL
    public func imageUpload(image: UIImage, secureResource: Bool = true) -> Single<ImageUploadResult> {
        return API.rx.upload(.post, Urls.compose(path:Paths.shareImageUpload),
                          images: [image],
                          parameters: ["secure_resource": secureResource],
                          headers: ["Authorization":"KakaoAK \(try! KakaoSDK.shared.appKey())"],
                          sessionType: .Api)
            .compose(API.rx.checkKApiErrorComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.custom, response, data)
            })
            .compose(API.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
    /// 이미지 스크랩 \
    /// Scrape image
    /// - parameters:
    ///   - imageUrl: 이미지 URL \
    ///               Image URL
    ///   - secureResource: 이미지 URL을 HTTPS로 설정 \
    ///                     Whether to use HTTPS for the image URL
    public func imageScrap(imageUrl: URL, secureResource: Bool = true) -> Single<ImageUploadResult> {
        return API.rx.responseData(.post, Urls.compose(path:Paths.shareImageScrap),
                                parameters: ["image_url": imageUrl.absoluteString, "secure_resource": secureResource],
                                headers: ["Authorization":"KakaoAK \(try! KakaoSDK.shared.appKey())"],
                                sessionType: .Api)
            .compose(API.rx.checkKApiErrorComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.custom, response, data)
            })
            .compose(API.rx.decodeDataComposeTransformer())
            .asSingle()
    }
}
