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
        case updateFingerPositions([Finger])
    }
    
    enum State {
        case wait
        case progress
        case ended
    }
    
    let fingers = Variable<[Finger]>([])
    let state = Variable<State>(.wait)
    
    func requestAppendFinger(at pointt: CGPoint, with identifier: String) {
        guard fingers.value.contains(where: { $0.identifier == identifier }) else {
            return
        }
        
    }
    
    func requestUpdateFinger(at point: CGPoint, with identifier: String) {
        
    }
    
    func leaveFinger(with identifier: String) {
        
    }
}
