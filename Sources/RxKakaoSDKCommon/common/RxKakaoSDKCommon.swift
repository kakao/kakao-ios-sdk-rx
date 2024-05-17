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
import KakaoSDKCommon

/// 주요 설정 및 초기화 클래스 \
/// Class for major settings and initializing
///## SeeAlso
///- [초기화](https://developers.kakao.com/docs/latest/ko/ios/getting-started#init) \
///  [Initialize](https://developers.kakao.com/docs/latest/en/ios/getting-started#init)
final public class RxKakaoSDK {
    
    // MARK: Fields
    
    /// Kakao SDK 초기화 \
    /// Initializes Kakao SDK
    /// - parameters:
    ///   - appKey: 앱 키 \
    ///             App key
    ///   - customScheme: 앱별 커스텀 URL 스킴 \
    ///                   Custom URL scheme for each app
    ///   - loggingEnable: Kakao SDK 내부 로그 기능 활성화 여부 \
    ///                    Whether to enable the internal log of the Kakao SDK
    
    public static func initSDK(appKey: String,
                               customScheme: String? = nil,
                               loggingEnable: Bool = false,
                               hosts: Hosts? = nil,
                               approvalType: ApprovalType? = nil,
                               sdkIdentifier: SdkIdentifier? = nil) {
        KakaoSDK.shared.initialize(appKey: appKey,
                                   customScheme: customScheme,
                                   loggingEnable: loggingEnable,
                                   hosts: hosts,
                                   approvalType: approvalType,
                                   sdkIdentifier: sdkIdentifier,
                                   sdkType:.RxSwift)
    }
}
