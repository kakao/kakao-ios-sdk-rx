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
import RxCocoa

import RxAlamofire
import KakaoSDKCommon

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension Api: ReactiveCompatible {}

#if swift(>=5.8)
@_documentation(visibility: private)
#endif
extension Reactive where Base: Api {
    public func decodeDataComposeTransformer<T:Codable>() -> ComposeTransformer<(SdkJSONDecoder, HTTPURLResponse, Data), T> {
        return ComposeTransformer<(SdkJSONDecoder, HTTPURLResponse, Data), T> { (observable) in
            return observable
                .map({ (jsonDecoder, response, data) -> T in
                    return try jsonDecoder.decode(T.self, from: data)
                })
                .do (
                    onNext: { ( decoded ) in
                        SdkLog.i("decoded model:\n \(String(describing: decoded))\n\n" )
                    }
                )
        }
    }
    
    public func checkKApiErrorComposeTransformer() -> ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> {
        return ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> { (observable) in
            return observable
                .map({(response, data) -> (HTTPURLResponse, Data, ApiType) in
                    return (response, data, ApiType.KApi)
                })
                .map({(response, data, apiType) -> (HTTPURLResponse, Data) in
                    if let error = SdkError(response:response, data:data, type:apiType) {
                        SdkLog.e("api error:\n statusCode:\(response.statusCode)\n error:\(error)\n\n")
                        throw error
                    }
                    return (response, data)
                })
        }
    }
    
    public func checkKAuthErrorComposeTransformer() -> ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> {
        return ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> { (observable) in
            return observable
                .map({(response, data) -> (HTTPURLResponse, Data, ApiType) in
                    return (response, data, ApiType.KAuth)
                })
                .map({(response, data, apiType) -> (HTTPURLResponse, Data) in
                if let error = SdkError(response:response, data:data, type:apiType) {
                    SdkLog.e("auth error:\n statusCode:\(response.statusCode)\n error:\(error)\n\n")
                    throw error }
                return (response, data)
            })
        }
    }
    
    public func responseData(_ kHTTPMethod: KHTTPMethod,
                      _ url: String,
                      parameters: [String: Any]? = nil,
                      headers: [String: String]? = nil,
                      sessionType: SessionType = .RxAuthApi) -> Observable<(HTTPURLResponse, Data)> {        
        return API.session(sessionType)
            .rx
            .responseData(Api.httpMethod(kHTTPMethod), url, parameters: parameters, encoding:API.encoding, headers: Api.httpHeaders(headers))
            .do (
                onNext: {
                    let json = (try? JSONSerialization.jsonObject(with:$1, options:[])) as? [String: Any]
                    SdkLog.d("===================================================================================================")
                    SdkLog.i("request: \n method: \(Api.httpMethod(kHTTPMethod))\n url:\(url)\n headers:\(String(describing: headers))\n parameters: \(String(describing: parameters)) \n\n")
                    SdkLog.i("response:\n \(String(describing: json))\n\n" )
                },
                onError: {
                    SdkLog.e("error: \($0)\n\n")
                    },
                onCompleted: {
                    SdkLog.d("== completed\n\n")
        })
    }
    
    public func upload(_ kHTTPMethod: KHTTPMethod,
                       _ url: String,
                       images: [UIImage?] = [],
                       parameters: [String: Any]? = nil,
                       headers: [String: String]? = nil,
                       needsAccessToken: Bool = true,
                       needsKAHeader: Bool = false,
                       sessionType: SessionType = .RxAuthApi) -> Observable<(HTTPURLResponse, Data)> {

        return Observable<(HTTPURLResponse, Data)>.create { observer in
            API.session(sessionType)
                .upload(multipartFormData: { (formData) in
                    images.forEach({ (image) in
                        if let imageData = image?.pngData() {
                            formData.append(imageData, withName: "file", fileName:"image.png",  mimeType: "image/png")
                        }
                        else if let imageData = image?.jpegData(compressionQuality: 1) {
                            formData.append(imageData, withName: "file", fileName:"image.jpg",  mimeType: "image/jpeg")
                        }
                        else {
                        }
                    })
                    parameters?.forEach({ (arg) in
                        guard let data = String(describing: arg.value).data(using: .utf8) else {
                            return
                        }
                        formData.append(data, withName: arg.key)
                    })
                }, to: url, method: Api.httpMethod(kHTTPMethod), headers: Api.httpHeaders(headers))
                .uploadProgress(queue: .main, closure: { (progress) in
                    SdkLog.i("upload progress: \(String(format:"%.2f", 100.0 * progress.fractionCompleted))%")
                })
                .responseData { (response) in
                    if let afError = response.error, let retryError = API.getRequestRetryFailedError(error:afError) {
                        SdkLog.e("response:\n api error: \(retryError)")
                        observer.onError(retryError)
                    }
                    else if let afError = response.error, API.getSdkError(error:afError) == nil {
                        //일반에러
                        SdkLog.e("response:\n not api error: \(afError)")
                        observer.onError(afError)
                    }
                    else if let data = response.data, let response = response.response {
                        observer.onNext((response, data))
                        observer.onCompleted()
                    }
                    else {
                        observer.onError(SdkError(reason: .Unknown, message: "response or data is nil."))
                    }
                }
            
            return Disposables.create()
        }
    }
}
