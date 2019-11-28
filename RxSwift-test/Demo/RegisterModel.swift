//
//  RegisterModel.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/11/28.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import Moya

let RegisterPro = MoyaProvider<RegisterModel>()
enum RegisterModel{
    case userNameVer(_ userName:String)
}

extension RegisterModel: TargetType  {
    var baseURL: URL {
        return URL(string: "https://github.com/")!
    }
    
    var path: String {
        switch self {
        case .userNameVer(let userName):
            return "\(userName)"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
}

enum ValidationResult {
    case validating  //正在验证中
    case empty  //输入为空
    case ok(message: String) //验证通过
    case failed(message: String)  //验证失败
    
    var isAble : Bool {
        switch self {
        case .ok(message: _):
            return true
        default:
            return false
        }
    }
    
    var describe : String {
        switch self {
        case .validating:
            return "正在验证..."
        case .empty:
            return ""
        case let .ok(message):
            return message
        case let .failed(message):
            return message
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .validating:
            return UIColor.gray
        case .empty:
            return UIColor.black
        case .ok:
            return UIColor(red: 0/255, green: 130/255, blue: 0/255, alpha: 1)
        case .failed:
            return UIColor.red
        }
    }
}
