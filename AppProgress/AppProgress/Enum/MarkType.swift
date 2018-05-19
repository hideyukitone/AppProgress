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

    public static func == (lhs: MarkType, rhs: MarkType) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.done, .done), (.err, .err), (.info, .info):
            return true
        case (.custom(let lImage, let lMode), .custom(let rImage, let rMode)) where lImage == rImage && lMode == rMode:
            return true
        default:
            return false
        }
    }

    var size: CGSize {
        return CGSize(width: 60, height: 60)
    }
}
