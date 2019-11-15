//: [Previous](@previous)
import Foundation
import RxCocoa
import RxSwift

/*:
 > 操作符Operator 创建新的序列、变化原有的序列。
 >>  [更多操作符](https://beeth0ven.github.io/RxSwift-Chinese-Documentation/content/decision_tree.html)
 ******
 ### 1.变换操作符
 #### .buffer()
 缓存新元素,当元素达到某个数量，或者经过了特定的时间，一次性发出event。一个都没则返回空数组[]
 
 #### .window()
 类似buffer，不同的是返回指定N个event，而buffer是返回包装成数组后的一个event
 
 #### .map { } 返回原序列新元素
 可观察队列，变换函数；进行映射处理。返回信号可为任意值：比如输入是String，影射到Bool
 
 #### .flatMap { } 返回新元素的新序列
 每一个元素应用一个转换方法，将他们转换成 Observables，然后将这些 Observables 的元素合并。
 
 #### .flatMapLatest{ }
 仅仅执行最新的信号，当有新的信号来的时候，取消上一次未执行完的整个序列
 
 #### .scan(init)
 序列中每一个event和前一个event进行变换,返回当前序列
 
 ### 2.过滤操作符
 #### .filter {}
 对信号(Element)进行过滤处理。返回信号和输入的信号是同一种类型
 
 #### .distinctUntilChanged()
 该操作符用于过滤掉连续重复的事件.
 
 #### .elementAt(index)
 只处理在index位置的事件，其他事件忽略
 
 #### .take(count)
 只处理count个事件，只针对事件序列
 
 #### .takeLast(count)
 只处理最后count个事件，只针对事件序列
 
 #### .debounce(time)
 time时间内最多响应一个event
 
 #### .throttle(time) 搭配Driver使用
 若time内多次改变，取最后一次
 
 ### 3.条件&布尔操作符
 #### .takeWhile( $0 < 6)
 只响应满足一定条件的event
 
 ### 4.结合操作符
 #### .startWith()
 在Observable序列开始之前插入一些事件元素，也可插入多个事件
 
 #### .merge()
 将两个Observable按原有Event顺序合为一个Observable
 
 #### .zip {}
 将两个Event通过指定方式进行合并。返回信号和输入的信号是同一种类型
 
 #### .combineLatest(){}
 与.merge()类似，不同是需要通过指定方式进行合并
 
 ### 5. 算数&聚合操作符
 #### .toArray()
 把一个序列转成一个数组,并作为一个单一的事件发送
 
 #### .reduce{}
 把一个序列通过指定的方式得到最终的单一结果，且接受一个初始值
 
 ### 6. 连接操作符
 
 ### 7. 其他操作符
 #### .delay(time)
 将所有元素延迟time后在触发
 
 #### .delaySubscription(time)
 将订阅事件延迟time后再进行订阅
 
 #### .timeout(time)
 超过time后就产生一个error
 
 #### .interval(time)
 创建一个Observable每隔一段时间，发出一个索引数
 
 #### .share(replay: 1)
 可多次绑定，且不会创建新的信号
 
 #### .catchErrorJustReturn()
 会将error修饰为一条成功序列
 
 #### .doOn()
 会在每一次事件(event)发送前被调用

 */

//: [Next](@next)
