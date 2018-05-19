//
//  AppProgressBackgroundStyle.swift
//  AppProgress
//
//  Created by 大國嗣元 on 2018/05/19.
//  Copyright © 2018年 hideyuki. All rights reserved.
//

import UIKit

public enum AppProgressBackgroundStyle: Equatable {
    case none
    case full
    case customFull(top: CGFloat, bottom: CGFloat, leading: CGFloat, trailing: CGFloat)

    public static func == (lhs: AppProgressBackgroundStyle, rhs: AppProgressBackgroundStyle) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none), (.full, .full):
            return true
        case (.customFull(let lTop, let lBottom, let lLeading, let lTrailing), .customFull(let rTop, let rBottom, let rLeading, let rTrailing)) where lTop == rTop && lBottom == rBottom && lLeading == rLeading && lTrailing == rTrailing:
            return true
        case (.none, _), (.full, _), (.customFull, _):
            return false
        }
    }
}
