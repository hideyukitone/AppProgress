//
//  AppProgress+.swift
//
//  Created by hideyuki okuni on 2016/11/02.
//  Copyright © 2016年 hideyuki. All rights reserved.
//

import Foundation
import UIKit

extension AppProgress {
    static func show(string: String = "") {
        guard let window = window else { return }
        
        show(view: window, string: string)
    }
    
    static func done(string: String = "", completion: (() -> Void)? = nil) {
        guard let window = window else { return }
        
        done(view: window, string: string, completion: completion)
    }
    
    static func info(string: String = "", completion: (() -> Void)? = nil) {
        guard let window = window else { return }
        
        info(view: window, string: string, completion: completion)
    }
    
    static func err(string: String = "", completion: (() -> Void)? = nil) {
        guard let window = window else { return }
        
        err(view: window, string: string, completion: completion)
    }
    
    static func custom(image: UIImage?, imageRenderingMode: UIImageRenderingMode = .alwaysTemplate, string: String = "", isRotation: Bool = false, completion: (() -> Void)? = nil) {
        guard let window = window else { return }
        
        custom(view: window, image: image, imageRenderingMode: imageRenderingMode, string: string, isRotation: isRotation, completion: completion)
    }
    
    private static var window: UIWindow? {
        for window in UIApplication.shared.windows where !window.isHidden && window.alpha > 0 && window.screen == UIScreen.main && window.windowLevel == UIWindowLevelNormal {
            return window
        }
        
        return nil
    }
}
