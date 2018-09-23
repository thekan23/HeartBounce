//
//  BindableType.swift
//  HeartBounce
//
//  Created by 안덕환 on 23/09/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import UIKit

protocol Bindable: class {
    associatedtype ViewModelType
    var viewModel: ViewModelType! { get set }
    func bindViewModel()
}

extension Bindable where Self: UIViewController {
    func bindViewModel(to viewModel: Self.ViewModelType) {
        self.viewModel = viewModel
        loadViewIfNeeded()
        bindViewModel()
    }
}
