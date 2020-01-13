//
//  BDSuperSearchViewController.swift
//  greatwall
//
//  Created by Henry on 2019/12/30.
//  Copyright © 2019 dada. All rights reserved.
//
//  cell需使用自动高度布局

import UIKit
import RxSwift
import RxCocoa
import Moya
import DDSwiftNetwork
import MJRefresh
class BDSuperSearchViewController<T:Decodable,Cell:UITableViewCell>: UIViewController,UITableViewDelegate {
    
    public typealias updateBlock = (_ text:String)->(Driver<[T]>)
    public typealias nextPageBlock = (_ text:String,_ page:Int)->(Driver<[T]>)
    public typealias cellFactory = (
        cellIdentifier:String,
        factory:(Int, T, Cell)->(Void),
        didSelect:(T)->(Void)
    )
    
    public init(searchUpdateAction: @escaping updateBlock,
         nextPageAction: nextPageBlock? = nil,
         tvFactoryAction : cellFactory)
    {
        self.searchUpdateAction = searchUpdateAction
        self.nextPageAction = nextPageAction
        self.tvFactoryAction = tvFactoryAction
        super.init(nibName: nil, bundle: nil)
        configureSearchController()
        self.historyResponse = {[weak self] () -> BehaviorRelay<[String]> in
            if let arr = self?.userDefaultsManger.getDataFromKeysArchive(placeHolder.value),
                let ar = arr as? [String]{
                return BehaviorRelay<[String]>(value: ar)
            }else{
                return BehaviorRelay<[String]>(value: [])
            }
        }()
    }
    
    public var placeHolder:BehaviorRelay<String> =
        BehaviorRelay(value: "请输入要查询的内容")
    
    public var searchResultsVC : BDSearchResultController {
        searchController!.searchResultsController as! BDSearchResultController
    }
    
    public var searchResultsTableView: UITableView {
        searchResultsVC.tableView
    }

    public var searchBar: UISearchBar {
        searchController.searchBar
    }
    
    /// 单页最大数据量
    public var pageSize : Int = 10
    
    /// 最短输入长度
    public var searchKeyLeast : Int = 2
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let searchUpdateAction: updateBlock
    
    private let nextPageAction: nextPageBlock?
    
    private let tvFactoryAction : cellFactory
    
    private var searchController: UISearchController!
    
    private var currentPage : Int = 1
    private var currentNetworkDis : Disposable?
    let nextPageResponse = BehaviorRelay<[T]>(value: [])
    let updateResponse = BehaviorRelay<[T]>(value: [])
    let disposeBag = DisposeBag()
    
    private lazy var searchResult:[T] = []
    
    private let historyTableView = UITableView(frame: CGRect.zero, style: .plain)
    fileprivate let userDefaultsManger:DataPersistManger = DataPersistManger()
    fileprivate var historyResponse: BehaviorRelay<[String]>!
    
    override func viewDidDisappear(_ animated: Bool) {
        networkCancle()
//        _ = nextPageResponse.takeUntil(rx.deallocated)
//        _ = updateResponse.takeUntil(rx.deallocated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        placeHolder.subscribe(onNext: {[unowned self] (str) in
            self.searchBar.placeholder = str
        }).disposed(by: disposeBag)
        
        //MARK: search Rx
        searchBar.rx.text.orEmpty
            .filter{ $0.count <= 2 }
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else{return}
                self.searchResultsVC.resultState = .LessInput})
            .disposed(by: disposeBag)
        
        //由于代码填入searchbar不会触发didTextChange的代理方法
        //估使用kvo来观察text的变化（text属于lazy在用户输入时并不改变）
        searchBar.rx.observeWeakly(String.self, "text")
            .map{ $0 ?? ""}
            .filter{ $0.count > 2 }
            .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler())
            .map {[weak self] (str) in
                guard let `self` = self else{return}
                self.networkCancle()
                self.searchResultsVC.resultState = .Loading
                self.currentPage = 1
                self.currentNetworkDis = self.searchUpdateAction(str)
                    .asDriver(onErrorJustReturn: [])
                    .map {[weak self] arr -> [T]  in
                        guard let `self` = self else{return []}
                        if arr.count >= self.pageSize {
                            self.searchResultsTableView.mj_footer.isHidden = false
                        }
                        if arr.count <= 0 {
                            self.searchResultsVC.resultState = .NoResult
                        }else{
                            self.searchResultsVC.resultState = .Result
                        }
                        self.searchResult.removeAll()
                        arr.forEach{ self.searchResult.append($0) }
                        return arr}
                    .drive(self.updateResponse)}
            .subscribe(onNext: { () in}).disposed(by: disposeBag)
        
        searchBar.rx.textChange.orEmpty
            .filter{ $0.count > 2 }
            .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler())
            .map {[weak self] (str) in
                guard let `self` = self else{return}
                self.networkCancle()
                self.searchResultsVC.resultState = .Loading
                self.currentPage = 1
                self.currentNetworkDis = self.searchUpdateAction(str)
                    .asDriver(onErrorJustReturn: [])
                    .map {[weak self] arr -> [T]  in
                        guard let `self` = self else{return []}
                        if arr.count >= self.pageSize {
                            self.searchResultsTableView.mj_footer.isHidden = false
                        }
                        if arr.count <= 0 {
                            self.searchResultsVC.resultState = .NoResult
                        }else{
                            self.searchResultsVC.resultState = .Result
                        }
                        self.searchResult.removeAll()
                        arr.forEach{ self.searchResult.append($0) }
                        return arr}
                    .drive(self.updateResponse)}
            .subscribe(onNext: { () in}).disposed(by: disposeBag)
        
        searchBar.rx.textDidBeginEditing.subscribe(onNext: {[unowned self] (_) in
            self.searchBar.showsCancelButton = true
            if #available(iOS 13, *) {
                self.searchBar.subviews.forEach { (vSearchBar) in
                    vSearchBar.subviews.forEach { (vSB) in
                        vSB.subviews.forEach { (v) in
                            if let btn = v as? UIButton {
                                btn.setTitle("取消", for: .normal)
                            }
                        }
                    }
                }
            }else{
                if let btn = self.searchBar.value(forKey: "cancelButton") as? UIButton{
                    btn.setTitle("取消", for: .normal)
                }
            }}).disposed(by: disposeBag)
        
        searchBar.rx.cancelButtonClicked.subscribe(onNext: {[unowned self] (_) in
            self.searchBar.showsCancelButton = false
        }).disposed(by: disposeBag)

        //MARK: nextPage Rx
        if let nextPageAction = nextPageAction {
            searchResultsTableView.rx.footerView
                .throttle(RxTimeInterval.seconds(1), scheduler: MainScheduler())
                .map {[weak self] (str) in
                    guard let `self` = self else{return}
                    self.networkCancle()
                    self.searchResultsVC.resultState = .Loading
                    self.currentPage += 1
                    self.currentNetworkDis = nextPageAction(self.searchBar.text ?? "", self.currentPage)
                            .asDriver(onErrorJustReturn: [])
                            .map {[weak self] arr -> [T]  in
                                guard let `self` = self else{return []}
                                self.searchResultsTableView.mj_footer.endRefreshing()
                                if arr.count < self.pageSize {
                                    self.searchResultsTableView.mj_footer.isHidden = true
                                }
                                arr.forEach{ self.searchResult.append($0) }
                                return arr}
                            .drive(self.nextPageResponse)}
                .subscribe(onNext: { () in}).disposed(by: disposeBag)
        }

        //MARK: tableview Rx
        Observable.merge(updateResponse.asObservable(), nextPageResponse.asObservable())
            .map {[weak self] (_) -> [T] in
                guard let `self` = self else{return []}
                self.currentNetworkDis = nil
                return self.searchResult}
            .bind(to:searchResultsTableView.rx
                .items(cellIdentifier: tvFactoryAction.cellIdentifier, cellType: Cell.self)) {[weak self] (row,data,cell) in
                    self?.tvFactoryAction.factory(row,data,cell)
        }.disposed(by: disposeBag)

        searchResultsTableView.rx
            .modelSelected(T.self).bind(onNext: {[weak self] (model) in
                guard let `self` = self else{return}
                self.tvFactoryAction.didSelect(model)
                //添加历史记录
                if let text = self.searchBar.text {
                    guard let _ = self.historyResponse.value.firstIndex(of: text) else{
                        var arrRecord = self.historyResponse.value
                        arrRecord.insert(text, at: 0)
                        self.historyResponse.accept(arrRecord)
                        return
                    }
                }
            }).disposed(by: disposeBag)
        
        searchResultsTableView.rx.itemDeleted.subscribe(onNext: { (index) in
            print(index)
        }).disposed(by: disposeBag)
        
        
        
        historyTableView.frame = view.frame
        historyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "searchHistoryCellId")
        view.addSubview(historyTableView)
        
        historyResponse
            .map {[weak self] (arr) -> [String] in
                guard let `self` = self else{return arr}
                self.userDefaultsManger.persistWithKeysArchive(arr as AnyObject, key: self.placeHolder.value)
                return arr}
            .bind(to: historyTableView.rx.items(cellIdentifier: "searchHistoryCellId")) {(row,strData,cell) in
                cell.textLabel?.text = strData
                cell.textLabel?.textColor = UIColor.black
                cell.imageView?.image = UIImage(named: "时间排序")
                cell.selectionStyle = .none}.disposed(by: disposeBag)
        
        historyTableView.rx
            .modelSelected(String.self).subscribe(onNext: {[unowned self] (str) in
                self.searchController.isActive = true
                self.searchBar.rx.text.onNext(str)
            }).disposed(by: disposeBag)
        
        historyTableView.rx.setDelegate(self).disposed(by: disposeBag)
    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray
        let lbl = UILabel(frame: CGRect(x: 15.0, y: 5, width: 150, height: 20))
        lbl.text = "搜索历史"
        lbl.textColor = UIColor.black
        lbl.font = UIFont.systemFont(ofSize: 15)
        view.addSubview(lbl)
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.clearHistoryView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    deinit {
        print("deinit:")
    }
}

extension BDSuperSearchViewController {
    fileprivate func configureSearchController() {
        let controller = BDSearchResultController()
        searchController = UISearchController(searchResultsController: controller)
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        searchController.dimsBackgroundDuringPresentation = false
        #if swift(<11.0)
        searchController.hidesNavigationBarDuringPresentation = false
        #endif
        searchBar.autocapitalizationType = .none
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            navigationItem.titleView = searchBar
        }
        definesPresentationContext = true
        extendedLayoutIncludesOpaqueBars = true
        var tf : UITextField
        if #available(iOS 13.0, *) {
            tf = searchBar.searchTextField
        }else{
            tf = searchBar.value(forKey: "_searchField") as! UITextField
        }
        tf.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1)
        tf.layer.cornerRadius = 18
        tf.layer.masksToBounds = true
        tf.font = UIFont.systemFont(ofSize: 14)
        searchBar.sizeToFit()
    }
    
    fileprivate func clearHistoryView()->UIView{
        
        let historyView = UIView(frame: CGRect(x: 0, y: 0, width:UIScreen.main.bounds.width, height: 44))
        historyView.backgroundColor = UIColor.white
        let lbl = UILabel(frame: historyView.bounds)
        lbl.text = "清空搜索历史(\(historyResponse.value.count))"
        lbl.textAlignment = .center
        lbl.textColor = UIColor.blue
        historyView.addSubview(lbl)
        let btn = UIButton(frame: historyView.bounds)
        btn.setTitle("", for: .normal)
        btn.rx.tap.subscribe(onNext: {[unowned self] (_) in
            self.historyResponse.accept([])
            }).disposed(by: disposeBag)
        btn.backgroundColor = UIColor.clear
        historyView.addSubview(btn)
        return historyView
    }
    
    fileprivate func networkCancle() {
        currentNetworkDis?.dispose()
    }
}
