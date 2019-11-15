//
//  ButtonViewController.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/8/14.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ButtonViewController: UIViewController {
    let disposeBag = DisposeBag()
    @IBOutlet weak var buuton: UIButton!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var vSwift: UISwitch!
    @IBOutlet weak var vAct: UIActivityIndicatorView!
    @IBOutlet weak var vSlider: UISlider!
    @IBOutlet weak var vStepper: UIStepper!
    override func viewDidLoad() {
        super.viewDidLoad()

        buuton.rx.tap
            .subscribe(onNext: {print("subscribe-按钮被点击")})
            .disposed(by: disposeBag)
        buuton.rx.tap
            .bind {print("bind-按钮被点击")}
            .disposed(by: disposeBag)

        Observable<Int>
            .interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .map{"计数：\($0)"}
//            .bind(to: buuton.rx.title()) 效果相同
            .bind(to: buuton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        let btnArr = [btn1,btn2,btn3].map{$0!}
        let selectedButton = Observable
            .from(btnArr.map{ button in button.rx.tap.map{ button }})
            .merge()
        for btn in btnArr {
            selectedButton
                .map{$0 == btn}
                .bind(to: btn.rx.isSelected)
                .disposed(by: disposeBag)
        }
        
        vSwift.rx.isOn
            .bind(to: vAct.rx.isAnimating)
            .disposed(by: disposeBag)
        vSwift.rx.isOn
            .bind(to: UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .disposed(by: disposeBag)
        
        vSlider.rx.value.subscribe { (f) in
            print(f)
        }.disposed(by: disposeBag)
        vStepper.rx.value.subscribe { (f) in
            print(f)
        }.disposed(by: disposeBag)
        vStepper.rx.value
            .map{Float($0)}
            .bind(to: vSlider.rx.value)
            .disposed(by: disposeBag)
    }


}
