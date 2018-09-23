//
//  ViewController.swift
//  HeartBounce
//
//  Created by 안덕환 on 22/09/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class HeartBounceViewController: UIViewController, Bindable {
    typealias ViewModelType = HeartBounceViewModel
    
    var viewModel: HeartBounceViewModel!
    
    func bindViewModel() {
        
    }
    
    var positions: [CGPoint] = []
    var colors: [UIColor] = [.red, .blue]
    var views: [UIView] = []
    
    var numberOfFingers: Int {
        return positions.count
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: view)
            positions.append(location)
            configureCircleView(at: location)
        }
    }
    
    private func configureCircleView(at point: CGPoint) {
        let v = UIView(frame: CGRect(origin: point, size: CGSize(width: 60, height: 60)))
        v.backgroundColor = .red
        v.layer.cornerRadius = 30
        v.layer.masksToBounds = true
        
        views.append(v)
        view.addSubview(v)
        
        v.snp.makeConstraints {
            $0.center.equalTo(point)
            $0.width.equalTo(60)
            $0.height.equalTo(60)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let point = t.location(in: view)
            guard let index = positions.firstIndex(of: point) else {
                return
            }
            positions[index] = point
            let v = views[index]
            v.snp.updateConstraints {
                $0.center.equalTo(point)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches ended")
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches cancel")
    }
}

