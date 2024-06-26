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

import RxKakaoSDKCommon

import KakaoSDKCommon
import KakaoSDKAuth

extension AuthApi: ReactiveCompatible {}

/// [카카오 로그인](https://developers.kakao.com/docs/latest/ko/kakaologin/common) 인증 및 토큰 관리 클래스 \
/// Class for the authentication and token management through [Kakao Login](https://developers.kakao.com/docs/latest/en/kakaologin/common)
extension Reactive where Base: AuthApi {
   
    // MARK: Methods
    
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    /// 추가 항목 동의 받기 요청시 인증값으로 사용되는 임시토큰 발급 요청입니다. SDK 내부 전용입니다.
    public func agt() -> Single<String?> {
        return API.rx.responseData(.post, Urls.compose(.Kauth, path:Paths.authAgt),
                                parameters: ["client_id":try! KakaoSDK.shared.appKey(),
                                             "access_token":AUTH.tokenManager.getToken()?.accessToken].filterNil(),
                                sessionType:.Auth)
            .compose(API.rx.checkKAuthErrorComposeTransformer())
            .map({ (response, data) -> String? in
                if let json = (try? JSONSerialization.jsonObject(with:data, options:[])) as? [String: Any] {
                    return json["agt"] as? String
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
    
    /// 인가 코드로 토큰 발급 \
    /// Issues tokens with the authorization code
    public func token(code: String,
                      codeVerifier: String? = nil,
                      redirectUri: String = KakaoSDK.shared.redirectUri()) -> Single<OAuthToken> {
        return API.rx.responseData(.post,
                                Urls.compose(.Kauth, path:Paths.authToken),
                                parameters: ["grant_type":"authorization_code",
                                             "client_id":try! KakaoSDK.shared.appKey(),
                                             "redirect_uri":redirectUri,
                                             "code":code,
                                             "code_verifier":codeVerifier,
                                             "ios_bundle_id":Bundle.main.bundleIdentifier].filterNil(),
                                sessionType:.Auth)
            .compose(API.rx.checkKAuthErrorComposeTransformer())
            .map({ (response, data) -> OAuthToken in
                return try SdkJSONDecoder.custom.decode(OAuthToken.self, from: data)
            })
            .do (
                onNext: { ( decoded ) in
                    SdkLog.i("decoded model:\n \(String(describing: decoded))\n\n" )
                }
            )
            .asSingle()
            .do(onSuccess: { (oauthToken) in
                AUTH.tokenManager.setToken(oauthToken)
            })
    }
    
    /// 토큰 갱신 \
    /// Refreshes the tokens
    public func refreshToken(token oldToken: OAuthToken? = nil) -> Single<OAuthToken> {
        return API.rx.responseData(.post,
                                Urls.compose(.Kauth, path:Paths.authToken),
                                parameters: ["grant_type":"refresh_token",
                                             "client_id":try! KakaoSDK.shared.appKey(),
                                             "refresh_token":oldToken?.refreshToken ?? AUTH.tokenManager.getToken()?.refreshToken,
                                             "ios_bundle_id":Bundle.main.bundleIdentifier].filterNil(),
                                sessionType:.Auth)
            .compose(API.rx.checkKAuthErrorComposeTransformer())
            .map({ (response, data) -> OAuthToken in
                let newToken = try SdkJSONDecoder.custom.decode(Token.self, from: data)
                
                //oauthtoken 객체가 없으면 에러가 나야함.
                guard let oldOAuthToken = oldToken ?? AUTH.tokenManager.getToken() else { throw SdkError(reason: .TokenNotFound) }
                
                var newRefreshToken: String {
                    if let refreshToken = newToken.refreshToken {
                        return refreshToken
                    }
                    else {
                        return oldOAuthToken.refreshToken
                    }
                }
                
                var newRefreshTokenExpiresIn : TimeInterval {
                    if let refreshTokenExpiresIn = newToken.refreshTokenExpiresIn {
                        return refreshTokenExpiresIn
                    }
                    else {
                        return oldOAuthToken.refreshTokenExpiresIn
                    }
                }
                
                let oauthToken = OAuthToken(accessToken: newToken.accessToken,
                                            expiresIn: newToken.expiresIn,
                                            tokenType: newToken.tokenType,
                                            refreshToken: newRefreshToken,
                                            refreshTokenExpiresIn: newRefreshTokenExpiresIn,
                                            scope: newToken.scope,
                                            scopes: newToken.scopes,
                                            idToken: newToken.idToken)
                return oauthToken
            })
            .do (
                onNext: { ( decoded ) in
                    SdkLog.i("decoded model:\n \(String(describing: decoded))\n\n" )
                }
            )
            .asSingle()
            .do(onSuccess: { (oauthToken) in
                AUTH.tokenManager.setToken(oauthToken)
            })
    }
    
    
    @available(*, deprecated, message: "use refreshToken(token:) instead")
    public func refreshAccessToken(refreshToken: String? = nil) -> Single<OAuthToken> {
        return Observable.empty().asSingle()
    }
}


extension Reactive where Base: AuthApi {
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    /// 인가 코드로 토큰과 전자서명 접수번호 발급 \
    /// Issues tokens and ``txId`` with the authorization code
    public func certToken(code: String,
                          codeVerifier: String? = nil,
                          redirectUri: String = KakaoSDK.shared.redirectUri()) -> Single<CertTokenInfo> {
        return API.rx.responseData(.post,
                                Urls.compose(.Kauth, path:Paths.authToken),
                                parameters: ["grant_type":"authorization_code",
                                             "client_id":try! KakaoSDK.shared.appKey(),
                                             "redirect_uri":redirectUri,
                                             "code":code,
                                             "code_verifier":codeVerifier,
                                             "ios_bundle_id":Bundle.main.bundleIdentifier].filterNil(),
                                sessionType:.Auth)
            .compose(API.rx.checkKAuthErrorComposeTransformer())
            .map({ (response, data) -> CertTokenInfo in
                if let certOauthToken = try? SdkJSONDecoder.custom.decode(CertOAuthToken.self, from: data) {
                    let oauthToken = OAuthToken(accessToken: certOauthToken.accessToken,
                                                expiresIn: certOauthToken.expiresIn,
                                                expiredAt: certOauthToken.expiredAt,
                                                tokenType: certOauthToken.tokenType,
                                                refreshToken: certOauthToken.refreshToken,
                                                refreshTokenExpiresIn: certOauthToken.refreshTokenExpiresIn,
                                                refreshTokenExpiredAt: certOauthToken.refreshTokenExpiredAt,
                                                scope: certOauthToken.scope,
                                                scopes: certOauthToken.scopes,
                                                idToken: certOauthToken.idToken)
                    
                    
                    if let txId = certOauthToken.txId {
                        let certTokenInfo = CertTokenInfo(token: oauthToken, txId: txId)
                        return certTokenInfo
                    }
                    else {
                        throw SdkError(reason: .Unknown, message: "certToken - txId is nil.")
                    }
                }
                else {
                    throw SdkError(reason: .Unknown, message: "certToken - token parsing error.")
                }
                
            })
            .do (
                onNext: { ( decoded) in
                    SdkLog.i("decoded model:\n \(String(describing: decoded))\n\n" )
                }
            )
            .asSingle()
            .do(onSuccess: { (certTokenInfo ) in
                AUTH.tokenManager.setToken(certTokenInfo.token)
            })
    }
    
}

extension Reactive where Base: AuthApi {
#if swift(>=5.8)
    @_documentation(visibility: private)
#endif
    public func prepare(certType: CertType,
                        txId: String? = nil,
                        settleId: String? = nil,
                        signData: String? = nil,
                        identifyItems: [IdentifyItem]? = nil) -> Single<String?> {
        
        guard certType != .K3220 else {
            return Single.error(SdkError(reason: .BadParameter, message: "not support k3220"))
        }
        
        if certType == .K2220 {
            guard txId != nil else {
                return Single.error(SdkError(reason: .BadParameter, message: "txId is nil"))
            }
        }
        
        return API.rx.responseData(.post,
                                   Urls.compose(.Kauth, path: Paths.authPrepare),
                                   parameters: [
                                    "client_id": try! KakaoSDK.shared.appKey(),
                                    "cert_type": certType.rawValue,
                                    "tx_id":txId,
                                    "settle_id": settleId,
                                    "sign_data": signData,
                                    "sign_identify_items": identifyItems?.map({ $0.rawValue }).joined(separator: ","),
                                    ].filterNil(),
                                   sessionType: .Auth)
            .compose(API.rx.checkKAuthErrorComposeTransformer())
            .map ({ (response, data) -> String? in
                if let json = (try? JSONSerialization.jsonObject(with:data, options:[])) as? [String: Any] {
                    return json["kauth_tx_id"] as? String
                } else {
                    throw SdkError(reason: .Unknown, message: "prepare - token parsing error.")
                }
            })
            .asSingle()
            .do { (decode) in
                SdkLog.i("decoded model:\n \(String(describing: decode))\n\n")
            }
    }
}
