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
import Moya

class DouBanViewController: UIViewController {

    let disposeBag = DisposeBag()
    let tableView = UITableView(frame: CGRect.zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        tableView.frame = view.frame
        tableView.register(UINib(nibName: DouBanTableViewCellId, bundle: nil), forCellReuseIdentifier: DouBanTableViewCellId)
        view.addSubview(tableView)
        DouBanProvider
        DouBanProvider.rx.requestWithProgress(DoubanModel.img).subscribe { (event) in
            print(event)
        }.disposed(by: disposeBag)
        
        
        loadChannels().bind(to: tableView.rx.items(cellIdentifier: DouBanTableViewCellId, cellType: DouBanTableViewCell.self)) {(row,data,cell) in
            cell.title.text = data.name
        }.disposed(by: disposeBag)
        tableView.rx.modelSelected(SessionModel.Channels.self)
            .map{ $0.channel_id }
            .flatMapLatest{ self.loadPlayList($0) }
            .subscribe (onNext: { (songModel) in
                self.showAlert(title: "歌曲信息", message: "歌手：\(songModel.artist)\n歌曲：\(songModel.title)")
            }).disposed(by: disposeBag)
    }
    
    func loadChannels() -> Observable<[SessionModel.Channels]> {
        return DouBanProvider.rx.request(.channels).asObservable()
            .compactMap { (response) -> SessionModel in
                let decoder = CleanJSONDecoder()
                return try! decoder.decode(SessionModel.self, from: response.data)
            }.map { $0.channels}
    }
    
    func loadPlayList(_ id:String) -> Observable<ChannelModel.Song> {
        return DouBanProvider.rx.request(.playList(id: "id")).asObservable()
            .compactMap { (response) -> ChannelModel in
                let decoder = CleanJSONDecoder()
                return try! decoder.decode(ChannelModel.self, from: response.data)
        }.compactMap{ $0.song.first }
    }
    
    func showAlert(title:String, message:String){
        let alertController = UIAlertController(title: title,
                                                message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "确定", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
