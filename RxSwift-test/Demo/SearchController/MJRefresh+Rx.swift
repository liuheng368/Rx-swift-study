//
//  MJRefresh+Rx.swift
//  RxSwift-test
//
//  Created by Henry on 2020/1/2.
//  Copyright © 2020 刘恒. All rights reserved.
//

import Foundation
import MJRefresh
import RxSwift
import RxCocoa

extension Reactive where Base: UITableView{
    public var footerView: ControlEvent<()> {
        let source: Observable<()> = Observable.create { [weak tableview = self.base] observe in
            MainScheduler.ensureRunningOnMainThread()
            
            guard let tableview = tableview else{
                observe.on(.completed)
                return Disposables.create()
            }
            tableview.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
                observe.on(.next(()))
            })
            
            return Disposables.create {
                tableview.mj_footer = nil
            }
        }
        .takeUntil(deallocated)
        
        return ControlEvent(events: source)
    }
    
    public var headerView: ControlEvent<()> {
        let source: Observable<()> = Observable.create { [weak tableview = self.base] observe in
            MainScheduler.ensureRunningOnMainThread()
            
            guard let tableview = tableview else{
                observe.on(.completed)
                return Disposables.create()
            }
            tableview.mj_header = MJRefreshNormalHeader(refreshingBlock: {
                observe.on(.next(()))
            })
            
            return Disposables.create {
                tableview.mj_header = nil
            }
        }
        .takeUntil(deallocated)
        
        return ControlEvent(events: source)
    }
}
