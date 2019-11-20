//
//  SessionTableViewController.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/11/18.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxAlamofire
import CleanJSON

class SessionTableViewController: UIViewController {

    let disposeBag = DisposeBag()
    var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: self.view.frame, style:.plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        
        guard let url = URL(string: "https://www.douban.com/j/app/radio/channels") else{return}
        let req = URLRequest(url: url)
        _ = URLSession.shared.rx.data(request: req)
            .compactMap({ (data) -> [SessionModel.Channels] in
                let decoder = CleanJSONDecoder()
                return try! decoder.decode(SessionModel.self, from: data).channels
            }).bind(to: tableView.rx.items) { (tableView, row, element) in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = "\(row)：\(element)"
                return cell
        }.disposed(by: disposeBag)
    }
}

struct SessionModel : Codable {
    var channels: [Channels]
    
    struct Channels: Codable {
        var name: String
        var name_en:String
        var channel_id: String
        var seq_id: Int
        var abbr_en: String
    }
}
