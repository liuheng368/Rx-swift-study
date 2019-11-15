//
//  UINavigationItem+Extension.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/8/22.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

typealias BarControl = UIBarButtonItem
extension Reactive where Base: UINavigationItem {
    
    public func rightControlEvent(_ barTitle:String) -> ControlEvent<(Void)> {
        let barButtonItem = UIBarButtonItem(title: barTitle, style: .done, target: nil, action: nil)
        self.base.rightBarButtonItem = barButtonItem
        return barButtonItem.rx.tap
        
//        let source: Observable<Void> = Observable.create { observer in
//            MainScheduler.ensureRunningOnMainThread()
//        guard let control = control else {
//            observer.on(.completed)
//            return Disposables.create()
//        }
//            let controlTarget = BarControlTarget(control: barButtonItem) { _ in
//                observer.on(.next(()))
//            }
//
//            return Disposables.create(with: controlTarget.dispose)
//            }
//            .takeUntil(deallocated)
//        return ControlEvent(events: source)
    }
}

final class BarControlTarget {
    typealias Callback = (BarControl) -> Void
    
    let selector: Selector = #selector(BarControlTarget.eventHandler(_:))
    
    weak var control: BarControl?
    var callback: Callback?
    
    init(control: BarControl, callback: @escaping Callback) {
        MainScheduler.ensureRunningOnMainThread()
        
        self.control = control
        self.callback = callback
        control.target = self
        control.action = selector
    }
    
    @objc func eventHandler(_ sender: BarControl!) {
        if let callback = self.callback, let control = self.control {
            callback(control)
        }
    }
    
    func dispose() {
        self.control?.target = nil
        self.control?.action = nil
        self.callback = nil
    }
}
