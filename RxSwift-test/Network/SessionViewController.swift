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
import RxAlamofire
import CleanJSON

class SessionViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = btnSimple.rx.tap.subscribe(onNext: { (_) in
            if let url = URL(string: "https://www.douban.com/j/app/radio/channels"){
                let req = URLRequest(url: url)
                _ = requestData(req)
                    .compactMap { (_,data) in try! CleanJSONDecoder().decode(SessionModel.self, from: data) }
                    .subscribe(onNext: { (model) in
                        model.channels.forEach { print($0) }
                    }, onError: { (err) in
                        print("请求失败！错误原因：", err)
                    }, onCompleted: {
                        print("请求完成")
                    }, onDisposed: {
                        print("信号终止")
                    })
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
        
        _ = btnHandle.rx.tap.asObservable()
            .flatMap({ (_) -> Observable<Data> in
                guard let url = URL(string: "https://www.douban.com/j/app/radio/channels") else{return Observable<Data>.empty()}
                let req = URLRequest(url: url)
                return URLSession.shared.rx.data(request: req)
                    .takeUntil(self.btnCanle.rx.tap)
                    .catchError { _ in Observable.empty()}
            })
            .share(replay: 1)
            .subscribe(onNext: {
                data in
                let str = String(data: data, encoding: String.Encoding.utf8)
                print("请求成功！返回的数据是：", str ?? "")
            }, onError: { error in
                //手动取消并不会产生消息
                print("请求失败！错误原因：", error)
            }, onCompleted: {
                print("完成")
            }, onDisposed: {
                print("信号终止")
            }).disposed(by: disposeBag)
        
    }
    
    @IBOutlet weak var btnSimple: UIButton!
    @IBOutlet weak var btnError: UIButton!
    @IBOutlet weak var btnHandle: UIButton!
    @IBOutlet weak var btnCanle: UIButton!
    
}
