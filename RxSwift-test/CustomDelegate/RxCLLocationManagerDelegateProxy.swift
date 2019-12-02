//
//  RxCLLocationManagerDelegateProxy.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/12/2.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

extension CLLocationManager : HasDelegate{
    public typealias Delegate = CLLocationManagerDelegate
}

class RxCLLocationManagerDelegateProxy:
    DelegateProxy<CLLocationManager, CLLocationManagerDelegate>,
CLLocationManagerDelegate, DelegateProxyType {
    
    public init(locationDelegate: CLLocationManager) {
        super.init(parentObject: locationDelegate,
                   delegateProxy: RxCLLocationManagerDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { (delegate) -> RxCLLocationManagerDelegateProxy in
            return RxCLLocationManagerDelegateProxy(locationDelegate: delegate)
        }
    }
    
    lazy var didUpdateLocationsSubject = PublishSubject<[CLLocation]>()
    lazy var didFailWithErrorSubject = PublishSubject<Error>()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _forwardToDelegate?.locationManager(manager, didUpdateLocations: locations)
        didUpdateLocationsSubject.onNext(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        _forwardToDelegate?.locationManager(manager, didFailWithError: error)
        didFailWithErrorSubject.onNext(error)
    }
    
    deinit {
        didUpdateLocationsSubject.onCompleted()
        didFailWithErrorSubject.onCompleted()
    }
}
