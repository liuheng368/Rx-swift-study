//
//  UISearchBar+BDRx.swift
//  RxSwift-test
//
//  Created by Henry on 2020/1/12.
//  Copyright © 2020 刘恒. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
extension Reactive where Base: UISearchBar {

/// Reactive wrapper for `text` property.
public var textChange: ControlProperty<String?> {
    let source: Observable<String?> = Observable.deferred { [weak searchBar = self.base as UISearchBar] () -> Observable<String?> in
        let text = searchBar?.text

        let textDidChange = (searchBar?.rx.delegate.methodInvoked(#selector(UISearchBarDelegate.searchBar(_:textDidChange:))) ?? Observable.empty())
        
        return textDidChange
                .map { _ in searchBar?.text ?? "" }
                .startWith(text)
    }

    let bindingObserver = Binder(self.base) { (searchBar, text: String?) in
        searchBar.text = text
    }
    
    return ControlProperty(values: source, valueSink: bindingObserver)
    }
}
