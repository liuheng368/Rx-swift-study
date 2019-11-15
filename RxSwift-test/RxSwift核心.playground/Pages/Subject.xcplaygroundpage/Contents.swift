//: [Previous](@previous)
import Foundation
import UIKit
import RxCocoa
import RxSwift


let disposeBag = DisposeBag()
//: > 某些情况下，对象既是可监听序列，也可以当做观察者

//textFiled用户既可以手动输入，也可以根据其他情况修改text的值
let observable = UITextField().rx.text
observable.subscribe(onNext: { print($0)})
let observer = UITextField().rx.text
UITextField().rx.text.bind(to: observer)


//: AsyncSubject 且只响应完成前的最后一次事件或error事件
let asyncSub = AsyncSubject<String?>() //observable
asyncSub.subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)
asyncSub.onNext("asyncSub：1")
asyncSub.onNext("asyncSub：2")
asyncSub.onNext("asyncSub：3")
asyncSub.onCompleted()

//: piblichSubject 从订阅开始响应所有事件包括error，订阅后不回放（类似：Signal）
let publichSub = PublishSubject<String>()
publichSub
    .subscribe(onNext: { print("publichSub1:\($0)") })
    .disposed(by: disposeBag)
publichSub.onNext("1")
publichSub.onNext("2")
publichSub
    .subscribe(onNext: { print("publichSub2:\($0)") })
    .disposed(by: disposeBag)
publichSub.onNext("一")
publichSub.onNext("二")

//: ReplaySubject 订阅后立即将指定次数的响应事件，订阅后全部回放（类似：Driver）
let replaySubject = ReplaySubject<String>.create(bufferSize: 2)//回放之前2次响应
replaySubject
    .subscribe(onNext: { print("replaySubject1:\($0)") })
    .disposed(by: disposeBag)
replaySubject.onNext("1")
replaySubject.onNext("2")
replaySubject
    .subscribe(onNext: { print("replaySubject2:\($0)") })
    .disposed(by: disposeBag)
replaySubject.onNext("一")
replaySubject.onNext("二")

//: BehaviorSubject 订阅后立即回放一次响应，若一次响应都没有则返回默认值；在error之后订阅只能收到error响应
let behaviorSubject = BehaviorSubject(value: "0")


//: [Next](@next)
