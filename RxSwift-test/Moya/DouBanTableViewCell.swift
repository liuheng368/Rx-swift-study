//
//  DouBanTableViewCell.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/11/27.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit

let DouBanTableViewCellId = "DouBanTableViewCell"
class DouBanTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
