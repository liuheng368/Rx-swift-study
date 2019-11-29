//: [Previous](@previous)

import Foundation
import RxCocoa
import RxSwift

//: Debug 调试操作
//将 debug调试操作符添加到一个链式步骤当中，这样系统就能将所有的订阅者、事件、和处理等详细信息打印出来。
let disposeBag = DisposeBag()
Observable.of("2", "3")
    .debug()
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)

//RxSwift.Resources.total我们可以查看当前RxSwift申请的所有资源数量
print(RxSwift.Resources.total)

// 被merge()过的signal无法再次被merge()后触发

优点:
1,没有做数据与View的绑定，没有做到真正的数据驱动视图
2,对于RxSwift的运用也仅限于网络请求库，RxCocoa的一些优点没有运用到项目
//: [Next](@next)
