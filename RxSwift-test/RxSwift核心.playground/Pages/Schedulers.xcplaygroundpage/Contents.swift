//: [Previous](@previous)

import Foundation
import RxCocoa
import RxSwift

//:* subscribeOn 可监听序列的构建函数在哪个线程中执行
//:* observeOn 监听所执行的函数在哪个线程中执行


let rxData : Observable<String> = Observable<String>.create { (anyObs) -> Disposable in
    sleep(1)
    anyObs.onNext("subscribeOn-observeOn")
    return Disposables.create()
}
rxData
    .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    .observeOn(MainScheduler.instance)
    .subscribe(onNext: { print($0) })
/*:
 ******
 CurrentThreadScheduler：表示当前线程 Scheduler。（默认使用这个）
 
 1. MainScheduler  代表主线程
 * 如果你需要执行一些和 UI 相关的任务，就需要切换到该 Scheduler 运行。
 
 2. SerialDispatchQueueScheduler 抽象了串行 DispatchQueue
 * 如果你需要执行一些串行任务，可以切换到这个 Scheduler 运行。
 
 3. ConcurrentDispatchQueueScheduler 抽象了并行 DispatchQueue
 * 如果你需要执行一些并发任务，可以切换到这个 Scheduler 运行。
 
 4. OperationQueueScheduler 抽象了 NSOperationQueue
 * 它具备 NSOperationQueue 的一些特点. 例如，你可以通过设置 maxConcurrentOperationCount，来控制同时执行并发任务的最大数量。
 */

//: [Next](@next)
