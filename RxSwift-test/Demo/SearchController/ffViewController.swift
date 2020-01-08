//
//  ffViewController.swift
//  RxSwift-test
//
//  Created by Henry on 2020/1/8.
//  Copyright © 2020 刘恒. All rights reserved.
//

import UIKit

class ffViewController: UIViewController {

//    private var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        // Do any additional setup after loading the view.
    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        searchController = nil
//    }
    
    func configureSearchController() {
        let controller = BDSearchResultController()
        let searchController = UISearchController(searchResultsController: controller)
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        searchController.dimsBackgroundDuringPresentation = false
        #if swift(<11.0)
        searchController.hidesNavigationBarDuringPresentation = false
        #endif
        searchController.searchBar.autocapitalizationType = .none

        if #available(*, iOS 11.0.1) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            navigationItem.titleView = searchController.searchBar
        }
//        definesPresentationContext = true
//        extendedLayoutIncludesOpaqueBars = true
//
//        var tf : UITextField
//        if #available(iOS 13.0, *) {
//            tf = searchController.searchBar.searchTextField
//        }else{
//            tf = searchController.searchBar.value(forKey: "_searchField") as! UITextField
//        }
//        tf.backgroundColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1)
//        tf.layer.cornerRadius = 18
//        tf.layer.masksToBounds = true
//        tf.font = UIFont.systemFont(ofSize: 14)
//        searchController.searchBar.sizeToFit()
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
