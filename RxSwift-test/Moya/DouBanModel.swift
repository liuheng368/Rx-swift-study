//
//  DouBanModel.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/11/26.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import Moya

let DouBanProvider = MoyaProvider<DoubanModel>()

public enum DoubanModel {
    case channels
    case playList(id:String)
}

extension DoubanModel : TargetType {
    public var baseURL: URL {
        switch self {
        case .channels:
            return URL(string: "https://www.douban.com")!
        case .playList(_):
            return URL(string: "https://douban.fm")!
        }
    }
    
    public var path: String {
        switch self {
        case .channels:
            return "/j/app/radio/channels"
        case .playList(_):
            return "/j/mine/playlist"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var task: Task {
        switch self {
        case .playList(let id):
            var params: [String: Any] = [:]
            params["channel"] = id
            params["type"] = "n"
            params["from"] = "mainsite"
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        default:return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    public var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
}
