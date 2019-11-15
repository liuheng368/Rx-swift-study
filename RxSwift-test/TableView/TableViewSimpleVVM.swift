//
//  TableViewSimpleVVM.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/8/12.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxSwift

struct StudentModel {
    var name : String
    var age : Int
}

extension StudentModel : CustomStringConvertible {
    var description : String {
        return "name:\(name) ,age:\(age)"
    }
}

struct StudentViewModel {
    let data = Observable<[StudentModel]>.create { (observer) -> Disposable in
        observer.onNext([
            StudentModel(name: "student1", age: 11),
            StudentModel(name: "student2", age: 12),
            StudentModel(name: "student3", age: 13)
            ])
        return Disposables.create()
    }
}
