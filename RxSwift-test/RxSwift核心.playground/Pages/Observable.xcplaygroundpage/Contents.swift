import UIKit
import RxCocoa
import RxSwift

//: [Previous](@previous)
let disposeBag = DisposeBag()
struct ObservableError : Error {}

//: Observable
let observabl = Observable<Int>.create { (observer) -> Disposable in
    observer.onNext(0)
    observer.onNext(1)
    observer.onNext(2)
    observer.onNext(3)
    observer.onNext(4)
    observer.onNext(5)
    observer.onNext(6)
    observer.onNext(7)
    observer.onNext(8)
    observer.onNext(9)
    observer.onCompleted()
    return Disposables.create()
}
observabl.subscribe(onNext: { (i) in
    print("\(i)")
}, onError: { (err) in
    print("\(err)")
}, onCompleted: {
    print("Completed")
}, onDisposed: {
    print("disposed")
}).disposed(by: disposeBag)

//Observable创建
let observable = [Observable<String>.just("A"),
                  Observable<String>.just("B"),
                  Observable<String>.just("C")]
let observable2 = Observable<String>.from(["A", "B", "C"])
let observable3 = Observable<String>.create{observer in
    observer.onNext("A")
    observer.onNext("B")
    observer.onNext("C")
    observer.onCompleted()
    return Disposables.create()
}

let observable4 = Observable<Int>.of(1, 2, 3 ,4 ,5)
let observable5 = Observable.range(start: 1, count: 5)

let observable6 = Observable<String>.empty()

let observable7 = Observable.generate(
    initialState: 0,
    condition: { $0 <= 10 },
    iterate: { $0 + 2 }
)
//主线程一秒触发一次event
let observable8 = Observable<Int>.interval(.second(1), scheduler: MainScheduler.instance)
//主线程5秒后产生唯一一个信号
let observable9 = Observable<Int>.timer(.second(5), scheduler: MainScheduler.instance)
//延时5秒种后，每隔1秒钟发出一个元素
let observable0 = Observable<Int>.timer(.second(5), period: 1, scheduler: MainScheduler.instance)
//test
observable.map { (obe) in
    obe.subscribe({  print($0) })
}

//: >Single 只发出一次信号 ,常用于网络请求
//可以使用asSingle()将普通序列转为single
let single = Single<String>.create { (single) -> Disposable in
    let str = ""
    if str.count >= 0 {
        single(.error(ObservableError()))
    }else{
        single(.success(str))
    }
    return Disposables.create()
}
let singleDis = single.subscribe(onSuccess: { print("Single + \($0)") }, onError: { print($0) })
//手动释放
singleDis.dispose()

//: >Completable 不产生信号传递，只发出成功或结束的信号
let completable = Completable.create { (completable) -> Disposable in
    //    completable(.completed)
    completable(.error(ObservableError()))
    return Disposables.create()
}
completable.subscribe { (event) in
    switch event {
    case .completed:break
    case .error(let err):
        print(err)
    }
}.disposed(by: DisposeBag())//DisposeBag在执行delloc之前会释放当前i订阅

//: >Maybe成功、结束、失败只会发出一个事件
func generateString() -> Maybe<String> {
    return Maybe<String>.create(subscribe: { (maybe) -> Disposable in
        maybe(.success("onNext1"))
        maybe(.success("onNext2"))
        //        maybe(.completed)
        //        maybe(.error(ObservableError()))
        return Disposables.create{ /*事件释放、终止方法*/}
    })
}
// 另一种声明方式.asMaybe()
func generateStringQ() -> Maybe<String> {
    return Observable<String>.create { (observer) -> Disposable in
//        observer.onNext("generateStringQ")
//        observer.onCompleted()
        observer.onError(ObservableError())
        return Disposables.create()
        }.asMaybe().catchErrorJustReturn("123")
}
generateString().subscribe(onSuccess: { print($0) },
                           onError:{ print($0) },
                           onCompleted: { })
generateStringQ().subscribe(onSuccess: { print($0+"success")  },
                            onError:{ print($0) },
                            onCompleted: { })


//: >Signal 事件序列的主线程序列
// 不会为后续订阅者回放之前的状态
let button = UIButton()
let event : Signal<Void> = button.rx.tap.asSignal()
event.emit(onNext: { print("弹出提示框1") })
sleep(5)
event.emit(onNext: { print("弹出提示框2") })


//: >Driver 状态序列的主线程序列,绑定后会回放之前的事件
/*:
 > 任何可监听序列满足3个条件则可以使用Driver
 1. 在主线程监听（UI刷新相关序列）
 2. 不产生error
 3. 这个序列可被共享监听*/
 var results = UITextField().rx.text
        .throttle(0.3, scheduler: MainScheduler.instance)
        .flatMapLatest { query in
            //异步请求fetch。。。。。。
            // 保证在主线程
            .observeOn(MainScheduler.instance)
            // 发生错误，返回空数组
            .catchErrorJustReturn([])}
        // 共享监听，保证只执行一次
        .shareReplay(1)
 results
     .map { "\($0.count)" }
     .bindTo(UILabel().rx.text)
     .addDisposableTo(disposeBag)
 //简化为:
 results = UITextField().rx.text
            // 转换成Driver序列
            .asDriver()
            .throttle(0.3, scheduler: MainScheduler.instance)
            .flatMapLatest { query in
            //异步请求fetch。。。。。。
            // 告诉Driver发生错误怎么办
            .asDriver(onErrorJustReturn: [])}
 results
    .map { "\($0.count)" }
    // 用Driver绑定，不需要切换到主线程
    .drive(UILabel().rx.text)
    .addDisposableTo(disposeBag)

/*: UI控件默认返回的序列类型,并不会回放
> ControlEvent 专门用于描述UI控件所产生的事件
> ControlProperty 专门用于描述UI控件属性的
1. 不会产生 error 事件
2. 一定在 MainScheduler 订阅（主线程订阅）
3. 一定在 MainScheduler 监听（主线程监听）
4. 共享附加作用
*/

//: [Next](@next)
