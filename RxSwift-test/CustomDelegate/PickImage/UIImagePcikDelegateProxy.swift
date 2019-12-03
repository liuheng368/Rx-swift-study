//
//  UIImagePcikDelegateProxy.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/12/2.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class UIImagePcikDelegateProxy:
    DelegateProxy<UIImagePickerController,
    UIImagePickerControllerDelegate & UINavigationControllerDelegate>,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    DelegateProxyType {
    
    init(imagePickerC : UIImagePickerController) {
        super.init(parentObject: imagePickerC,
                   delegateProxy: UIImagePcikDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register {UIImagePcikDelegateProxy(imagePickerC: $0)}
    }
    
    static func currentDelegate(for object: UIImagePickerController) -> (UIImagePickerControllerDelegate & UINavigationControllerDelegate)? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?, to object: UIImagePickerController) {
        object.delegate = delegate
    }
}
