//
//  BDSuperSearchViewController.swift
//  greatwall
//
//  Created by Henry on 2019/12/30.
//  Copyright © 2019 dada. All rights reserved.
//

import UIKit

class BDSuperSearchViewController: UISearchController {

    
    public init() {
//        super.init(searchResultsController: BDSearchTableViewController(style: .plain))
        super.init(searchResultsController: UIViewController())
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        hidesNavigationBarDuringPresentation = true
        dimsBackgroundDuringPresentation = false
    }

//    private var searchResultVC : BDSearchTableViewController
}
