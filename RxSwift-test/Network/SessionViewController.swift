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
        
        _ = btnSimple.rx.tap.subscribe(onNext: {(_) in
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
        
        
    }
    
    @IBOutlet weak var btnSimple: UIButton!
    @IBOutlet weak var btnError: UIButton!
    @IBOutlet weak var btnHandle: UIButton!
    @IBOutlet weak var btnCanle: UIButton!
    
    @IBAction func didPressError(_ sender: Any) {
       if let url = URL(string: "https://www.douban.com/j/xsfsdf/radio/channels"){
           let req = URLRequest(url: url)
           URLSession.shared.rx.data(request: req).subscribe(onNext: { (data) in
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
           }).disposed(by: disposeBag)
       }
    }
    
    @IBAction func didPressHandle(_ sender: Any) {
        if let url = URL(string: "https://www.douban.com/j/xsfsdf/radio/channels"){
            let req = URLRequest(url: url)
            
            
        }
    }
   
    @IBAction func didPressCancle(_ sender: Any) {
        
    }
    
}
