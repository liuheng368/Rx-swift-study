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
class BDSuperSearchViewController<T:Decodable,Cell:UITableViewCell>: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
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
    private var nextPageNetworkDis : Disposable?
    let nextPageResponse = BehaviorRelay<[T]>(value: [])
    let updateResponse = BehaviorRelay<[T]>(value: [])
    let disposeBag = DisposeBag()
    private lazy var searchResult:[T] = []
    
    private let historyTableView = UITableView(frame: CGRect.zero, style: .plain)
    fileprivate var arrHistory : [String] = []
    override func viewDidDisappear(_ animated: Bool) {
        currentNetworkDis?.dispose()
        nextPageNetworkDis?.dispose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        searchBar.rx.text.orEmpty
            .filter{ $0.count <= 2 }
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else{return}
                self.searchResultsVC.resultState = .LessInput})
            .disposed(by: disposeBag)
        
        searchBar.rx.text.orEmpty
            .filter{ $0.count > 2 }
            .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler())
            .distinctUntilChanged()
            .map {[weak self] (str) in
                guard let `self` = self else{return}
                if let _ = self.currentNetworkDis {
                    self.currentNetworkDis?.dispose()
                }
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
 
        if let nextPageAction = nextPageAction {
            searchResultsTableView.rx.footerView
                .throttle(RxTimeInterval.seconds(1), scheduler: MainScheduler())
                .map {[weak self] (str) in
                        guard let `self` = self else{return}
                        if let _ = self.nextPageNetworkDis {
                            self.nextPageNetworkDis?.dispose()
                        }
                    self.currentPage += 1
                    self.nextPageNetworkDis = nextPageAction(self.searchBar.text ?? "", self.currentPage)
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

        Observable.merge(updateResponse.asObservable(), nextPageResponse.asObservable())
            .map {[weak self] (_) -> [T] in
                guard let `self` = self else{return []}
                return self.searchResult}
            .bind(to:searchResultsTableView.rx
                .items(cellIdentifier: tvFactoryAction.cellIdentifier, cellType: Cell.self)) {[weak self] (row,data,cell) in
                    self?.currentNetworkDis = nil
                    self?.nextPageNetworkDis = nil
                    self?.tvFactoryAction.factory(row,data,cell)
        }.disposed(by: disposeBag)

        searchResultsTableView.rx
            .modelSelected(T.self).bind(onNext: {[unowned self] (model) in
                self.tvFactoryAction.didSelect(model)
            })
            .disposed(by: disposeBag)

        placeHolder.subscribe(onNext: {[unowned self] (str) in
            self.searchBar.placeholder = str
        }).disposed(by: disposeBag)
        
        historyTableView.frame = view.frame
        historyTableView.rowHeight = UITableView.automaticDimension
        historyTableView.delegate = self
        historyTableView.dataSource = self
        searchHistory()
        view.addSubview(historyTableView)
    }
    
    @objc fileprivate func clearAction() {
//        userDefaultsManger.clearKey(placeHolder.value)
        arrHistory = []
        historyTableView.reloadData()
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        searchBar.becomeFirstResponder()
//    }
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        let lbl = UILabel(frame: CGRect(x: 15.0, y: 10.0, width: 150, height: 20))
        lbl.text = "搜索历史"
        lbl.textColor = UIColor.black
        lbl.font = UIFont.systemFont(ofSize: 17)
        view.addSubview(lbl)
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.clearHistoryView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrHistory.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "searchHistoryCellId")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "searchHistoryCellId")
        }
        cell?.textLabel?.text = arrHistory[indexPath.row]
        cell?.textLabel?.textColor = UIColor.black
        cell?.imageView?.image = UIImage(named: "时间排序")
        cell?.selectionStyle = .none
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        searchBar.rx.text.onNext(arrHistory[indexPath.row])
//        if arrHistory.count > indexPath.row {
//            searchController.isActive = true
//            searchBar.rx.text.onNext(arrHistory[indexPath.row])
//            searchBar.becomeFirstResponder()
//        }
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
        lbl.text = "清空搜索历史(\(arrHistory.count))"
        lbl.textAlignment = .center
        lbl.textColor = UIColor.blue
        historyView.addSubview(lbl)
        let btn = UIButton(frame: historyView.bounds)
        btn.setTitle("", for: .normal)
        btn.addTarget(self, action: #selector(clearAction), for: .touchUpInside)
        btn.backgroundColor = UIColor.clear
        historyView.addSubview(btn)
        return historyView
    }
    
    fileprivate func searchHistory() {
        arrHistory.removeAll()
//        if let abc = userDefaultsManger.getDataFromKeysArchive(placeHolder.value) {
//            arrHistory = abc as! [String]
//        }
        arrHistory = ["121dsfsd","dfsdfsf","yu342h3u"]
        historyTableView.reloadData()
    }
}
