//
//  RegisterViewModel.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/11/28.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class RegisterService {
    //验证用户名
    func validateUsername(_ username: String) -> Driver<ValidationResult> {
        if username.isEmpty {return .just(.empty)}
        if username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {return .just(.failed(message: "用户名只能包含数字和字母"))}
        return usernameAvailable(username).map { (b) in
            if b {
                return .ok(message: "用户名可用")
            }else{
                return .failed(message: "用户名已存在")
            }
        }.startWith(.validating)
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        if password.count == 0 {return .empty}
        if password.count < 5 {return .ok(message: "密码至少5位")}
        return .ok(message: "密码有效")
    }
    
    func validateRepeatedPassword(_ password: String,_ repeatedPassword: String) ->ValidationResult {
        if repeatedPassword.count == 0 {return .empty}
        if password != repeatedPassword {return .failed(message: "2次密码不一致")}
        return .ok(message: "密码有效")
    }
    
    func usernameAvailable(_ username: String) -> Driver<Bool> {
        return RegisterPro.rx.request(.userNameVer(username))
            .map {$0.statusCode == 404}
            .asDriver(onErrorJustReturn: false)
    }
    
    func singup(_ userN:String,_ pw:String) -> Driver<Bool> {
        return Driver.just(arc4random() % 3 == 0 ? false : true)
            .delay(RxTimeInterval.milliseconds(1500))
    }
    
}

class RegisterViewModel {

    let nameVer:Driver<ValidationResult>
    let passWordVer:Driver<ValidationResult>
    let passWordAgainVer:Driver<ValidationResult>
    let registerVer:Driver<Bool>
    let registerNetWork:Driver<Bool>
    let netWorking:Driver<Bool>

    lazy var server = RegisterService()
    init(nameAction:Driver<String>,
         passWordAction:Driver<String>,
         passWordAgainAction:Driver<String>,
         registerAction:Signal<Void>,
         service:RegisterService) {
        nameVer = nameAction
            .flatMapLatest(service.validateUsername(_:))
        passWordVer = passWordAction
            .map {service.validatePassword($0)}
        passWordAgainVer = Driver.combineLatest(passWordAction,passWordAgainAction)
            .map {service.validateRepeatedPassword($0, $1)}
        registerVer = Driver.combineLatest(nameVer,passWordVer,passWordAgainVer)
            .map { $0.isAble && $1.isAble && $2.isAble}
        
        let activityIndicator = ActivityIndicator()
        netWorking = activityIndicator.asDriver()
        
        
        
        let usernameAndPassword = Driver.combineLatest(nameAction, passWordAction).map{($0,$1)}
        registerNetWork = registerAction
//            .withLatestFrom(usernameAndPassword)
            .flatMap{_ in usernameAndPassword}
            .flatMapLatest { (w,p) in
                return service.singup(w, p)
                    .trackActivity(activityIndicator)
                    .asDriver(onErrorJustReturn: false)
        }
    }
}
