//
//  MarkType.swift
//  AppProgress
//
//  Created by 大國嗣元 on 2018/05/19.
//  Copyright © 2018年 hideyuki. All rights reserved.
//

import UIKit

enum MarkType: Equatable {
    case loading
    case done
    case err
    case info
    case custom(UIImage?, UIImageRenderingMode)

    var size: CGSize {
        return CGSize(width: 60, height: 60)
    }
}
