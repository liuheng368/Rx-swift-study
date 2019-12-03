//
//  Rx+UIImagePcikController.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/12/2.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base : UIImagePickerController {
    
    public var delegatea : DelegateProxy<UIImagePickerController,
        UIImagePickerControllerDelegate & UINavigationControllerDelegate> {
        return UIImagePcikDelegateProxy.proxy(for: base)
    }
    
    public var didFinishPickingMediaWithInfo : Observable<[UIImagePickerController.InfoKey : AnyObject]> {
        return delegatea.methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
            .map{ try castOrThrow([UIImagePickerController.InfoKey : AnyObject].self, $0[1]) }
    }
    
    public var didCancel : Observable<()> {
        return delegatea.methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
            .map{_ in}
    }
    
    static func createWithParent(_ parentVC : UIViewController,
                                 animated:Bool = true,
                                 configure:@escaping (UIImagePickerController)throws -> ()) -> Observable<UIImagePickerController> {
        return Observable.create { (observer) in
            var imagePick = UIImagePickerController()
            
            let dissmissDis = Observable.merge(
                imagePick.rx.didFinishPickingMediaWithInfo.map{_ in},
                imagePick.rx.didCancel)
                .subscribe(onNext: {_ in
                    observer.on(.completed)
                })
            do {
                try configure(imagePick)
            }catch{
                observer.on(.error(error))
                return Disposables.create()
            }
            parentVC.present(imagePick, animated: true, completion: nil)
            observer.on(.next(imagePick))
            return Disposables.create {
                dismissViewController(imagePick, animated: true)
            }
        }
    }
}

func dismissViewController(_ viewController: UIViewController, animated: Bool) {
    if viewController.isBeingDismissed || viewController.isBeingPresented {
        DispatchQueue.main.async {
            dismissViewController(viewController, animated: animated)
        }
        return
    }
     
    if viewController.presentingViewController != nil {
        viewController.dismiss(animated: animated, completion: nil)
    }
}
