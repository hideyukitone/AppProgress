//
//  AppProgress.swift
//
//  Created by hideyuki okuni on 2016/11/02.
//  Copyright © 2016年 hideyuki. All rights reserved.
//

import Foundation
import UIKit

open class AppProgress {
    private static var colorType: ColorType?
    private static var backgroundStyle: BackgroundStyle?
    private static var minimumDismissTimeInterval: TimeInterval?
    private static var appProgressView: AppProgressView?
}

public extension AppProgress {
    static func set(colorType: ColorType) {
        self.colorType = colorType
    }

    static func set(backgroundStyle: BackgroundStyle) {
        self.backgroundStyle = backgroundStyle
    }

    static func set(minimumDismissTimeInterval: TimeInterval) {
        self.minimumDismissTimeInterval = minimumDismissTimeInterval
    }

    static func show(view: UIView, string: String = "") {
        syncMain {
            add(view: view)
            appProgressView?.show(string: string)
        }
    }

    static func done(view: UIView, string: String = "", completion: (() -> Void)? = nil) {
        syncMain {
            add(view: view)
            appProgressView?.done(string: string, completion: {
                remove()
                completion?()
            })
        }
    }

    static func info(view: UIView, string: String = "", completion: (() -> Void)? = nil) {
        syncMain {
            add(view: view)
            appProgressView?.info(string: string, completion: {
                remove()
                completion?()
            })
        }
    }

    static func err(view: UIView, string: String = "", completion: (() -> Void)? = nil) {
        syncMain {
            add(view: view)
            appProgressView?.err(string: string, completion: {
                remove()
                completion?()
            })
        }
    }

    static func custom(view: UIView, image: UIImage?, imageRenderingMode: UIImageRenderingMode = .alwaysTemplate, string: String = "", isRotation: Bool = false, completion: (() -> Void)? = nil) {
        syncMain {
            add(view: view)
            appProgressView?.custom(image: image, imageRenderingMode: imageRenderingMode, string: string, isRotation: isRotation, completion: {
                remove()
                completion?()
            })
        }
    }

    static func dismiss(completion: (() -> Void)? = nil) {
        syncMain {
            appProgressView?.dismiss(completion: {
                remove()
                completion?()
            })
        }
    }
}

private extension AppProgress {
    static func syncMain(block: () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync() { () -> Void in
                block()
            }
        }
    }

    static func add(view: UIView) {
        guard appProgressView == nil else { return }
        appProgressView = AppProgressView.create(colorType: colorType, backgroundStyle: backgroundStyle, minimumDismissTimeInterval: minimumDismissTimeInterval)
        appProgressView?.add(to: view)
    }

    static func remove() {
        appProgressView?.removeFromSuperview()
        appProgressView = nil
    }
}
