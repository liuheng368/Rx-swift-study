
//
//  SearchDemoViewController.swift
//  RxSwift-test
//
//  Created by Henry on 2019/12/30.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit

class SearchDemoViewController: UIViewController {

    let a = BDSuperSearchViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = a
        } else {
            self.navigationItem.titleView = a.searchBar
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
