//
//  AppProgress.swift
//
//  Created by hideyuki okuni on 2016/11/02.
//  Copyright © 2016年 hideyuki. All rights reserved.
//

import Foundation
import UIKit

open class AppProgress {
    private static var colorType: AppProgressColor?
    private static var backgroundStyle: AppProgressBackgroundStyle?
    private static var minimumDismissTimeInterval: TimeInterval?
    private static var appProgressView: AppProgressView?
    
    private static func syncMain(block: () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync() { () -> Void in
                block()
            }
        }
    }

    private static func add(view: UIView) {
        guard appProgressView == nil else { return }
        appProgressView = AppProgressView.create(colorType: colorType, backgroundStyle: backgroundStyle, minimumDismissTimeInterval: minimumDismissTimeInterval)
        if let appProgressView = appProgressView {
            view.addSubview(appProgressView)
            appProgressView.translatesAutoresizingMaskIntoConstraints = false
            view.topAnchor.constraint(equalTo: appProgressView.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: appProgressView.bottomAnchor).isActive = true
            view.leadingAnchor.constraint(equalTo: appProgressView.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: appProgressView.trailingAnchor).isActive = true
        }
    }

    private static func remove() {
        appProgressView?.removeFromSuperview()
        appProgressView = nil
    }
}

extension AppProgress {
    open static func setColorType(type: AppProgressColor) {
        colorType = type
    }

    open static func setBackgroundStyle(style: AppProgressBackgroundStyle) {
        backgroundStyle = style
    }

    open static func setMinimumDismissTimeInterval(timeInterval: TimeInterval) {
        minimumDismissTimeInterval = timeInterval
    }

    open static func show(view: UIView, string: String = "") {
        syncMain {
            add(view: view)
            appProgressView?.displayRotationAnimation(type: .loading, string: string)
        }
    }

    open static func done(view: UIView, string: String = "", completion: (() -> Void)? = nil) {
        syncMain {
            add(view: view)
            appProgressView?.displayAnimationWithDismiss(type: .done, string: string, completion: {
                remove()
                completion?()
            })
        }
    }

    open static func info(view: UIView, string: String = "", completion: (() -> Void)? = nil) {
        syncMain {
            add(view: view)
            appProgressView?.displayAnimationWithDismiss(type: .info, string: string, completion: {
                remove()
                completion?()
            })
        }
    }

    open static func err(view: UIView, string: String = "", completion: (() -> Void)? = nil) {
        syncMain {
            add(view: view)
            appProgressView?.displayAnimationWithDismiss(type: .err, string: string, completion: {
                remove()
                completion?()
            })
        }
    }

    open static func custom(view: UIView, image: UIImage?, imageRenderingMode: UIImageRenderingMode = .alwaysTemplate, string: String = "", isRotation: Bool = false, completion: (() -> Void)? = nil) {
        syncMain {
            add(view: view)
            if isRotation {
                appProgressView?.displayRotationAnimation(type: .custom(image, imageRenderingMode), string: string)
            } else {
                appProgressView?.displayAnimationWithDismiss(type: .custom(image, imageRenderingMode), string: string, completion: {
                    remove()
                    completion?()
                })
            }
        }
    }

    open static func dismiss(completion: (() -> Void)? = nil) {
        syncMain {
            appProgressView?.dismiss(completion: {
                remove()
                completion?()
            })
        }
    }
}
