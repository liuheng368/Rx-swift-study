//
//  DouBanViewController.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/11/26.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CleanJSON

class DouBanViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        DouBanProvider.rx.request(.channels).subscribe(onSuccess: { (res) in
            print(String(data: res.data, encoding: .utf8))
        }) { (err) in
            print(err)
        }.disposed(by: disposeBag)
    }
    
    func loadChannels() -> Observable<SessionModel> {
        let a = DouBanProvider.rx.request(.channels)
            .map([SessionModel.Channels].self)
        
//            .compactMap { (response) -> [SessionModel.Channels] in
//                let decoder = CleanJSONDecoder()
//                return try! decoder.decode(SessionModel.self, from: response.data).channels
//        }
        
        return
    }
    

}
