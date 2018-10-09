//
//  UIWindow+Extension.swift
//  HeartBounce
//
//  Created by 안덕환 on 10/10/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {
    class var hasNotch: Bool {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        if max(height, width) / min(height, width) > 2 {
            return true
        }
        return false
    }
}
