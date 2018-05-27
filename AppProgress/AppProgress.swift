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

extension AppProgress {
    open static func set(colorType: ColorType) {
        self.colorType = colorType
    }

    open static func set(backgroundStyle: BackgroundStyle) {
        self.backgroundStyle = backgroundStyle
    }

    open static func set(minimumDismissTimeInterval: TimeInterval) {
        self.minimumDismissTimeInterval = minimumDismissTimeInterval
    }

    open static func show(view: UIView, string: String = "") {
        syncMain {
            add(view: view)
            appProgressView?.show(string: string)
        }
    }

    open static func done(view: UIView, string: String = "", completion: (() -> Void)? = nil) {
        syncMain {
            add(view: view)
            appProgressView?.done(string: string, completion: {
                remove()
                completion?()
            })
        }
    }

    open static func info(view: UIView, string: String = "", completion: (() -> Void)? = nil) {
        syncMain {
            add(view: view)
            appProgressView?.info(string: string, completion: {
                remove()
                completion?()
            })
        }
    }

    open static func err(view: UIView, string: String = "", completion: (() -> Void)? = nil) {
        syncMain {
            add(view: view)
            appProgressView?.err(string: string, completion: {
                remove()
                completion?()
            })
        }
    }

    open static func custom(view: UIView, image: UIImage?, imageRenderingMode: UIImageRenderingMode = .alwaysTemplate, string: String = "", isRotation: Bool = false, completion: (() -> Void)? = nil) {
        syncMain {
            add(view: view)
            appProgressView?.custom(image: image, imageRenderingMode: imageRenderingMode, string: string, isRotation: isRotation, completion: {
                remove()
                completion?()
            })
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
        if let appProgressView = appProgressView {
            view.addSubview(appProgressView)
            appProgressView.translatesAutoresizingMaskIntoConstraints = false
            view.topAnchor.constraint(equalTo: appProgressView.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: appProgressView.bottomAnchor).isActive = true
            view.leadingAnchor.constraint(equalTo: appProgressView.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: appProgressView.trailingAnchor).isActive = true
        }
    }

    static func remove() {
        appProgressView?.removeFromSuperview()
        appProgressView = nil
    }
}
