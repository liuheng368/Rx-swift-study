//
//  PickImageViewController.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/12/2.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PickImageViewController: UIViewController {
    @IBOutlet weak var btnPhoto: UIButton!
    @IBOutlet weak var btnPicture: UIButton!
    @IBOutlet weak var btnChip: UIButton!
    @IBOutlet weak var ivImage: UIImageView!
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        btnPhoto.isHidden = !UIImagePickerController.isSourceTypeAvailable(.camera)
        btnPicture.isHidden = !UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        
//        btnPhoto.rx.tap
//            .flatMapLatest { [weak self] in
//                return UIImagePickerController.rx.createWithParent(self!) { (imagePick) in
//                    imagePick.sourceType = .camera
//                    imagePick.allowsEditing = false
//                }.flatMap{$0.rx.didFinishPickingMediaWithInfo}
//        }.map { (info) in
//            return info[UIImagePickerController.InfoKey.originalImage] as? UIImage
//        }.bind(to: _)
//        .disposed(by: disposeBag)
        
        btnChip.rx.tap
            .flatMapLatest {[weak self] in
                return UIImagePickerController.rx.createWithParent(self!) { (imagePick) in
                    imagePick.sourceType = .photoLibrary
                    imagePick.allowsEditing = true
                }.flatMap{$0.rx.didFinishPickingMediaWithInfo}
        }.map { (info) in
            return info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        }.subscribe(onNext: { (_) in
            
        })
        .disposed(by: disposeBag)
    }
}
