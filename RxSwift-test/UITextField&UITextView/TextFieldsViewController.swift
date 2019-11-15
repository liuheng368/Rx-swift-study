//
//  TextFieldViewController.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/8/14.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TextFieldsViewController: UIViewController {
    let disposeBag = DisposeBag()
    @IBOutlet weak var tfSec: UITextField!
    @IBOutlet weak var tfView: UITextField!
    @IBOutlet weak var lnl: UILabel!
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var textInfo : BehaviorRelay<String?> = BehaviorRelay(value: "1")
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
//        多控件绑定()
//        多控件输入()
//        textFild状态()
//        textView状态()
        双向绑定()
    }

    func 多控件绑定() {
//        print(RxSwift.Resources.total)
        let inputObs = tfView.rx.text.orEmpty.asDriver()
            .throttle(.seconds(1))
        inputObs
            .debug()
            .drive(onNext: { print($0) })
            .disposed(by: disposeBag)
        inputObs
            .drive(self.tfSec.rx.text)
            .disposed(by: disposeBag)
        inputObs
            .map{"当前字数\($0.count)"}
            .drive(self.lnl.rx.text)
            .disposed(by: disposeBag)
        inputObs
            .map { $0.count > 5 }
            .drive(self.btn.rx.isEnabled)
            .disposed(by: disposeBag)
//        print(RxSwift.Resources.total)
    }

    func 多控件输入(){
        Observable.combineLatest(tfView.rx.text.orEmpty, tfSec.rx.text.orEmpty) { (tfView1, tfView2) -> String in
            return "你输入的号码是：\(tfView1)-\(tfView2)"
        }.bind(to: lnl.rx.text)
        .disposed(by: disposeBag)
    }
    
    func textFild状态() {
        tfView.rx.controlEvent([.editingDidBegin])
            .subscribe { (event) in
                print("开始编辑内容!")
        }.disposed(by: disposeBag)
        tfView.rx.controlEvent([.editingChanged])
            .subscribe { (event) in
                print("编辑内容为：\(self.tfView.text!)")
            }.disposed(by: disposeBag)
        tfView.rx.controlEvent([.editingDidEnd])
            .subscribe { (event) in
                print("结束编辑内容!")
            }.disposed(by: disposeBag)
        tfView.rx.controlEvent([.editingDidEndOnExit])
            .subscribe { (event) in
                print("点击Return")
            }.disposed(by: disposeBag)
    }
    
    func textView状态() {
        //开始编辑响应
        textView.rx.text.subscribe({str in
            print("nonMarkedText" + nonMarkedText(self.textView)!)
            print("text" + self.textView.text)
        }).disposed(by: disposeBag)
        textView.rx.didBeginEditing
            .subscribe(onNext: {
                print("开始编辑")
            })
            .disposed(by: disposeBag)
        
        //结束编辑响应
        textView.rx.didEndEditing
            .subscribe(onNext: {
                print("结束编辑")
            })
            .disposed(by: disposeBag)
        
        //内容发生变化响应
        textView.rx.didChange
            .subscribe(onNext: {
                print("内容发生改变")
            })
            .disposed(by: disposeBag)
        
        //选中部分变化响应
        textView.rx.didChangeSelection
            .subscribe(onNext: {
                print("选中部分发生变化")
            })
            .disposed(by: disposeBag)
    }
    
    func 双向绑定() {
        
        (tfView.rx.text <-> textInfo)
            .disposed(by: disposeBag)
        
        textInfo.bind(to: lnl.rx.text)
            .disposed(by: disposeBag)
        
    }
}

