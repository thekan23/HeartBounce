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
        case wait
        case progress
        case ended
    }
    
    let viewAction = PublishSubject<ViewAction>()
    let fingers = Variable<[Finger]>([])
    let state = Variable<State>(.wait)
    let fingerProducer = FingerProducer()
    
    func requestAppendFinger(at pointt: CGPoint, with identifier: String) {
        guard fingers.value.contains(where: { $0.identifier == identifier }) else {
            return
        }
        let finger = fingerProducer.produce(identifier: identifier, point: pointt)
        fingers.value.append(finger)
        viewAction.onNext(.createFinger(finger))
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
