//
//  BDSuperSearchViewController.swift
//  greatwall
//
//  Created by Henry on 2019/12/30.
//  Copyright © 2019 dada. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BDSuperSearchViewController<T:Decodable>: UIViewController {
    
    public typealias updateBlock = (_ text:String)->(Driver<[T]>)
    public typealias nextPageBlock = (_ text:String,_ page:Int)->(Driver<[T]>)
    
    public var searchUpdateAction: updateBlock!
   
    public var nextPageAction: nextPageBlock?
    
    public var placeHolder:BehaviorRelay<String> =
        BehaviorRelay(value: "请输入要查询的内容")
    
    public var searchResultsTableView: UITableView {
        return (searchController.searchResultsController as! BDSearchTableViewController).tableView
    }

    public var searchBar: UISearchBar {
        return searchController.searchBar
    }
    
    private lazy var searchController: UISearchController = {
        let controller = BDSearchTableViewController(style: .plain)
        let searchC = UISearchController(searchResultsController: controller)
        if #available(iOS 9.1, *) {
            searchC.obscuresBackgroundDuringPresentation = false
        }
        searchC.dimsBackgroundDuringPresentation = false
        searchC.searchResultsUpdater = self as? UISearchResultsUpdating
        #if swift(<11.0)
        searchC.hidesNavigationBarDuringPresentation = false
        #endif
        return searchC
    }()
    
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
            .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler())
            .distinctUntilChanged()
            .flatMapLatest(searchUpdateAction)
            .map { (arr) -> [T] in
                arr.forEach { self.searchResult.append($0) }
                return arr}
            .asDriver(onErrorJustReturn: [])
            .drive(response)
            .disposed(by: disposeBag)
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        searchBar.becomeFirstResponder()
//    }
    
    func configureSearchController() {
        searchBar.autocapitalizationType = .none
        
        if #available(*, iOS 11.0.1) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            navigationItem.titleView = searchController.searchBar
        }
        definesPresentationContext = true
        extendedLayoutIncludesOpaqueBars = true
    }
}
