//
//  RegisterViewController.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/11/28.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class RegisterViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vm = RegisterViewModel(
            nameAction: tvName.rx.text.orEmpty.asDriver()
                .throttle(RxTimeInterval.milliseconds(500))
                .distinctUntilChanged(),
            passWordAction: tvPassWord.rx.text.orEmpty.asDriver(),
            passWordAgainAction: tvPassWordAgain.rx.text.orEmpty.asDriver(),
            registerAction: btnLogin.rx.tap.asSignal(),
            service: RegisterService())
        
        vm.nameVer.drive(lblName.rx.validationResult).disposed(by: disposeBag)
        vm.passWordVer.drive(lblPassWord.rx.validationResult).disposed(by: disposeBag)
        vm.passWordAgainVer.drive(lblPassWA.rx.validationResult).disposed(by: disposeBag)
        vm.registerVer.drive(btnLogin.rx.isEnabled).disposed(by: disposeBag)
        vm.registerNetWork.drive(onNext: { (b) in
            print("注册\(b ? "成功" : "失败")")
            }).disposed(by: disposeBag)
    }
    
    @IBOutlet weak var tvPassWordAgain: UITextField!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPassWord: UILabel!
    @IBOutlet weak var lblPassWA: UILabel!
    @IBOutlet weak var tvPassWord: UITextField!
    @IBOutlet weak var tvName: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
}

//扩展UILabel
extension Reactive where Base: UILabel {
    //让验证结果（ValidationResult类型）可以绑定到label上
    var validationResult: Binder<ValidationResult> {
        return Binder(base) { label, result in
            label.textColor = result.textColor
            label.text = result.describe
        }
    }
}
