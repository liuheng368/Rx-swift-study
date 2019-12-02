//
//  Rx+CLLocationManager.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/12/2.
//  Copyright © 2019 刘恒. All rights reserved.
//

import CoreLocation
import RxCocoa
import RxSwift
extension Reactive where Base : CLLocationManager{
    
    public var delegate : DelegateProxy<CLLocationManager,CLLocationManagerDelegate> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
    }
    
    public var didUpdateLocations : Observable<[CLLocation]> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
            .didUpdateLocationsSubject.asObserver()
    }
    
    public var didFailWithError : Observable<Error> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
            .didFailWithErrorSubject.asObserver()
    }
    
    public var didFinishDeferredUpdatesWithError: Observable<Error?> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate
            .locationManager(_:didFinishDeferredUpdatesWithError:)))
            .map { (any) in
                return try castOptionalOrThrow(Error.self, any[1])
        }
    }
    
    public var didStartMonitoringForRegion: Observable<CLRegion> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate
            .locationManager(_:didStartMonitoringFor:)))
            .map { a in
                return try castOrThrow(CLRegion.self, a[1])
        }
    }
    
    public var didVisit: Observable<CLVisit> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate
            .locationManager(_:didVisit:)))
            .map { a in
                return try castOrThrow(CLVisit.self, a[1])
        }
    }
    
    public var didChangeAuthorizationStatus: Observable<CLAuthorizationStatus> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate
            .locationManager(_:didChangeAuthorization:)))
            .map { a in
                let number = try castOrThrow(NSNumber.self, a[1])
                return CLAuthorizationStatus(rawValue: Int32(number.intValue))
                    ?? .notDetermined
        }
    }
}

fileprivate func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
     
    return returnValue
}
 
fileprivate func castOptionalOrThrow<T>(_ resultType: T.Type,
                                        _ object: Any) throws -> T? {
    if NSNull().isEqual(object) {
        return nil
    }
     
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}
