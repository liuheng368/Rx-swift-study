
//
//  BDSearchResultController.swift
//  greatwall
//
//  Created by Henry on 2019/12/30.
//  Copyright © 2019 dada. All rights reserved.
//

import UIKit

class BDSearchResultController: UIViewController {

    lazy var tableView = UITableView(frame: self.view.frame, style: .plain)
    var data : [Decodable]? {
        didSet{
            if let _ = data {
                self.tableView.reloadData()
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.red
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
}

extension BDSearchResultController:UITableViewDelegate,UITableViewDataSource{
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell? = UITableViewCell(style: .default, reuseIdentifier: "cellId")
        cell?.textLabel?.text = "\(data?[indexPath.row] ?? "1")"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
