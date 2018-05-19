//
//  ViewRotationable.swift
//  AppProgress
//
//  Created by 大國嗣元 on 2018/05/19.
//  Copyright © 2018年 hideyuki. All rights reserved.
//

import UIKit

protocol ViewRotationable {
    var forKey: String { get }
    func startRotation()
    func stopRotation()
    var isRotationing: Bool { get }
}

extension ViewRotationable where Self: UIView {
    var forKey: String {
        return "loadingAnimation"
    }

    func startRotation() {
        self.stopRotation()

        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = CGFloat(Double.pi) * 2
        animation.duration = 1.17
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.repeatCount = MAXFLOAT
        animation.isCumulative = true
        animation.autoreverses = false
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false

        self.layer.add(animation, forKey: forKey)
    }

    func stopRotation() {
        self.layer.removeAnimation(forKey: forKey)
    }

    var isRotationing: Bool {
        return self.layer.animationKeys()?.filter({$0 == forKey}).count ?? 0 > 0
    }
}
