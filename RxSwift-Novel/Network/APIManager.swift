//
//  APIManager.swift
//  RxSwift-Novel
//
//  Created by TrinaSolar on 2020/8/6.
//  Copyright © 2020 yu.qiao. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import RxSwift
import HandyJSON
import SwiftyJSON
import Kanna

/// 超时时长
private let requestTimeOut: Double = 30

let network = APIManager<API>.defaultService()

extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    func mapNovelInfo() -> Single<[NovelInfo]> {
        return flatMap { res -> Single<[NovelInfo]> in
            guard let doc = try? HTML(html: res.data, encoding: .utf8) else {
                return Single.create { single in
                    single(.error(NetError.message(text: "HTML解析错误")))
                    return Disposables.create()
                }
            }
            let divs = doc.xpath("//table[@class='grid']").first!.css("tr > td")
            var results = [NovelInfo]()
            for i in 0..<(divs.count / 5) {
                let link = divs[i*6]
                var data = NovelInfo()
                data.title = link.text ?? ""
                data.path = link.css("a").first?["href"] ?? ""
                results.append(data)
            }
            return Single.just(results)
        }
    }
}

// MARK: - 定制 Provider
class APIManager<Target> : MoyaProvider<Target> where Target: TargetType {

    override init(
        endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MoyaProvider<Target>.defaultEndpointMapping,
        requestClosure: @escaping MoyaProvider<Target>.RequestClosure = MoyaProvider<Target>.defaultRequestMapping,
        stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
        callbackQueue: DispatchQueue? = nil,
        session: Session = MoyaProvider<Target>.defaultAlamofireSession(),
        plugins: [PluginType] = [],
        trackInflights: Bool = false)
    {
        super.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, callbackQueue: callbackQueue, session: session, plugins: plugins, trackInflights: trackInflights)
    }
    
    static func defaultService() -> APIManager {
        return APIManager(endpointClosure: APIManager<Target>.defaultEndpoint, requestClosure: APIManager<Target>.defaultRequest, stubClosure: MoyaProvider.neverStub, callbackQueue: nil, session: APIManager<Target>.defaultSession(), plugins: [], trackInflights: false)
    }
}

extension APIManager {
    final class func defaultEndpoint(for target: Target) -> Endpoint {
        /// 这里把endpoint重新构造一遍主要为了解决网络请求地址里面含有? 时无法解析的bug https://github.com/Moya/Moya/issues/1198
        let url = target.baseURL.absoluteString + target.path
        return Endpoint(
            url: url,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }

    final class func defaultRequest(for endpoint: Endpoint, closure: RequestResultClosure) {
        /// 定制 URLRequest 的属性，例如 timeoutInterval 、 cachePolicy 、 httpShouldHandleCookies 等
        do {
            var urlRequest = try endpoint.urlRequest()
            /// 设置超时时间
            urlRequest.timeoutInterval = requestTimeOut
            // 打印请求参数
            if let requestData = urlRequest.httpBody {
                Dlog("\(urlRequest.url!)" + "\n" + "\(urlRequest.httpMethod ?? "")" + "发送参数" + "\(String(data: requestData, encoding: String.Encoding.utf8) ?? "")")
            } else {
                Dlog("\(urlRequest.url!)" + " " + "\(String(describing: urlRequest.httpMethod))")
            }
            closure(.success(urlRequest))
        } catch MoyaError.requestMapping(let url) {
            closure(.failure(MoyaError.requestMapping(url)))
        } catch MoyaError.parameterEncoding(let error) {
            closure(.failure(MoyaError.parameterEncoding(error)))
        } catch {
            closure(.failure(MoyaError.underlying(error, nil)))
        }
    }
    
    final class func defaultSession() -> Session {
        /// 定制 URLSessionConfiguration 的属性，例如 requestCachePolicy 、 timeoutIntervalForRequest 、 httpAdditionalHeaders 、 httpCookieStorage 等
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        
        return Session(configuration: configuration, startRequestsImmediately: false)
    }
}
