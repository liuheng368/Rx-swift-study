//
//  MVVMViewModel.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/11/27.
//  Copyright © 2019 刘恒. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CleanJSON

class MVVMService {
     
    func searchRepositories(_ query:String) -> Driver<MVVMModel>{
        return GitHubProvider.rx.request(.repositories(query))
            .filterSuccessfulStatusCodes().asObservable()
            .compactMap { try! CleanJSONDecoder().decode(MVVMModel.self, from: $0.data)}
            .asDriver(onErrorRecover: {_ in Driver.empty()})
    }
}

class MVVMViewModel {
    
    let networkService = MVVMService()
    
    fileprivate let searchAction:Driver<String>
    
    let searchResult: Driver<MVVMModel>
    
    let repositories : Driver<[MVVMModel.GitHubRepository]>
    
    let cleanResult : Driver<Void>
    
    let navigationTitle: Driver<String>
    
    
    init(searchAction_ : Driver<String>) {
        self.searchAction = searchAction_
            
        self.searchResult = searchAction_
            .filter{
                !$0.isEmpty}
            .flatMapLatest(networkService.searchRepositories)
        
        self.cleanResult = searchAction_
            .filter{
                $0.isEmpty }
            .map{_ in Void() }
        
        self.repositories = Driver.of(searchResult.map{$0.items},
                                      cleanResult.map{[]}).merge()
        
        self.navigationTitle = Driver.merge(searchResult.map{"共有 \($0.total_count) 个结果"},
                                            cleanResult.map{"henry"})
    }
}
