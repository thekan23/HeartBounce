//
//  HeartBounceView.swift
//  HeartBounce
//
//  Created by 안덕환 on 08/10/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import SnapKit

class HeartBounceView: UIView {
    typealias Class = HeartBounceView
    
    var externalIndicator: NVActivityIndicatorView!
    var innerIndicator: NVActivityIndicatorView!
    
    static var externalFrame: CGRect {
        return CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
    }
    
    static var innerFrame: CGRect {
        return CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
    }
    
    convenience init(color: UIColor) {
        self.init(frame: Class.externalFrame)
        setupIndicatorViews(with: color)
    }
    
    func startAnimating() {
        externalIndicator.startAnimating()
        innerIndicator.startAnimating()
    }
    
    func stopAnimation() {
        externalIndicator.stopAnimating()
        innerIndicator.stopAnimating()
    }
}

extension HeartBounceView {
    private func setupIndicatorViews(with color: UIColor) {
        externalIndicator = NVActivityIndicatorView(
            frame: Class.externalFrame,
            type: .circleStrokeSpin,
            color: color,
            padding: nil)
        innerIndicator = NVActivityIndicatorView(
            frame: Class.innerFrame,
            type: .ballScaleMultiple,
            color: color,
            padding: nil)
        
        addSubview(externalIndicator)
        addSubview(innerIndicator)
        
        externalIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        innerIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
