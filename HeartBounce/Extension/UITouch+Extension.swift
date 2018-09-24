//
//  UITouch+Extension.swift
//  HeartBounce
//
//  Created by 안덕환 on 24/09/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import UIKit


extension UITouch {
    var identifier: String {
        return String(format: "%p", self)
    }
}
