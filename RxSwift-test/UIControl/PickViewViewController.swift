//
//  PickViewViewController.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/11/13.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class PickViewViewController: UIViewController {
    //标准样式
    private let stringAdapter = RxPickerViewStringAdapter<[[String]]>(components: [],
                                                                      numberOfComponents: {(_, _, items) -> Int in
                                                                        return items.count},
                                                                    numberOfRowsInComponent: { (_, _, items, section) -> Int in
                                                                        return items[section].count},
                                                                    titleForRow: { (_, _, items, row, section) -> String? in
                                                                        return items[section][row]})
    //自定义样式
    private let customViewAdapter = RxPickerViewViewAdapter<[[String]]>(components: [],
                                                                        numberOfComponents: {(_, _, items) -> Int in
                                                                            return items.count},
                                                                        numberOfRowsInComponent: { (_, _, items, section) -> Int in
                                                                            return items[section].count},
                                                                        viewForRow:{(_,_,items,row,section,view) ->UIView in
                                                                            print(view?.subviews as Any)
                                                                            return view ?? UIView()
    })
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let pv = UIPickerView(frame: view.frame)
        view.addSubview(pv)
        
        Observable.just([["one","two","three"],["first","second","third"]])
            .bind(to: pv.rx.items(adapter: stringAdapter))
            .disposed(by: disposeBag)
        
        let button = UIButton(frame:CGRect(x:0, y:100, width:100, height:30))
        button.backgroundColor = UIColor.blue
        button.setTitle("获取信息",for:.normal)
        button.rx.tap.bind {[weak self] in
            let message = "\(pv.selectedRow(inComponent: 0)) : \(pv.selectedRow(inComponent: 1))"
            let alertController = UIAlertController(title: "被选中的索引为",
                                                    message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            self?.present(alertController, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        self.view.addSubview(button)
    }
    
}
