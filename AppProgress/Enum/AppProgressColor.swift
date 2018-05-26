//
//  AppProgressColor.swift
//  AppProgress
//
//  Created by 大國嗣元 on 2018/05/19.
//  Copyright © 2018年 hideyuki. All rights reserved.
//

import UIKit

public extension AppProgress {
    public enum ColorType: Equatable {
        case blackAndWhite
        case whiteAndBlack
        case grayAndWhite
        case lightGrayAndWhite
        case custom(UIColor, UIColor) //(tintColor, backgroundColor)

        public static func == (lhs: ColorType, rhs: ColorType) -> Bool {
            return lhs.tintColor == rhs.tintColor && lhs.backgroundColor == rhs.backgroundColor
        }

        var tintColor: UIColor? {
            switch self {
            case .grayAndWhite:
                return #colorLiteral(red: 0.5176470588, green: 0.5176470588, blue: 0.5176470588, alpha: 1)
            case .whiteAndBlack:
                return .white
            case .lightGrayAndWhite:
                return #colorLiteral(red: 0.6549019608, green: 0.6509803922, blue: 0.6509803922, alpha: 1)
            case .blackAndWhite:
                return .black
            case .custom(let color, _):
                return color
            }
        }

        var backgroundColor: UIColor? {
            switch self {
            case .grayAndWhite:
                return UIColor.white.withAlphaComponent(0.99)
            case .whiteAndBlack:
                return #colorLiteral(red: 0.137254902, green: 0.137254902, blue: 0.137254902, alpha: 0.89)
            case .lightGrayAndWhite:
                return UIColor.white.withAlphaComponent(0.99)
            case .blackAndWhite:
                return UIColor.white.withAlphaComponent(0.99)
            case .custom(_, let color):
                return color
            }
        }
    }
}
