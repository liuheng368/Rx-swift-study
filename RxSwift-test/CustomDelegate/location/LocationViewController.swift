//
//  LocationViewController.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/12/2.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class LocationViewController: UIViewController {

    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var lblLat: UILabel!
    @IBOutlet weak var lblLng: UILabel!
    
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()

        GeoLocationService.instance.authorized
            .drive(btnLocation.rx.isHidden)
            .disposed(by: disposeBag)
        
        GeoLocationService.instance.location.drive(onNext: { (cll) in
            self.lblLat.text = "维度:\(cll.latitude)"
            self.lblLng.text = "经度:\(cll.longitude)"
        }).disposed(by: disposeBag)
        
        btnLocation.rx.tap.bind {
            self.openAppPreferences()
        }.disposed(by: disposeBag)
    }
    
    private func openAppPreferences() {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        } else {
            UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
        }
    }

}
