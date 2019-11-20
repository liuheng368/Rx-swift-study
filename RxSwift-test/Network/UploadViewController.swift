//
//  UploadViewController.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/11/19.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Alamofire
import RxAlamofire

class UploadViewController: UIViewController {

    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnCancle: UIButton!
    @IBOutlet weak var vPro: UIProgressView!
    @IBOutlet weak var vActivity: UIActivityIndicatorView!
    
    let disposeBag = DisposeBag()
    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent("file1/myLogo.png")
        //两个参数表示如果有同名文件则会覆盖，如果路径中文件夹不存在则会自动创建
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    }
    let downloadURL = URLRequest(url: URL(string: "http://attach.bbs.miui.com/forum/201501/29/154912worftckqkkv55trf.jpg")!)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        _ = btnStart.rx.tap
//            .share(replay: 1)
//            .subscribe(onNext: { (_) in
//                download(self.downloadURL, to: self.destination)
//                    .takeUntil(self.btnCancle.rx.tap)
//                .subscribe(onNext: { element in
//                    element.downloadProgress(closure: { progress in
//                        self.vPro.progress = Float(progress.fractionCompleted)
//                        print("  已下载：\(progress.completedUnitCount/1024)KB")
//                        print("  总大小：\(progress.totalUnitCount/1024)KB")
//                    })
//                }, onError: { error in
//                    print("请求失败！错误原因：", error)
//                }, onCompleted: {
//                    print("完成")
//                    self.vActivity.stopAnimating()
//                }, onDisposed: {
//                    print("信号终止")
//                }).disposed(by: self.disposeBag)
//        })

        
        _ =  btnStart.rx.tap.asObservable()
            .debug("点击")
            .flatMap({ (_) -> Observable<DownloadRequest> in
                return download(self.downloadURL, to: self.destination)
                .takeUntil(self.btnCancle.rx.tap)
                .catchError{_ in Observable.empty()}
                .debug("123")
            })
            .debug("321")
            .subscribe(onNext: { element in
                print("开始下载。")
            element.downloadProgress(closure: { progress in
                self.vPro.progress = Float(progress.fractionCompleted)
                print("  已下载：\(progress.completedUnitCount/1024)KB")
                print("  总大小：\(progress.totalUnitCount/1024)KB")
            })
            }, onError: { error in
                print("下载失败! 失败原因：\(error)")
            }, onCompleted: {
                print("下载完毕!")
                self.vActivity.stopAnimating()
            }, onDisposed: {
                print("信号终止")
            }).disposed(by: disposeBag)
    }
}
