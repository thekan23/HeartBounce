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
    let color: UIColor
    let identifier: String
    var currentPoint: CGPoint
    lazy var indicator: UIView = {
        let frame = CGRect(origin: currentPoint, size: CGSize(width: 60, height: 60))
        let v = UIView(frame: frame)
        v.backgroundColor = color
        return v
    }()
}
