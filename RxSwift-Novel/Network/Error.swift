//
//  Error.swift
//  RxSwift-Novel
//
//  Created by TrinaSolar on 2020/8/7.
//  Copyright © 2020 yu.qiao. All rights reserved.
//

import Foundation
import Moya

enum NetError: Swift.Error {
    case message(text: String)
}

extension Swift.Error {
    var message: String {
        if self is NetError {
            switch (self as! NetError) {
            case let .message(text):
                return text
            }
        }else if self is MoyaError {
            return (self as! MoyaError).errorDescription ?? ""
        }
        return localizedDescription
    }
}
