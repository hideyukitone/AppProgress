//
//  AnimationDelayable.swift
//  AppProgress
//
//  Created by 大國嗣元 on 2018/05/19.
//  Copyright © 2018年 hideyuki. All rights reserved.
//

import Foundation

protocol AnimationDelayable {
    func delayStart(second: Double, animations: @escaping () -> Void)
}

extension AnimationDelayable {
    func delayStart(second: Double, animations: @escaping () -> Void) {
        let dispatchTime = DispatchTime.now() + Double(Int64(second * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            animations()
        })
    }
}
