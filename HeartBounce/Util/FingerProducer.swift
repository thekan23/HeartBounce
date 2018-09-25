//
//  FingerProducer.swift
//  HeartBounce
//
//  Created by 안덕환 on 23/09/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation
import UIKit


class FingerProducer {
    var producedColors: [UIColor] = []
    
    func produce(identifier: String, point: CGPoint) -> Finger {
        let finger = Finger(
            color: UIColor.random(),
            identifier: identifier,
            currentPoint: point,
            isLeaved: false)
        return finger
    }
}
