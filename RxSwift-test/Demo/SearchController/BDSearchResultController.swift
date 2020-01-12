
//
//  BDSearchResultController.swift
//  greatwall
//
//  Created by Henry on 2019/12/30.
//  Copyright © 2019 dada. All rights reserved.
//

import UIKit

enum BDSearchResultState {
    case Loading, Result, NoResult, LessInput
}

class BDSearchResultController: UIViewController {

    public var resultState : BDSearchResultState? {
        didSet{
            switch resultState {
            case .Result:
                tableView.isHidden = false
            case .Loading:
                tableView.isHidden = true
                lblTips.text = loading
            case .NoResult:
                tableView.isHidden = true
                lblTips.text = noResult
            case .LessInput, .none:
                tableView.isHidden = true
                lblTips.text = lessInputTips
            }
        }
    }
    
    public let tableView = UITableView(frame: CGRect.zero, style: .plain)
    let lblTips = UILabel(frame: CGRect.zero)
    
    let lessInputTips = "再输入一点信息吧~"
    let noResult = "没有搜索结果，换个关键词试试..."
    let loading = "正在拼命加载中..."
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        lblTips.frame = view.frame
        lblTips.textColor = UIColor.darkText
        lblTips.textAlignment = .center
        view.addSubview(lblTips)
        
        tableView.frame = view.frame
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)
    }
}
