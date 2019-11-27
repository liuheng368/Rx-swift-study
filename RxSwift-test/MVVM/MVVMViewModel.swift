//
//  MVVMViewModel.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/11/27.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxSwift
import CleanJSON

class MVVMService {
     
    func searchRepositories(_ query:String) -> Observable<MVVMModel>{
        return GitHubProvider.rx.request(.repositories(query))
            .asObservable()
            .compactMap { try! CleanJSONDecoder().decode(MVVMModel.self, from: $0.data)}
            .catchError { _ in Observable<MVVMModel>.empty() }
    }
}

class MVVMViewModel {
    
    let networkService = MVVMService()
    
    fileprivate let searchAction:Observable<String>
    
    let searchResult: Observable<MVVMModel>
    
    let repositories : Observable<[MVVMModel.GitHubRepository]>
    
    let cleanResult : Observable<Void>
    
    let navigationTitle: Observable<String>
    
    
    init(searchAction_ : Observable<String>) {
        self.searchAction = searchAction_
        
        self.searchResult = searchAction_
            .filter{!$0.isEmpty}
            .flatMapLatest(networkService.searchRepositories)
        
        self.cleanResult = searchAction_
            .filter{ $0.isEmpty }
            .map{_ in Void() }
        
        self.repositories = Observable.of(searchResult.map{$0.items},
                                          cleanResult.map{[]}).merge()
        
        self.navigationTitle = Observable.of(searchResult.map{"共有 \($0.total_count) 个结果"},
                                             cleanResult.map{"henry"}).merge()
    }
}
