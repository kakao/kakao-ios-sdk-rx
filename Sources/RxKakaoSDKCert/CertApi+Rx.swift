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

import UIKit
import Foundation
import RxSwift

import KakaoSDKCommon
import RxKakaoSDKCommon

import KakaoSDKAuth
import RxKakaoSDKAuth

import KakaoSDKCert

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
@_exported import KakaoSDKCertCore

extension CertApi: ReactiveCompatible {}

/// 카카오 인증서비스 API 클래스 \
/// Class for the Kakao Certification APIs
extension Reactive where Base: CertApi  {
    // MARK: Cert Login

    /// 카카오톡으로 인증 로그인 \
    /// Certification Login with Kakao Talk
    /// - parameters:
    ///   - certType: 상품 종류 \
    ///               Product type
    ///   - launchMethod: 카카오 로그인 시 앱 전환 방식 \
    ///                   Method to switch apps for Kakao Login
    ///   - prompts: 동의 화면에 상호작용 추가 요청 프롬프트 \
    ///              Prompt to add an interaction to the consent screen
    ///   - signData: 서명할 데이터 \
    ///               Data to sign
    ///   - nonce: ID 토큰 재생 공격 방지를 위한 검증 값, 임의의 문자열 \
    ///            Random strings to prevent ID token replay attacks
    ///   - settleId: 정산 ID \
    ///               Settlement ID
    ///   - identifyItems: 확인할 서명자 정보 \
    ///                    Signer information to verifys
    public func certLoginWithKakaoTalk(certType: CertType,
                                       txId: String? = nil,
                                       launchMethod: LaunchMethod? = nil,
                                       prompts: [Prompt]? = nil,
                                       channelPublicIds: [String]? = nil,
                                       serviceTerms: [String]? = nil,
                                       signData: String? = nil,
                                       nonce: String? = nil,
                                       settleId: String? = nil,
                                       identifyItems: [IdentifyItem]? = nil) -> Observable<CertTokenInfo> {
        return AuthApi.shared.rx.prepare(certType: certType, txId: txId, settleId: settleId, signData: signData, identifyItems: identifyItems)
            .asObservable()
            .flatMap({ kauthTxId -> Observable<CertTokenInfo> in
                AuthController.shared.rx._certAuthorizeWithTalk(launchMethod: launchMethod,
                                                                prompts:prompts,
                                                                channelPublicIds: channelPublicIds,
                                                                serviceTerms: serviceTerms,
                                                                nonce: nonce,
                                                                kauthTxId: kauthTxId)
            })
    }
    
    /// 카카오계정으로 인증 로그인 \
    /// Certification Login with Kakao Account
    /// - parameters:
    ///   - certType: 상품 종류 \
    ///               Product type
    ///   - launchMethod: 카카오 로그인 시 앱 전환 방식 \
    ///                   Method to switch apps for Kakao Login
    ///   - prompts: 동의 화면에 상호작용 추가 요청 프롬프트 \
    ///              Prompt to add an interaction to the consent screen
    ///   - loginHint: 카카오계정 로그인 페이지 ID에 자동 입력할 이메일 또는 전화번호, +82 00-0000-0000 형식 \
    ///                Email or phone number in the format +82 00-0000-0000 to fill in the ID field of the Kakao Account login page
    ///   - signData: 서명할 데이터 \
    ///               Data to sign
    ///   - nonce: ID 토큰 재생 공격 방지를 위한 검증 값, 임의의 문자열 \
    ///            Random strings to prevent ID token replay attacks
    ///   - settleId: 정산 ID \
    ///               Settlement ID
    ///   - identifyItems: 확인할 서명자 정보 \
    ///                    Signer information to verify
    public func certLoginWithKakaoAccount(certType: CertType,
                                          txId: String? = nil,
                                          prompts : [Prompt]? = nil,
                                          loginHint: String? = nil,
                                          signData: String? = nil,
                                          nonce: String? = nil,
                                          settleId: String? = nil,
                                          identifyItems: [IdentifyItem]? = nil) -> Observable<CertTokenInfo> {
        return AuthApi.shared.rx.prepare(certType: certType, txId: txId, settleId: settleId, signData: signData, identifyItems: identifyItems)
            .asObservable()
            .flatMap({ kauthTxId -> Observable<CertTokenInfo> in
                AuthController.shared.rx._certAuthorizeWithAuthenticationSession(prompts: prompts,
                                                                                 loginHint:loginHint,
                                                                                 nonce: nonce,
                                                                                 kauthTxId: kauthTxId)
            })
    }
    
    /// 세션 정보 가져오기 \
    /// Retrieve session infomation
    public func sessionInfo(certType:CertType, txId: String) -> Single<SessionInfo> {
        return Observable<SessionInfo>.create { observer in
            CertApi.shared.sessionInfo(certType:certType, txId: txId) { sessionInfo, error in
                if let error = error {
                    observer.onError(error)
                }
                else {
                    if let sessionInfo = sessionInfo {
                        observer.onNext(sessionInfo)
                        observer.onCompleted()
                    }
                    else {
                        observer.onError(SdkError(reason: .Unknown, message: "Unknown Error."))
                    }
                }
            }
            return Disposables.create()
        }
        .asSingle()
    }
    
    /// 축약서명하기 \
    /// Sign for abbreviated signature
    public func reducedSign(certType:CertType, data:String) -> Single<String> {
        return Observable<String>.create { observer in
            CertApi.shared.reducedSign(certType:certType, data: data) { signature, error in
                if let error = error {
                    observer.onError(error)
                }
                else {
                    if let signature = signature {
                        observer.onNext(signature)
                        observer.onCompleted()
                    }
                    else {
                        observer.onError(SdkError(reason: .Unknown, message: "Unknown Error."))
                    }
                }
            }
            return Disposables.create()
        }
        .asSingle()
    }
}

//k3220
extension Reactive where Base: CertApi  {
    /// 세션 정보 가져오기 \
    /// Retrieve session infomation
    public func sessionInfoByAppKey(certType:CertType,
                                    txId: String,
                                    targetAppKey:String? = nil) -> Single<SessionInfo> {
        return Observable<SessionInfo>.create { observer in
            CertApi.shared.sessionInfoByAppKey(certType:certType, txId: txId, targetAppKey: targetAppKey) { sessionInfo, error in
                if let error = error {
                    observer.onError(error)
                }
                else {
                    if let sessionInfo = sessionInfo {
                        observer.onNext(sessionInfo)
                        observer.onCompleted()
                    }
                    else {
                        observer.onError(SdkError(reason: .Unknown, message: "Unknown Error."))
                    }
                }
            }
            return Disposables.create()
        }
        .asSingle()
    }
    
    /// 사용자 서명 요청하기 \
    /// Request user signature
    public func signWithKakaoTalk(certType:CertType,
                                  txId:String,
                                  targetAppKey:String) -> Observable<SignStatusInfo> {
        return Observable<SignStatusInfo>.create { observer in
            CertApi.shared.signWithKakaoTalk(certType:certType, txId: txId, targetAppKey: targetAppKey) { signStatusInfo, error in
                if let error = error {
                    observer.onError(error)
                }
                else {
                    if let signStatusInfo = signStatusInfo {
                        observer.onNext(signStatusInfo)
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
