//
//  UIFont+Extension.swift
//  HeartBounce
//
//  Created by 안덕환 on 09/10/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    class func firaSansBoldFont(size: CGFloat) -> UIFont {
        return UIFont(name: "FiraSans-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
