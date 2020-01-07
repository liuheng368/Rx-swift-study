//
//  MVVMViewController.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/11/27.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Moya
class MVVMViewController: UIViewController {

    let tableView = UITableView(frame: CGRect.zero, style: .plain)
    let searchBar = UISearchBar(frame: CGRect.zero)
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        tableView.frame = view.frame
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        view.addSubview(tableView)
        searchBar.frame.size = CGSize(width: view.frame.width, height: 56)
        tableView.tableHeaderView = searchBar
        let searchAction = searchBar.rx.text
            .orEmpty
            .asDriver()
            .throttle(RxTimeInterval.milliseconds(500))
            .distinctUntilChanged()
        
        let viewModel = MVVMViewModel(searchAction_: searchAction)
        viewModel.navigationTitle.drive(navigationItem.rx.title).disposed(by: disposeBag)
        
        viewModel.repositories.drive(tableView.rx.items) {(tableView, row, element) in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellId")!
            cell.textLabel?.text = element.name
            cell.detailTextLabel?.text = element.htmlUrl
            return cell
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(MVVMModel.GitHubRepository.self)
            .subscribe(onNext: {[unowned self] (item) in
                self.showAlert(title: item.fullName, message: item.description)
            }).disposed(by: disposeBag)
        
        let a = GitHubProvider.rx.request(MultiTarget(vvv.lll)).subscribe(onSuccess: { (obj) in
            print(obj)
        }) { (err) in
            print(err)
        }.disposed(by: disposeBag)
        
        
        
    }
    
    func showAlert(title:String, message:String){
        let alertController = UIAlertController(title: title,
                                                message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
