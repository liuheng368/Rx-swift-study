//: [Previous](@previous)

import Foundation
import RxCocoa
import RxSwift

let disposeBag = DisposeBag()
//: > 和Subjects相似，唯一的区别是不会接受onError或onCompleted这样的终止事件。

//: PublishRelay 就是PublishSubject去掉终止事件(onError,onCompleted)
//订阅后开始响应所有事件，但不包含终止事件
let relay = PublishRelay<String>()
relay
    .subscribe { print("Event:", $0) }
    .disposed(by: disposeBag)   //订阅event
relay.accept("PublishRelay")    //发出event

//: BehaviorRelay  就是BehaviorSubject 去掉终止事件
// 订阅后立即回放一次响应，若一次响应都没有则返回默认值
let behavior = BehaviorRelay(value: "BehaviorRelay-init")

behavior
    .subscribe { print("Event:", $0) }
    .disposed(by: disposeBag)

//behavior.value = "BehaviorRelay-event"
behavior.accept("BehaviorRelay-event")

//: [Next](@next)
