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
import NVActivityIndicatorView

class HeartBounceViewController: UIViewController, Bindable {
    typealias ViewModelType = HeartBounceViewModel
    
    @IBOutlet weak var surfaceView: UIView!
    
    var viewModel: HeartBounceViewModel!
    var fingerIndicatorMap: [String: HeartBounceView] = [:]
    let disposeBag = DisposeBag()
    
    func bindViewModel() {
        bindViewAction()
        bindState()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: view)
            viewModel.requestAppendFinger(at: location, with: t.identifier)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if viewModel.state.value == .ended {
            return
        }
        
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
                    let indicator = self.configureFingerIndicator(finger)
                    indicator.startAnimating()
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
                    indicator.stopAnimation()
                    indicator.removeFromSuperview()
                case .leaveFingerWithOrder(let finger):
                    guard let indicator = self.fingerIndicatorMap.removeValue(forKey: finger.identifier) else {
                        return
                    }
                    indicator.stopAnimation()
                    indicator.removeFromSuperview()
                case .indicateCaughtFingers:
                    let caughtFingers = self.viewModel.caughtFingers
                    print("caught count: \(caughtFingers.count)")
                    for (key, indicator) in self.fingerIndicatorMap {
                        var isMatched = false
                        for caughtFinger in caughtFingers {
                            if caughtFinger.identifier == key {
                                isMatched = true
                            }
                        }
                        if !isMatched {
                            indicator.removeFromSuperview()
                        }
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    private func bindState() {
        viewModel.state.asObservable()
            .subscribe(onNext: {
                switch $0 {
                case .idle:
                    print("idle")
                case .wait:
                    print("wait")
                case .progress:
                    Vibration.medium.vibrate()
                    print("progress")
                case .ended:
                    Vibration.heavy.vibrate()
                    print("ended")
                }
            }).disposed(by: disposeBag)
    }
    
    private func configureFingerIndicator(_ finger: Finger) -> HeartBounceView {
        let frameSize = CGSize(width: 120, height: 120)
        let fingerIndicator = HeartBounceView(color: finger.color)
        view.addSubview(fingerIndicator)
        fingerIndicator.snp.makeConstraints {
            $0.size.equalTo(frameSize)
            $0.center.equalTo(finger.currentPoint)
        }
        return fingerIndicator
    }
}

