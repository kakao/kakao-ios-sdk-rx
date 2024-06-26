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
import KakaoSDKUser

/// [카카오 로그인](https://developers.kakao.com/docs/latest/ko/kakaologin/common)  API 클래스 \
/// Class for the [Kakao Login](https://developers.kakao.com/docs/latest/en/kakaologin/common) APIs
///
extension UserApi: ReactiveCompatible {}

// MARK: Login APIs
extension Reactive where Base: UserApi {
    
    // MARK: Login with KakaoTalk
    
    /// 카카오톡으로 로그인 \
    /// Login with Kakao Talk
    /// - parameters:
    ///   - launchMethod: 카카오 로그인 시 앱 전환 방식 \
    ///                   Method to switch apps for Kakao Login
    ///   - serviceTerms: 동의받을 서비스 약관 태그 목록 \
    ///                   Tags of desired service terms
    ///   - nonce: ID 토큰 재생 공격 방지를 위한 검증 값, 임의의 문자열 \
    ///            A random string to prevent replay attacks
    /// ## SeeAlso
    /// - [카카오톡으로 로그인](https://developers.kakao.com/docs/latest/ko/kakaologin/ios#login-through-kakaotalk) \
    ///   [Login with Kakao Talk](https://developers.kakao.com/docs/latest/en/kakaologin/ios#login-with-kakao-talk)
    public func loginWithKakaoTalk(launchMethod: LaunchMethod? = .UniversalLink,
                                   channelPublicIds: [String]? = nil,
                                   serviceTerms: [String]? = nil,
                                   nonce: String? = nil) -> Observable<OAuthToken> {
        
        return AuthController.shared.rx._authorizeWithTalk(launchMethod: launchMethod,
                                                           channelPublicIds: channelPublicIds,
                                                           serviceTerms: serviceTerms,
                                                           nonce: nonce)
    }
    
    // MARK: Login with Kakao Account
    
    /// 카카오계정으로 로그인 \
    /// Login with Kakao Account
    /// - parameters:
    ///   - prompts: 동의 화면에 상호작용 추가 요청 프롬프트 \
    ///              Prompt to add an interaction to the consent screen
    ///   - loginHint: 카카오계정 로그인 페이지의 ID란에 자동 입력할 값 \
    ///                A value to fill in the ID field of the Kakao Account login page
    ///   - nonce: ID 토큰 재생 공격 방지를 위한 검증 값, 임의의 문자열 \
    ///            A random string to prevent replay attacks
    /// ## SeeAlso
    /// - [카카오계정으로 로그인](https://developers.kakao.com/docs/latest/ko/kakaologin/ios#login-with-kakaoaccount) \
    ///   [Login with Kakao Account](https://developers.kakao.com/docs/latest/en/kakaologin/ios#login-with-kakao-account)
    public func loginWithKakaoAccount(prompts : [Prompt]? = nil,
                                      loginHint: String? = nil,
                                      nonce: String? = nil) -> Observable<OAuthToken> {
        return AuthController.shared.rx._authorizeWithAuthenticationSession(prompts: prompts,
                                                                            loginHint:loginHint,
                                                                            nonce: nonce)
    }
    
    // MARK: New Agreement
    
    /// 추가 항목 동의 받기 \
    /// Request additional consent
    /// - parameters:
    ///   - scopes: 동의항목 ID 목록 \
    ///              List of the scope IDs
    ///   - nonce: ID 토큰 재생 공격 방지를 위한 검증 값, 임의의 문자열 \
    ///            A random string to prevent replay attacks
    public func loginWithKakaoAccount(scopes:[String],nonce: String? = nil) -> Observable<OAuthToken> {
        return AuthController.shared.rx._authorizeByAgtWithAuthenticationSession(scopes:scopes, nonce:nonce)
    }
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    /// 카카오싱크 전용입니다. 자세한 내용은 카카오싱크 전용 개발가이드를 참고하시기 바랍니다.
    public func loginWithKakaoAccount(prompts : [Prompt]? = nil,
                                      channelPublicIds: [String]? = nil,
                                      serviceTerms: [String]? = nil,
                                      nonce: String? = nil) -> Observable<OAuthToken> {
        
        return AuthController.shared.rx._authorizeWithAuthenticationSession(prompts: prompts,
                                                                            channelPublicIds: channelPublicIds,
                                                                            serviceTerms: serviceTerms,
                                                                            nonce: nonce)
    }
}

// MARK: Other APIs
extension Reactive where Base: UserApi {
    /// 연결하기 \
    /// Manual signup
    /// - parameters:
    ///   - properties: 사용자 프로퍼티 \
    ///                 User properties
    public func signup(properties: [String:String]? = nil) -> Single<Int64?> {
        return AUTH_API.rx.responseData(.post, Urls.compose(path:Paths.signup), parameters:["properties": properties?.toJsonString()].filterNil())
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> Int64? in
                if let json = (try? JSONSerialization.jsonObject(with:data, options:[])) as? [String: Any] {
                    return json["id"] as? Int64
                }
                else {
                    return nil
                }
            })
            .do (
                onNext: { ( decoded ) in
                    SdkLog.i("decoded model:\n \(String(describing: decoded))\n\n" )
                }
            )
            .asSingle()
    }
    
    /// 사용자 정보 가져오기 \
    /// Retrieve user information
    /// - parameters:
    ///   - propertyKeys: 사용자 프로퍼티 키 목록 \
    ///                   List of user property keys to retrieve
    ///   - secureResource: 이미지 URL 값 HTTPS 여부 \
    ///                     Whether to use HTTPS for the image URL
    /// ## SeeAlso
    /// - ``User``
    /// - [사용자 정보 가져오기](https://developers.kakao.com/docs/latest/ko/kakaologin/ios#req-user-info) \
    ///   [Retrieve user information](https://developers.kakao.com/docs/latest/en/kakaologin/ios#req-user-info)
    public func me(propertyKeys: [String]? = nil,
                   secureResource: Bool = true) -> Single<User> {        
        return AUTH_API.rx.responseData(.get, Urls.compose(path:Paths.userMe),
                                    parameters: ["property_keys": propertyKeys?.toJsonString(), "secure_resource": secureResource].filterNil())
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.customIso8601Date, response, data)
            })
            .compose(API.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
    /// 사용자 정보 저장하기 \
    /// Store user information
    /// - parameters:
    ///   - properties: 사용자 프로퍼티 \
    ///                 User properties
    /// ## SeeAlso
    /// - ``User.properties``
    public func updateProfile(properties: [String:Any]) -> Completable {
        return AUTH_API.rx.responseData(.post, Urls.compose(path:Paths.userUpdateProfile),
                                 parameters: ["properties": properties.toJsonString()].filterNil())
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .do (
                onNext: { _ in
                    SdkLog.i("completable:\n success\n\n" )
                }
            )
            .ignoreElements()
            .asCompletable()
    }
    
    /// 토큰 정보 보기 \
    /// Retrieve token information
    /// ## SeeAlso
    /// - ``AccessTokenInfo``
    public func accessTokenInfo() -> Single<AccessTokenInfo> {
        return AUTH_API.rx.responseData(.get, Urls.compose(path:Paths.userAccessTokenInfo))
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.custom, response, data)
            })
            .compose(API.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
    /// 로그아웃 \
    /// Logout
    public func logout() -> Completable {
        return AUTH_API.rx.responseData(.post, Urls.compose(path:Paths.userLogout))
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .ignoreElements()
            .asCompletable()
            .do(onError: { (_) in
                ///실패여부와 상관없이 토큰삭제.
                AUTH.tokenManager.deleteToken()
            }, onCompleted:{
                ///실패여부와 상관없이 토큰삭제.
                AUTH.tokenManager.deleteToken()
            })
    }
    
    /// 연결 끊기 \
    /// Unlink
    public func unlink() -> Completable {
        return AUTH_API.rx.responseData(.post, Urls.compose(path:Paths.userUnlink))
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .ignoreElements()
            .asCompletable()
            .do(onCompleted: {
                AUTH.tokenManager.deleteToken()
            })
    }
    
    /// 배송지 가져오기 \
    /// Retrieve shipping address
    /// - parameters:
    ///   - fromUpdatedAt: 이전 페이지의 마지막 배송지 수정 시각, `0` 전달 시 처음부터 조회 \
    ///                    Last shipping address modification on the previous page, retrieve from beginning if passing `0`
    ///   - pageSize: 한 페이지에 포함할 배송지 수(기본값: 10) \
    ///               Number of shipping addresses displayed on a page (Default: 10)
    /// ## SeeAlso
    /// - ``UserShippingAddresses``
    public func shippingAddresses(fromUpdatedAt: Date? = nil, pageSize: Int? = nil) -> Single<UserShippingAddresses> {
        return AUTH_API.rx.responseData(.get, Urls.compose(path:Paths.userShippingAddress),
                                    parameters: ["from_updated_at": fromUpdatedAt?.toSeconds(), "page_size": pageSize].filterNil())
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.customSecondsSince1970, response, data)
            })
            .compose(API.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
    /// 배송지 가져오기 \
    /// Retrieve shipping address
    /// - parameters:
    ///   - addressId : 배송지 ID \
    ///                Shipping address ID
    /// ## SeeAlso
    /// - ``UserShippingAddresses``
    public func shippingAddresses(addressId: Int64) -> Single<UserShippingAddresses> {
        return AUTH_API.rx.responseData(.get, Urls.compose(path:Paths.userShippingAddress),
                                 parameters: ["address_id": addressId].filterNil())
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.customSecondsSince1970, response, data)
            })
            .compose(API.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
    /// 서비스 약관 동의 내역 확인하기 \
    /// Retrieve consent details for service terms
    /// - parameters:
    ///   - result: 조회 대상(`agreed_service_terms`: 사용자가 동의한 서비스 약관 목록 | `app_service_terms`: 앱에 사용 설정된 서비스 약관 목록, 기본값: `agreed_service_terms`) \
    ///             Result type (`agreed_service_terms`: List of service terms the user has agreed to | `app_service_terms`: List of service terms enabled for the app, Default: `agreed_service_terms`)
    ///   - tags: 서비스 약관 태그 목록 \
    ///           Tags of service terms
    /// ## SeeAlso
    /// - ``UserServiceTerms``
    public func serviceTerms(result:String? = nil, tags: [String]? = nil) -> Single<UserServiceTerms> {
        return AUTH_API.rx.responseData(.get, Urls.compose(path:Paths.userServiceTerms),
                                        parameters: ["result": result, "tags": tags?.joined(separator: ",")].filterNil())
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.customIso8601Date, response, data)
            })
            .compose(API.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
    /// 서비스 약관 동의 철회하기 \
    /// Revoke consent for service terms
    /// - parameters:
    ///   - tags: 서비스 약관 태그 목록 \
    ///           Tags of service terms
    public func revokeServiceTerms(tags: [String]) -> Single<UserRevokedServiceTerms> {
        return AUTH_API.rx.responseData(.post, Urls.compose(path: Paths.userRevokeServiceTerms), parameters: ["tags" : tags.joined(separator: ",")].filterNil())
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .map { (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.customIso8601Date, response, data)
            }
            .compose(API.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
    /// 동의 내역 확인하기 \
    /// Retrieve consent details
    /// - parameters:
    ///   - scopes: 동의 항목 ID 목록 \
    ///             List of the scope IDs
    public func scopes(scopes:[String]? = nil) -> Single<ScopeInfo> {
        return AUTH_API.rx.responseData(.get, Urls.compose(path:Paths.userScopes), parameters: ["scopes":scopes?.toJsonString()].filterNil())
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.custom, response, data)
            })
            .compose(API.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
    /// 동의 철회하기 \
    /// Revoke consent
    /// - parameters:
    ///   - scopes: 동의 항목 ID 목록 \
    ///             List of the scope IDs
    public func revokeScopes(scopes:[String]) -> Single<ScopeInfo> {
        return AUTH_API.rx.responseData(.post, Urls.compose(path:Paths.userRevokeScopes), parameters: ["scopes":scopes.toJsonString()].filterNil())
            .compose(AUTH_API.rx.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (SdkJSONDecoder, HTTPURLResponse, Data) in
                return (SdkJSONDecoder.custom, response, data)
            })
            .compose(API.rx.decodeDataComposeTransformer())
            .asSingle()
    }
    
    /// 배송지 선택하기 \
    /// Select shipping address
    public func selectShippingAddress() -> Single<Int64> {
        return Observable<Int64>.create { observer in
            UserApi.shared.selectShippingAddress() { (addressId, error) in
                if let error = error {
                    observer.onError(error)
                } else {                    
                    if let addressId = addressId {
                        observer.onNext(addressId)
                        observer.onCompleted()
                    } else {
                        observer.onError(SdkError(reason: .IllegalState))
                    }
                }
            }
            return Disposables.create()
        }.asSingle()
    }
}
