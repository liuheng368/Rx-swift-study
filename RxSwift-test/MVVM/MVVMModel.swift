//
//  MVVMModel.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/11/27.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import Moya

struct MVVMModel : Codable {
    var total_count: Int
    var incompleteResults: Bool
    var items: [GitHubRepository]
    
    struct GitHubRepository : Codable {
        var id: Int
        var name: String
        var fullName:String
        var htmlUrl:String
        var description:String
    }
}

let GitHubProvider = bdMoyaProvider<MultiTarget>()

class bdMoyaProvider<Target: TargetType>: MoyaProvider<Target> {
    init() {
        super.init(plugins:[DDNetworkLoggerPlugin()])
    }
}


protocol bdTargetType {
    var bdTask: Task { get }
}

enum MVVMApi{
    case repositories(_ content:String)
}

enum vvv  : TargetType {
    case lll
    
    var baseURL: URL {
        return URL(string: "http://bdapi.ndev.imdada.cn")!
    }
    
    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json",
                "User-Id":"9974",
                "Virtual-Id":"25501",
                "User-Token":"hyl",
                "Verification-Hash":"Alan.p"]
    }
    
    var path: String {
        return "/v1/user/findBdByAddress"
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        var a : [[String:Double]] = []
        a.append(["cityId":1,"lat":22.281960,"lng":114.163171])
        let data = try! JSONSerialization.data(withJSONObject: ["addressList":a ], options: .prettyPrinted)
        return .requestCompositeData(bodyData: data, urlParameters: [:])
//        return .requestCompositeParameters(bodyParameters: ["supplierIds":[1,2]], bodyEncoding: URLEncoding.httpBody, urlParameters: [:])
    }
}

extension MVVMApi : TargetType {
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
    
    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
    var path: String {
        switch self {
        case .repositories(_):
            return "/search/repositories"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    
    var task: Task {
        
        switch self {
        case .repositories(let str):
            var params: [String: Any] = [:]
            params["q"] = str
            params["sort"] = "stars"
            params["order"] = "desc"
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.default)
        }
    }
    
}

extension TargetType {
    var whiteList : [String] {
        return []
    }
    
    var timeOut : Int {
        return 30
    }
}



