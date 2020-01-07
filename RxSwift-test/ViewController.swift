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
class ViewController: UIViewController,UITableViewDelegate {

    @IBOutlet weak var tvMain: UITableView!
    
    var arr : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            }, tvFactoryAction: (cellIdentifier:"cellId",
                                 factory: {(row,model,cell) in
                           cell.textLabel?.text = model.name
                           cell.detailTextLabel?.text = model.htmlUrl
            },didSelect:{[unowned self] model in
                self.showAlert(title: model.name, message: model.htmlUrl)
            }))
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
