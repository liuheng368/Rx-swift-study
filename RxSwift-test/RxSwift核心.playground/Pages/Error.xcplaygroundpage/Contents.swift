//: [Previous](@previous)
import Foundation
import UIKit
import RxCocoa
import RxSwift

//: > error在RxSwift中表现为：retry、catch

//: retry如果序列发送错误，则重试操作，且最多重试3次。
let rxData : Observable<String> = Observable<String>.create { (anyObs) -> Disposable in
    sleep(1)
    anyObs.onNext("networking")
    return Disposables.create()
}
rxData
    .retry(3)
    .subscribe(onNext: nil, onError: nil)

//: retryWhen如果序列发送错误,则按照一定要求进行一定数量、一段延时后的重新尝试
rxData
    .retryWhen { (rxError:Observable<Error>) -> Observable<Int> in
    //发生错误后延迟3秒后重新，仅着一次重试
    return Observable<Int>.timer(3, scheduler: MainScheduler.instance)}
rxData
    .retryWhen { (rxError:Observable<Error>) -> Observable<Int> in
        //最大重试次数5
        return rxError.flatMapWithIndex({ (err, index) -> Observable<Int> in
            guard index < 5 else{
                return Observable.error(err)
            }
            return Observable.timer(3, scheduler: MainScheduler.instance)
        })}

//: CatchError
//可以在错误产生时，用一个备用元素或者一组备用元素将错误替换掉,然后结束
rxData
    .catchErrorJustReturn("error")
//当遇到 error 事件的时候，就返回指定的Observable,然后结束
let publichSub = PublishSubject<String>()   //异常处理
rxData
    .catchError { _ -> Observable<String> in
    return publichSub
}

//: Result 直接返回error会使序列终止，无法进行重试操作。所以需要将error包装
rxData
    .flatMapLatest { (str) -> Observable<Result<String,Error>> in
        return PublishSubject()
            .map({ Result.success("success") })
            .catchError({ err in Observable.just(Result.failure(err))})
    }
    .subscribe(onNext: { (result) in
        switch result {
        case .success(let str):
            print(str)
        case .failure(let err):
            print(err)
        }
    })


//: [Next](@next)
