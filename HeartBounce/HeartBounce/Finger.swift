//
//  Finger.swift
//  HeartBounce
//
//  Created by 안덕환 on 23/09/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation
import UIKit


struct Finger {
    
    enum State {
        case none, leaved, caught
    }
    
    let color: UIColor
    let identifier: String
    var currentPoint: CGPoint
    var state: State = .none
}
