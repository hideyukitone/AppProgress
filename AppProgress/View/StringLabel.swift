//
//  StringLabel.swift
//  AppProgress
//
//  Created by 大國嗣元 on 2018/05/19.
//  Copyright © 2018年 hideyuki. All rights reserved.
//

import UIKit

final class StringLabel: UILabel, ViewReleasable {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(string: String, tintColor: UIColor?) {
        super.init(frame: .zero)

        self.numberOfLines = 0
        self.text = string
        self.textColor = tintColor
        self.font = UIFont.systemFont(ofSize: 15)
        self.textAlignment = .center
        self.isUserInteractionEnabled = false
    }

    private var widthLabelAnchor: NSLayoutConstraint?
    private var heightLabelAnchor: NSLayoutConstraint?
    func setAnchor(spaceMarkAndLabel: CGFloat, markImageSize: CGSize, backgroundStyle: AppProgress.BackgroundStyle, viewSize: CGSize) {
        guard let backgroundView = self.superview else { return }

        self.frame.size = .zero

        if self.text != "" {
            self.frame.size = .zero
            self.sizeToFit()
        }

        var maxLabelWidth: CGFloat {
            let space: CGFloat = 70

            switch backgroundStyle {
            case .full, .none:
                return viewSize.width - space
            case .customFull( _, _, let leading, let trailing):
                return viewSize.width - leading - trailing - space
            }
        }

        if self.frame.size.width > maxLabelWidth {
            let size = CGSize(width: maxLabelWidth, height: self.frame.size.height)
            self.frame.size = self.sizeThatFits(size)
            self.lineBreakMode = .byWordWrapping
        }

        self.translatesAutoresizingMaskIntoConstraints = false

        self.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: markImageSize.height / 2 + spaceMarkAndLabel).isActive = true

        if let widthLabelAnchor = widthLabelAnchor, let heightLabelAnchor = heightLabelAnchor {
            widthLabelAnchor.constant = self.frame.size.width
            heightLabelAnchor.constant = self.frame.size.height
        } else {
            widthLabelAnchor = self.widthAnchor.constraint(equalToConstant: self.frame.size.width)
            widthLabelAnchor?.isActive = true

            heightLabelAnchor = self.heightAnchor.constraint(equalToConstant: self.frame.size.height)
            heightLabelAnchor?.isActive = true
        }
    }
}
