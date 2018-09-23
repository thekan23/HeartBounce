//
//  RootViewController.swift
//  HeartBounce
//
//  Created by 안덕환 on 23/09/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation
import UIKit

class RootViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let identifier = segue.identifier else {
            return
        }
        
        switch identifier {
        case "HeartBounce":
            guard let vc = segue.destination as? HeartBounceViewController else {
                return
            }
            let vm = HeartBounceViewModel()
            vc.bindViewModel(to: vm)
        default:
            break
        }
    }
}
