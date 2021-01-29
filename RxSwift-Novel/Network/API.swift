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

enum Domain: String {
    case biquge = "https://www.biquge.info"
    case san7 = "https://www.37zw.net"
}

extension Domain {
    var searchPath: String {
        switch self {
        case .biquge:
            return "/modules/article/search.php?searchkey="
        case .san7:
            return "/s/so.php?type=articlename$s="
        }
    }
}

extension API: TargetType {
    var headers: [String : String]? {
        return nil
    }
    
    var baseURL: URL {
        return URL(string: Domain.biquge.rawValue)!
    }
    
    var path: String {
        switch self {
        case .search(let name):
            let newName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            return Domain.biquge.searchPath + "\(newName)"
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

