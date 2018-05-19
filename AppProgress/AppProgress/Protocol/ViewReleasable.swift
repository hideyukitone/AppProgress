//
//  ViewReleasable.swift
//  AppProgress
//
//  Created by 大國嗣元 on 2018/05/19.
//  Copyright © 2018年 hideyuki. All rights reserved.
//

import UIKit

protocol ViewReleasable {
    func releaseAll()
}

extension ViewReleasable where Self: UIView {
    func releaseAll() {
        self.removeFromSuperview()
        self.isHidden = true

        if let imageView = self as? UIImageView {
            imageView.stopAnimating()
            imageView.image = nil
            imageView.animationImages = nil
        }
    }
}
