//
//  GeoLocationService.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/12/2.
//  Copyright © 2019 刘恒. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa

class GeoLocationService {
    static let instance = GeoLocationService()
    
    //定位权限序列
    private (set) var authorized: Driver<Bool>
    //经纬度信息序列
    private (set) var location: Driver<CLLocationCoordinate2D>
    //定位管理器
    private let locationManager = CLLocationManager()
    
    private init() {
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        authorized = Observable.deferred({[weak locationManager] in
            let status = CLLocationManager.authorizationStatus()
            guard let locationManager = locationManager else {return Observable.just(status)}
            return locationManager
                .rx.didChangeAuthorizationStatus
                .startWith(status)
        })
            .asDriver(onErrorJustReturn: CLAuthorizationStatus.notDetermined)
            .map {
                switch $0 {
                case .notDetermined:return false
                default:return true
                }
        }
        
        location = locationManager.rx.didUpdateLocations
            .asDriver(onErrorJustReturn: [])
            .flatMap({($0.last.map { Driver.just($0)} ?? Driver.empty())})
            .map{ return $0.coordinate}
        
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
}
