//
//  TableViewSimpleViewController.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/8/12.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TableViewSimpleViewController: UIViewController {
    let viewModel = StudentViewModel()
    
    @IBOutlet weak var tvMain: UITableView!
    @IBOutlet weak var lblTimer: UILabel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvMain.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewSimple")
        viewModel.data.bind(to: tvMain.rx.items(cellIdentifier: "TableViewSimple")) { row,model,cell in
            cell.textLabel?.text = model.name
            cell.detailTextLabel?.text = "\(model.age)"
        }.disposed(by: disposeBag)
        
        tvMain.rx.modelSelected(StudentModel.self).subscribe { (model) in
            print(model.element!)
        }.disposed(by: disposeBag)
        
        tvMain.rx.itemSelected.subscribe { index in
            print(index)
        }.disposed(by: disposeBag)

//        print(RxSwift.Resources.total)
        let timerObs = Observable<Int>.interval(.seconds(5), scheduler: MainScheduler.instance)
        //基本方式
        timerObs.map { "当前索引\($0)a" }
            .bind {[unowned self] in
                self.lblTimer.text = $0 }
            .disposed(by: disposeBag)
        //优化方式
        let binder = Binder(lblTimer) { (lab, str) in
            lab.text = str
        }
        timerObs
            .map { "当前索引\($0)b" }
            .bind(to: binder)
            .disposed(by: disposeBag)
        //最优方式
        timerObs
            .map { "当前索引\($0)c" }
            .debug("参数：")
            .bind(to: lblTimer.rx.text)
            .disposed(by: disposeBag)
        //自定义extension
        timerObs
            .bind(to: lblTimer.rx.fontSize)
            .disposed(by: disposeBag)
//        print(RxSwift.Resources.total)
    }
    
    deinit {
        print(#file,#function)
    }
}
