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
    case img
}
//https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1576595174694&di=9029613759c8b851d5561d967da5f664&imgtype=0&src=http%3A%2F%2F00.minipic.eastday.com%2F20161222%2F20161222195407_66e9861db58f43ca5d9a53437a400105_3.jpeg
extension DoubanModel : TargetType {
    public var baseURL: URL {
        switch self {
        case .channels:
            return URL(string: "https://www.douban.com")!
        case .playList(_):
            return URL(string: "https://douban.fm")!
        case .img:
            return URL(string: "https://github.com/liuheng368/SwiftNetwork_Henry.git")!
        }
    }
    
    public var path: String {
        switch self {
        case .channels:
            return "/j/app/radio/channels"
        case .playList(_):
            return "/j/mine/playlist"
        case .img:
            return ""
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

struct ChannelModel : Codable {
    var song: [Song]
    
    struct Song: Codable {
        var title: String
        var artist:String
    }
}
