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
import CleanJSON

class SessionTableViewController: UITableViewController {

    var data : SessionModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = URL(string: "https://www.douban.com/j/app/radio/channels") else{return}
        let req = URLRequest(url: url)
        
        URLSession.shared.rx.data(request: req)
            .subscribe(onNext: { (data) in
                let decoder = CleanJSONDecoder()
                self.data = try? decoder.decode(SessionModel.self, from: data)
                print(self.data)
            })
    }
    
}

struct SessionModel : Codable {
    var channels: [channels]
    
    struct channels: Codable {
        var name: String
        var nameEn:String
        var channelId: String
        var seqId: Int
        var abbrEn: String
    }
}
