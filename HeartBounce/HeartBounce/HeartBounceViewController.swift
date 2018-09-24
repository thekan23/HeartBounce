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
            viewModel.requestAppendFinger(at: location, with: t.identifier)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: view)
            viewModel.requestUpdateFinger(at: location, with: t.identifier)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            viewModel.leaveFinger(with: t.identifier)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            viewModel.leaveFinger(with: t.identifier)
        }
    }
}

extension HeartBounceViewController {
    private func bindViewAction() {
        viewModel.viewAction
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else {
                    return
                }
                switch $0 {
                case .createFinger(let finger):
                    let indicator = self.configureFinger(finger)
                    self.fingerIndicatorMap[finger.identifier] = indicator
                case .updateFingerPositions:
                    self.fingerIndicatorMap.forEach { identifier, view in
                        guard let point = self.viewModel.fingerForIdentifier(identifier)?.currentPoint else {
                            return
                        }
                        view.snp.updateConstraints {
                            $0.center.equalTo(point)
                        }
                    }
                case .leaveFinger(let finger):
                    guard let indicator = self.fingerIndicatorMap.removeValue(forKey: finger.identifier) else {
                        return
                    }
                    indicator.removeFromSuperview()
                }
            }).disposed(by: disposeBag)
    }
    
    private func configureFinger(_ finger: Finger) -> UIView {
        let size = CGSize(width: 80, height: 80)
        let fingerIndicator = UIView()
        fingerIndicator.backgroundColor = finger.color
        fingerIndicator.layer.cornerRadius = size.width / 2
        fingerIndicator.layer.masksToBounds = true
        self.view.addSubview(fingerIndicator)
        fingerIndicator.snp.makeConstraints {
            $0.size.equalTo(size)
            $0.center.equalTo(finger.currentPoint)
        }
        return fingerIndicator
    }
}

