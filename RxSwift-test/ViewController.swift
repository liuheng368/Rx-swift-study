//
//  ViewController.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/7/29.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit

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
               "RegisterViewController"]
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
        default:break
        }
        self.navigationController?.pushViewController(vc, animated: true)
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
