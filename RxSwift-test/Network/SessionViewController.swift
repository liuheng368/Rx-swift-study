//
//  SessionViewController.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/11/15.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SessionViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = btnSimple.rx.tap.subscribe(onNext: { (_) in
            if let url = URL(string: "https://www.douban.com/j/app/radio/channels"){
                let req = URLRequest(url: url)
                _ = URLSession.shared.rx.response(request: req).subscribe { event in
                    if let ele = event.element {
                        if 200..<300 ~= ele.response.statusCode {
                            if let str = String(bytes: ele.data, encoding: .utf8){
                                print(str)
                            }
                        }else{
                            print("请求失败！")
                        }
                    }
                }
            }
        })
        
        _ = btnError.rx.tap.subscribe(onNext: { (_) in
            if let url = URL(string: "https://www.douban.com/j/xsfsdf/radio/channels"){
                let req = URLRequest(url: url)
                _ = URLSession.shared.rx.data(request: req).subscribe(onNext: { (data) in
                    if let str = String(bytes: data, encoding: .utf8){
                        print(str)
                    }
                }, onError: { (err) in
                    print("err")
                    print(err)
                }, onCompleted: {
                    print("onCompleted")
                }, onDisposed: {
                    print("onDisposed")
                })
            }
        })
        
        _ = btnHandle.rx.tap.asObservable().flatMap({ (_) -> Observable<Data> in
            guard let url = URL(string: "https://github.com/liuheng368/TakeTime.git") else{return Observable<Data>.empty()}
            let req = URLRequest(url: url)
            return URLSession.shared.rx.data(request: req)
                .takeUntil(self.btnCanle.rx.tap)
        }).subscribe(onNext: {
            data in
            let str = String(data: data, encoding: String.Encoding.utf8)
            print("请求成功！返回的数据是：", str ?? "")
        }, onError: { error in
            //手动取消并不会产生消息
            print("请求失败！错误原因：", error)
        }).disposed(by: disposeBag)
        
        
    }
    
    @IBOutlet weak var btnSimple: UIButton!
    @IBOutlet weak var btnError: UIButton!
    @IBOutlet weak var btnHandle: UIButton!
    @IBOutlet weak var btnCanle: UIButton!
    
}
