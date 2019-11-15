//
//  DatePickerViewController.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/8/20.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DatePickerViewController: UIViewController {

    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var LBLTIME: UILabel!
    @IBOutlet weak var vPickView: UIDatePicker!
    lazy var dateFor : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter
    }()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        vPickView.rx.date
//            .map { date in
//                "当前选择时间: " + self.dateFor.string(from: date)}
//            .bind(to: LBLTIME.rx.text)
//            .disposed(by: disposeBag)
        
        let leftTime = BehaviorRelay(value: TimeInterval(60))
        let doingStatus = BehaviorRelay(value: false)
        
        DispatchQueue.main.async {
            _ = self.vPickView.rx.countDownDuration <-> leftTime
        }
        btnAction.rx.tap.subscribe { _ in
            doingStatus.accept(true)
            Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
                .takeUntil(doingStatus.asObservable().filter{!$0})
                .subscribe { _ in
                    if leftTime.value <= 0 {
                        doingStatus.accept(false)
                    }
                    leftTime.accept(leftTime.value - 1)
                }.disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
        
        doingStatus
            .map{ !$0 }
            .bind(to: btnAction.rx.isEnabled)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(doingStatus, leftTime) { (d, l) -> String in
            return d ? "倒计时开始，还有 \(Int(l)) 秒..." : "开始"
            }.bind(to: btnAction.rx.title())
            .disposed(by: disposeBag)
        

    }

}
