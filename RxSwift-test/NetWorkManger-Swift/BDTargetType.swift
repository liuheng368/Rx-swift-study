//
//  bdSupTArget.swift
//  DDSwiftNetwork
//
//  Created by Henry on 2019/12/12.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import DDSwiftNetwork

public func CreateTarget(_ t : BDTargetType) -> DDCustomTarget {
    let a = BDCustomTarget(t)
    
    return DDCustomTarget(a)
}

public let NetWorker = DDMoyaProvider().rx

public protocol BDTargetType {

    /// 请求路径
    var path: String { get }

    /// 请求体
    var task: DDTask { get }
    
    /// 请求弹框文案
    var HUDString : String { get }
    
    /// 请求根路径
    var baseURLString : String {get}
}

extension BDTargetType {
    var HUDString: String { return "" }
    
    var baseURLString : String { return "" }
}

public enum BDCustomTarget: DDTargetType {
    
    /// The embedded `TargetType`.
    case target(BDTargetType)
    
    public init(_ target: BDTargetType) {
        self = BDCustomTarget.target(target)
    }
    
    /// The embedded `TargetType`.
    public var target: BDTargetType {
        switch self {
        case .target(let target): return target
        }
    }
    
    public var loginOutTime: () -> Void {
        return {
            DDShowHUD.error(title: "登录超时，请重新登录", duration: 2).show()
        }
    }
    
    public var whiteList: [String] {
        return ["/v1/log/coordinator",
                "/v1/message/unread/count",
                "/v1_0/push/bind",
                "/v1_0/push/unbind",
                "/v1/waitdo/list",
                "/v1/statistics/todo",
                "/v1/track/savelist",
                "/v1/track/list"]
    }
    
    public var timeOut: Int {
        return 30
    }

    /// The baseURL of the embedded target.
    public var baseURL: URL {
        URL(string: target.baseURLString)!
    }

    /// The headers of the embedded target.
    public var headers: [String: String]? {
        return [:]
    }
    
    public var bLmitate: Bool {
        return false
    }
    
    /// The `Task` of the embedded target.
    public var task: DDTask {
        return target.task
    }
    
    /// The embedded target's base `URL`.
    public var path: String {
        return target.path
    }
    
    public var HUDString: String {
        return target.HUDString
    }
}
