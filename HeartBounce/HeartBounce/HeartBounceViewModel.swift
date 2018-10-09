//
//  HeartBounceViewModel.swift
//  HeartBounce
//
//  Created by 안덕환 on 23/09/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

class HeartBounceViewModel {
    
    enum ViewAction {
        case createFinger(Finger)
        case updateFingerPositions
        case leaveFinger(Finger)
        case leaveFingerWithOrder(Finger)
        case indicateCaughtFingers
    }
    
    enum State {
        case idle
        case wait
        case progress
        case ended
    }
    
    let viewAction = PublishSubject<ViewAction>()
    let fingers = Variable<[Finger]>([])
    let state = Variable<State>(.idle)
    let fingerProducer = FingerProducer()
    var disposeBag = DisposeBag()
    let fingerEnterTimer = SecondCountDownTimer(from: 3, to: 0)
    var fingerLeaveTimer: MilliSecondCountDownTimer?
    
    var leavedFingersProxy: [Finger] = []
    
    var numberOfFingers: Int {
        return fingers.value.count
    }
    
    var numberOfLeavedFingers: Int {
        return fingers.value.filter { $0.state == .leaved }.count
    }
    
    var numberOfUnleavedFingers: Int {
        return fingers.value.filter { $0.state == .none }.count
    }
    
    var caughtFingers: [Finger] {
        return fingers.value.filter { $0.state == .caught }
    }
    
    init() {
        restart()
    }
    
    func fingerForIdentifier(_ identifier: String) -> Finger? {
        guard let finger = fingers.value.first(where: { $0.identifier == identifier }) else {
            return nil
        }
        return finger
    }
    
    func requestAppendFinger(at pointt: CGPoint, with identifier: String) {
        if state.value == .idle {
            state.value = .wait
        }
        
        guard state.value == .wait else {
            return
        }
        guard !fingers.value.contains(where: { $0.identifier == identifier }) else {
            return
        }
        
        let finger = fingerProducer.produce(identifier: identifier, point: pointt)
        fingers.value.append(finger)
        viewAction.onNext(.createFinger(finger))
        fingerEnterTimer.count()
    }
    
    func requestUpdateFinger(at point: CGPoint, with identifier: String) {
        guard let fingerIndex = fingers.value.firstIndex(where: { $0.identifier == identifier }) else {
            return
        }
        fingers.value[fingerIndex].currentPoint = point
        viewAction.onNext(.updateFingerPositions)
    }
    
    func leaveFinger(with identifier: String) {
        switch state.value {
        case .wait:
            handleFingerLeaveWhenWait(identifier)
        case .progress:
            handleFingerLeaveWhenProgress(identifier)
        default:
            break
        }
    }
    
    func restart() {
        fingers.value.removeAll()
        state.value = .idle
        disposeBag = DisposeBag()
        leavedFingersProxy.removeAll()
        
        fingerEnterTimer.countDown
            .subscribe(onNext: { [weak self] count in
                guard let `self` = self else {
                    return
                }
                guard self.state.value == .wait else {
                    return
                }
                if count == 0 {
                    if self.numberOfFingers > 1 {
                        self.state.value = .progress
                    } else {
                        self.state.value = .idle
                    }
                }
            }).disposed(by: disposeBag)
    }
    
    private func handleFingerLeaveWhenWait(_ identifier: String) {
        guard let leavedFingerIndex = fingers.value.firstIndex(where: { $0.identifier == identifier }) else {
            return
        }
        
        let leavedFinger = fingers.value.remove(at: leavedFingerIndex)
        viewAction.onNext(.leaveFinger(leavedFinger))
    }
    
    private func processMultipleLeaveEndSequence() {
        guard leavedFingersProxy.count >= 2 else {
            return
        }
        for leavedFinger in leavedFingersProxy {
            guard let index = fingers.value.firstIndex(where: { $0.identifier == leavedFinger.identifier }) else {
                continue
            }
            fingers.value[index].state = .caught
        }
        state.value = .ended
        viewAction.onNext(.indicateCaughtFingers)
    }
    
    private func processLastOneEndSequence() {
        guard numberOfUnleavedFingers <= 1, let index = fingers.value.firstIndex(where: { $0.state == .none }) else {
            return
        }
        fingers.value[index].state = .caught
        state.value = .ended
        viewAction.onNext(.indicateCaughtFingers)
    }
    
    private func processNextSequence() {
        guard
            leavedFingersProxy.count < 2, let identifier = leavedFingersProxy.first?.identifier,
            let fingerIndex = fingers.value.firstIndex(where: { $0.identifier == identifier }) else {
                return
        }
        fingers.value[fingerIndex].state = .leaved
        let leavedFinger = fingers.value[fingerIndex]
        viewAction.onNext(.leaveFingerWithOrder(leavedFinger))
    }
    
    private func handleFingerLeaveWhenProgress(_ identifier: String) {
        guard let leavedFingerIndex = fingers.value.firstIndex(where: { $0.identifier == identifier }) else {
            return
        }
        let leavedFinger = fingers.value[leavedFingerIndex]
        leavedFingersProxy.append(leavedFinger)
        
        if fingerLeaveTimer == nil {
            fingerLeaveTimer = MilliSecondCountDownTimer(from: 1, to: 0)
            fingerLeaveTimer?.startCountdown()
            fingerLeaveTimer?.onTimeout
                .subscribe(onNext: { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    if self.leavedFingersProxy.count >= 2 {
                        self.processMultipleLeaveEndSequence()
                    } else {
                        self.processNextSequence()
                    }
                    
                    if self.numberOfUnleavedFingers <= 1, self.state.value == .progress {
                        self.processLastOneEndSequence()
                    }
                    self.fingerLeaveTimer = nil
                    self.leavedFingersProxy.removeAll()
                }).disposed(by: disposeBag)
        }
    }
}
