//
//  TapViewController.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/8/20.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit

class TapViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        点击TAP()
//        滑动Pan()
        向下滑动Ges()
    }
    
    func 点击TAP() {
        let tap = UITapGestureRecognizer()
        self.view.addGestureRecognizer(tap)
        tap.rx.event.subscribe { (event) in
            let point = event.element?.location(in: event.element?.view)
            print(point!)
        }
    }
    
    func 滑动Pan() {
        let tap = UIPanGestureRecognizer()
        self.view.addGestureRecognizer(tap)
        tap.rx.event.subscribe { (event) in
            let point = event.element?.location(in: event.element?.view)
            if let p = point {
                print("滑动Pan\(p)")
            }
        }
    }
    
    func 向下滑动Ges(){
        let tap = UISwipeGestureRecognizer()
        tap.direction = .down
        self.view.addGestureRecognizer(tap)
        tap.rx.event.subscribe { (event) in
            let point = event.element?.location(in: event.element?.view)
            if let p = point {
                print("向下滑动Ges\(p)")
            }
        }
    }
}
