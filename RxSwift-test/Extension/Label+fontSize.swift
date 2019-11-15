//
//  Label+fontSize.swift
//  RxSwift-test
//
//  Created by 刘恒 on 2019/8/13.
//  Copyright © 2019 刘恒. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: UILabel {
    public var fontSize : Binder<Int> {
        return Binder(self.base) {(label, size) in
            label.font = UIFont.systemFont(ofSize: CGFloat(size * 2))
        }
    }
}
