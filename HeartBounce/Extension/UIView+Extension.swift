//
//  UIView+Extension.swift
//  HeartBounce
//
//  Created by 안덕환 on 09/10/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func findConstraint(for attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        let view = (attribute == .width || attribute == .height) ? self : superview
        return view?.constraints.first { $0.hasItem(self) && $0.hasAttribute(attribute) }
    }
}

extension NSLayoutConstraint {
    func hasItem(_ item: UIView) -> Bool {
        let items = [firstItem, secondItem].compactMap { $0 as? UIView }
        return items.contains(item)
    }
    
    func hasAttribute(_ attribute: NSLayoutConstraint.Attribute) -> Bool {
        return [firstAttribute, secondAttribute].contains(attribute)
    }
}
