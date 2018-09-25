//
//  MilliSecondCountDownTimer.swift
//  HeartBounce
//
//  Created by 안덕환 on 25/09/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation
import RxSwift


class MilliSecondCountDownTimer {
    let timeout = PublishSubject<Void>()
    let disposeBag = DisposeBag()
    
    private let from: Int
    private let to: Int
    private var timer: Observable<Int>?
    
    init(from: Int, to: Int) {
        self.from = from
        self.to = to
    }
    
    func count() {
        timer = Observable<Int>
            .timer(0, period: 0.1, scheduler: MainScheduler.instance)
            .take(from - to + 1)
            .map { self.from - $0 }
        
        timer?.subscribe(onNext: { [weak self] count in
            if count == 0 {
                self?.timeout.onNext(())
            }
        }).disposed(by: disposeBag)
    }
}
