//
//  ViewController.swift
//  HeartBounce
//
//  Created by 안덕환 on 22/09/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class HeartBounceViewController: UIViewController, Bindable {
    typealias ViewModelType = HeartBounceViewModel
    
    var viewModel: HeartBounceViewModel!
    var fingerIndicatorMap: [String: UIView] = [:]
    let disposeBag = DisposeBag()
    
    func bindViewModel() {
        bindViewAction()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: view)
            let identifier = String(format: "%p", t)
            viewModel.requestAppendFinger(at: location, with: identifier)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: view)
            let identifier = String(format: "%p", t)
            viewModel.requestUpdateFinger(at: location, with: identifier)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let identifier = String(format: "%p", t)
            viewModel.leaveFinger(with: identifier)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let identifier = String(format: "%p", t)
            viewModel.leaveFinger(with: identifier)
        }
    }
}

extension HeartBounceViewController {
    private func bindViewAction() {
        viewModel.viewAction
            .subscribe(onNext: { [weak self] in
                switch $0 {
                case .createFinger:
                case .updateFingerPositions:
                case .leaveFinger:
                }
            }).disposed(by: disposeBag)
    }
}

