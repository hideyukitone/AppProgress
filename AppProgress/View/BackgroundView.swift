//
//  BackgroundView.swift
//  AppProgress
//
//  Created by 大國嗣元 on 2018/05/19.
//  Copyright © 2018年 hideyuki. All rights reserved.
//

import UIKit

final class BackgroundView: UIView, ViewReleasable, AnimationDelayable {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(backgroundColor: UIColor?) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.isUserInteractionEnabled = false
    }

    func setAnchor(markOriginalSize: CGSize, backgroundStyle: AppProgress.BackgroundStyle, stringLabel: StringLabel) {
        guard let view = self.superview else {
            return
        }

        self.translatesAutoresizingMaskIntoConstraints = false

        switch backgroundStyle {
        case .none:
            self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            self.backgroundColor = .clear
        case .full:
            self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        case .customFull(let top, let bottom, let leading, let trailing):
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: top).isActive = true
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom).isActive = true
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading).isActive = true
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailing).isActive = true
        }
    }
}
