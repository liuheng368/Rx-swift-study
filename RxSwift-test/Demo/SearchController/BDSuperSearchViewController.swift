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
 
    init(<#parameters#>) {
        <#statements#>
    }
    
    public var searchUpdateAction: Driver<T>?
    
    public var nextPageAction: Driver<T>?
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        configureSearchController()
        
        placeHolder.subscribe(onNext: {[unowned self] (str) in
            self.searchBar.placeholder = str
        }).disposed(by: disposeBag)
        
        //searchUpdate
        searchBar.rx.text
            .orEmpty
            .asDriver()
            .throttle(RxTimeInterval.milliseconds(500))
            .distinctUntilChanged()
            .flatMapLatest{_ in self.searchUpdateAction!}
            .drive(onNext: <#T##((Decodable) -> Void)?##((Decodable) -> Void)?##(Decodable) -> Void#>, onCompleted: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, onDisposed: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
                
        }
        
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
