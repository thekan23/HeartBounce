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
    let disposeBag = DisposeBag()
    let timer = CountDownTimer(from: 5, to: 0)
    
    init() {
        timer.countDown
            .subscribe(onNext: { [weak self] count in
                print("count: \(count)")
                guard let `self` = self else {
                    return
                }
                guard self.state.value == .wait else {
                    return
                }
                if count == 0 {
                    print("game start")
                    self.state.value = .progress
                }
            }).disposed(by: disposeBag)
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
        timer.count()
    }
    
    func requestUpdateFinger(at point: CGPoint, with identifier: String) {
        guard let fingerIndex = fingers.value.firstIndex(where: { $0.identifier == identifier }) else {
            return
        }
        fingers.value[fingerIndex].currentPoint = point
        viewAction.onNext(.updateFingerPositions)
    }
    
    func leaveFinger(with identifier: String) {
        guard let fingerIndex = fingers.value.firstIndex(where: { $0.identifier == identifier }) else {
            return
        }
        let finger = fingers.value.remove(at: fingerIndex)
        viewAction.onNext(.leaveFinger(finger))
    }
}
