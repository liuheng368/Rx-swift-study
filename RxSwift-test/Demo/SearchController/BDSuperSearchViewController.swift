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
class BDSuperSearchViewController<T:Decodable,Cell:UITableViewCell>: UIViewController {
    
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
    }
    
    public var placeHolder:BehaviorRelay<String> =
        BehaviorRelay(value: "请输入要查询的内容")
    
    public var searchResultsTableView: UITableView {
        (searchController.searchResultsController as! BDSearchResultController).tableView
    }

    public var searchBar: UISearchBar {
        return searchController.searchBar
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let searchUpdateAction: updateBlock
    
    private let nextPageAction: nextPageBlock?
    
    private let tvFactoryAction : cellFactory
    
    private var searchController: UISearchController!
    
    private var currentPage : Int = 1
    
    let disposeBag = DisposeBag()
    private lazy var searchResult:[T] = []
    let response = BehaviorRelay<[T]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        configureSearchController()
        
        placeHolder.subscribe(onNext: {[unowned self] (str) in
            self.searchBar.placeholder = str
        }).disposed(by: disposeBag)
    
         searchBar.rx.text.orEmpty
            .filter{ $0.count > 0 }
            .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler())
            .distinctUntilChanged()
            .flatMap {[weak self] (str) -> Observable<[T]> in
                guard let network = self?.searchUpdateAction(str) else{
                    return Observable.empty()
                }
                return network.asObservable() }
            .asDriver(onErrorJustReturn: [])
            .map {[weak self] arr -> [T]  in
                guard let `self` = self else{return []}
                self.searchResult.removeAll()
                arr.forEach{[weak self] in
                    if let _ = self {
                        self!.searchResult.append($0) }
                    }
                return arr}.drive(onNext: { (a) in
                    print(a)
            }).disposed(by: disposeBag)

        var nextPage : Driver<[T]>?
        if let nextPageAction = nextPageAction {
            nextPage = searchResultsTableView.rx
                .footerView
                .flatMapLatest {[weak self] (_) -> Observable<[T]> in
                    guard let `self` = self else{return Observable.empty()}
                    self.currentPage += 1
                    let network = nextPageAction(self.searchBar.text ?? "", self.currentPage)
                    return network.asObservable() }
                .asDriver(onErrorJustReturn: [])
                .map {[weak self] arr -> [T] in
                    guard let `self` = self else{return []}
                    arr.forEach{ self.searchResult.append($0) }
                    return arr
            }
        }

        searchResultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
//        Driver.merge(update, nextPage ?? Driver.empty())
//            .drive(searchResultsTableView.rx
//                .items(cellIdentifier: tvFactoryAction.cellIdentifier, cellType: Cell.self)) {[unowned self] (row,data,cell) in
//                self.tvFactoryAction.factory(row,data,cell)
//        }
//        .disposed(by: disposeBag)

        searchResultsTableView.rx
            .modelSelected(T.self).bind(onNext: {[unowned self] (model) in
                self.tvFactoryAction.didSelect(model)
            })
            .disposed(by: disposeBag)
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        searchBar.becomeFirstResponder()
//    }
    
    func configureSearchController() {
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

        if #available(*, iOS 11.0.1) {
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
}

struct qwe:Decodable {
    var ss : String
}
