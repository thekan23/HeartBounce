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
import RxCocoa
import NVActivityIndicatorView

class HeartBounceViewController: UIViewController, Bindable {
    typealias ViewModelType = HeartBounceViewModel
    
    @IBOutlet weak var surfaceView: UIView!
    @IBOutlet weak var displayGameStateLabel: UILabel!
    @IBOutlet weak var finishAndRestartView: UIView!
    @IBOutlet weak var restartButton: UIButton!
    
    var viewModel: HeartBounceViewModel!
    var fingerIndicatorMap: [String: HeartBounceView] = [:]
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func bindViewModel() {
        bindViewAction()
        bindState()
        bindButtons()
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
                    self.removeAllExceptCaughtFingers()
                }
            }).disposed(by: disposeBag)
    }
    
    private func bindState() {
        viewModel.state.asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                switch $0 {
                case .idle:
                    self.displayGameStateLabel.isHidden = false
                    self.finishAndRestartView.isHidden = true
                    self.displayGameStateLabel.text = "Wait..."
                case .wait:
                    self.viewModel.fingerEnterTimer.countDown
                        .subscribe(onNext: { countDown in
                            if self.viewModel.state.value == .wait {
                                self.displayGameStateLabel.text = String(countDown)
                            }
                        }).disposed(by: self.disposeBag)
                case .progress:
                    self.displayGameStateLabel.text = "Start"
                    Vibration.medium.vibrate()
                case .ended:
                    self.displayGameStateLabel.isHidden = true
                    self.finishAndRestartView.isHidden = false
                    Vibration.heavy.vibrate()
                }
            }).disposed(by: disposeBag)
    }
    
    private func bindButtons() {
        restartButton.rx.tap
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.restart()
            }).disposed(by: disposeBag)
    }
}

extension HeartBounceViewController {
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
    
    private func removeAllExceptCaughtFingers() {
        let caughtFingers = self.viewModel.caughtFingers
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
}
