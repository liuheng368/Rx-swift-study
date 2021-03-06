//
//  ViewController.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/7/29.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import CleanJSON


struct RootClass: Codable {
    var nu: String
    var state: String
    var status: String
    var data : [Dataa]
    var com: String
    var condition: String
    var ischeck: String
    var condition1: String
    var ischeck1: String
    var message: String
}

struct Dataa: Codable {
    var time: String
    var context: String
    var ftime: String
}



class ViewController: UIViewController,UITableViewDelegate {
    
    @IBOutlet weak var tvMain: UITableView!
    
    var arr : [String] = []
    
    func swiftChart() {
//        Thread.sleep(forTimeInterval: TimeInterval(10))
        sleep(10)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swiftChart()
        var dic : [String:[String]] = [:]
        dic["key"] = []
        for i in 0...1 {
            dic["key"]?.append("as\(i)")
        }
        
        let data = NSData(contentsOfFile: Bundle.main.path(forResource: "asd.json", ofType: "")!)! as Data
//        let data = try! JSONSerialization.data(withJSONObject: ss, options: .prettyPrinted)
        NSLog("%ld", Int(Date().timeIntervalSince1970 * 1000))
        for i in 0...1 {
            let a = try! CleanJSONDecoder().decode(RootClass.self, from: data)
//            let a = try! JSONDecoder().decode(RootClass.self, from: data)
        }
        NSLog("%ld", Int(Date().timeIntervalSince1970 * 1000))
        
        tvMain.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        arr = ["textFiled",
               "TableViewSimpleViewController",
               "ButtonViewController",
               "TapViewController",
               "DatePickerViewController",
               "RxDataSourceViewController",
               "PickViewViewController",
               "SessionViewController",
               "SessionTableViewController",
               "UploadViewController",
               "DouBanViewController",
               "MVVMViewController",
               "RegisterViewController",
               "LocationViewController",
               "PickImageViewController",
               "SearchDemoViewController"]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var vc : UIViewController = UIViewController()
        switch indexPath.row {
        case 0:
            vc = TextFieldsViewController(nibName: "TextFieldsViewController", bundle: nil)
        case 1:
            vc = TableViewSimpleViewController(nibName: "TableViewSimpleViewController", bundle: nil)
        case 2:
            vc = ButtonViewController(nibName: "ButtonViewController", bundle: nil)
        case 3:
            vc = TapViewController()
        case 4:
            vc = DatePickerViewController(nibName: "DatePickerViewController", bundle: nil)
        case 5:
            vc = RxDataSourceViewController()
        case 6:
            vc = PickViewViewController()
        case 7:
            vc = SessionViewController()
        case 8:
            vc = SessionTableViewController()
        case 9:
            vc = UploadViewController(nibName: "UploadViewController", bundle: nil)
        case 10:
            vc = DouBanViewController()
        case 11:
            vc = MVVMViewController()
        case 12:
            vc = RegisterViewController()
        case 13:
            vc = LocationViewController()
        case 14:
            vc = PickImageViewController()
        case 15:
            vc = BDSuperSearchViewController<MVVMModel.GitHubRepository, UITableViewCell>(searchUpdateAction: { (searchText) in
                return GitHubProvider.rx
                    .request(MultiTarget(MVVMApi.repositories(searchText)))
                    .asObservable()
                    .compactMap { try! CleanJSONDecoder().decode(MVVMModel.self, from: $0.data).items}
                    .asDriver(onErrorJustReturn: [])
            },nextPageAction:{ (searchText, page) in
                return GitHubProvider.rx
                    .request(MultiTarget(MVVMApi.repositories(searchText)))
                    .asObservable()
                    .compactMap { try! CleanJSONDecoder().decode(MVVMModel.self, from: $0.data).items}
                    .asDriver(onErrorJustReturn: [])
            }, tvFactoryAction: (cellIdentifier:"cellId",
                                 factory: {(row,model,cell) in
                           cell.textLabel?.text = model.name
                           cell.detailTextLabel?.text = model.htmlUrl
            },didSelect:{[unowned self] model in
                self.showAlert(title: model.name, message: model.htmlUrl)
            }))
            (vc as? BDSuperSearchViewController<MVVMModel.GitHubRepository, UITableViewCell>)?.searchResultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
            (vc as? BDSuperSearchViewController<MVVMModel.GitHubRepository, UITableViewCell>)?.placeHolder.accept("商户ID")
        default:break
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAlert(title:String, message:String){
        let alertController = UIAlertController(title: title,
                                                message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cellId")
        cell?.textLabel?.text = arr[indexPath.row]
        return cell!
    }
}
