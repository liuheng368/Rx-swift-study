//: [Previous](@previous)
import Foundation
import UIKit
import RxCocoa
import RxSwift

//: > 监听序列后按一定条件处理事件（闭包）就叫做是观察者
let observer = UIButton().rx.tap.subscribe(onNext: {print("基本观察者")})

//: AnyObserver 可以描述任意观察者,更加符合函数编程思路
let anyObserver : AnyObserver<String?> = AnyObserver { (event) in
    switch event {
    case .next(let str): print(str!)
    case .completed:break
    case .error(let err): print(err)
    }
}
let aObserver = UITextField().rx.text.subscribe(anyObserver)


//: Binder 不会处理错误事件，默认在主线程执行
let lab = UILabel()
let binder : Binder<Bool> = Binder(lab) { (view, bool) in
    view.isHidden = bool
}
UITextField().rx.text.orEmpty
    .map({ $0.count >= 5 })
    .bind(to: binder)

//: [Next](@next)
