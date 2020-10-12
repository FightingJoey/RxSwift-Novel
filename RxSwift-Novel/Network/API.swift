//
//  API.swift
//  RxSwift-Novel
//
//  Created by TrinaSolar on 2020/8/6.
//  Copyright © 2020 yu.qiao. All rights reserved.
//

import Foundation
import Moya

enum API {
    // 搜索
    case search(keyword: String)
    // 页面
    case page(page: String)
}

extension API: TargetType {
    var headers: [String : String]? {
        return nil
    }
    
    var baseURL: URL {
        return URL(string: "https://www.biquge.info")!
    }
    
    var path: String {
        switch self {
        case .search(let name):
            let newName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            return "/modules/article/search.php?searchkey=\(newName)"
        case .page(let page):
            return "\(page)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .search(_), .page(_):
            return .requestPlain
        }
    }

    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
}

