//
//  RxDataSourceViewController.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/8/22.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class RxDataSourceViewController: UIViewController {

    var searchBar:UISearchBar = UISearchBar(frame: CGRect.zero)
    lazy var tvMain : UITableView = UITableView(frame: self.view.frame, style: .plain)
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tvMain.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        searchBar.frame = CGRect(x: 0, y: 0,
                                 width: self.view.bounds.size.width, height: 56)
        tvMain.tableHeaderView = self.searchBar
        self.view.addSubview(tvMain)
        let randomResult = navigationItem.rx.rightControlEvent("刷新")
            .asObservable()
            .startWith(())
            .flatMapLatest(getRandomResult)
            .flatMap(filterResult)
            .share(replay: 1, scope: .whileConnected)
        
        let dataS = RxTableViewSectionedReloadDataSource<SectionModel<String,Int>> (configureCell: { (dataSource, tv, indexpath, ele) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "cellId")
            cell?.textLabel?.text = "第:\(indexpath.row),\(ele)"
            return cell!
        })
        
        randomResult
            .bind(to: tvMain.rx.items(dataSource: dataS))
            .disposed(by: disposeBag)
        
        tvMain.rx.itemSelected
            .subscribe { (e) in
                print(e.element?.row)
        }
            .disposed(by: disposeBag)
        
        tvMain.rx.itemDeselected
            .subscribe {_ in}
            .disposed(by: disposeBag)
        //设置代理
        tvMain.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func getRandomResult() -> Observable<[SectionModel<String,Int>]>{
        let items = (0...4).map { _ in Int(arc4random()) }
        let observable = Observable.just([SectionModel(model: "qwe", items: items)])
        return observable.delay(DispatchTimeInterval.seconds(2), scheduler: MainScheduler.instance)
    }
    
    func filterResult(data:[SectionModel<String, Int>])
        -> Observable<[SectionModel<String, Int>]> {
            return self.searchBar.rx.text.orEmpty
                .flatMapLatest{
                    query -> Observable<[SectionModel<String, Int>]> in
                    print("正在筛选数据（条件为：\(query)）")
                    //输入条件为空，则直接返回原始数据
                    if query.isEmpty{
                        return Observable.just(data)
                    }else{
                        var newData:[SectionModel<String, Int>] = []
                        for sectionModel in data {
                            let items = sectionModel.items.filter{ "\($0)".contains(query) }
                            newData.append(SectionModel(model: sectionModel.model, items: items))
                        }
                        return Observable.just(newData)
                    }
            }
    }
}

//tableView代理实现
extension RxDataSourceViewController : UITableViewDelegate {
    //设置单元格高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath)
        -> CGFloat {
            if indexPath.row == 0 {
                return 100
            }
            
            return 60
    }
    
}
