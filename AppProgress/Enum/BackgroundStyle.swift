//
//  BackgroundStyle.swift
//  AppProgress
//
//  Created by 大國嗣元 on 2018/05/19.
//  Copyright © 2018年 hideyuki. All rights reserved.
//

import UIKit

public extension AppProgress {
    public enum BackgroundStyle: Equatable {
        case none
        case full
        case customFull(top: CGFloat, bottom: CGFloat, leading: CGFloat, trailing: CGFloat)
    }
}
