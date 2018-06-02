//
//  AppProgressView.swift
//  AppProgress
//
//  Created by 大國嗣元 on 2018/05/19.
//  Copyright © 2018年 hideyuki. All rights reserved.
//

import UIKit

open class AppProgressView: UIView {
    private let fadeInAnimationDuration: TimeInterval = 0.15
    private let fadeOutAnimationDuration: TimeInterval = 0.15
    private var backgroundView: BackgroundView?
    private var stringLabel: StringLabel?
    private var markView: MarkView?
    private var colorType = AppProgress.ColorType.whiteAndBlack
    private var backgroundStyle = AppProgress.BackgroundStyle.full
    private var minimumDismissTimeInterval: TimeInterval = 0.5
    private var settingInfo: SettingInformation?
}

extension AppProgressView {
    open static func create(colorType: AppProgress.ColorType? = nil, backgroundStyle: AppProgress.BackgroundStyle? = nil, minimumDismissTimeInterval: TimeInterval? = nil) -> AppProgressView {
        let appProgressView = AppProgressView()
        appProgressView.update(colorType: colorType, backgroundStyle: backgroundStyle, minimumDismissTimeInterval: minimumDismissTimeInterval)
        return appProgressView
    }

    open func add(to view: UIView) {
        view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }

    open func update(colorType: AppProgress.ColorType? = nil, backgroundStyle: AppProgress.BackgroundStyle? = nil, minimumDismissTimeInterval: TimeInterval? = nil) {
        if let colorType = colorType {
            self.colorType = colorType
        }
        if let backgroundStyle = backgroundStyle {
            self.backgroundStyle = backgroundStyle
        }
        if let minimumDismissTimeInterval = minimumDismissTimeInterval {
            self.minimumDismissTimeInterval = minimumDismissTimeInterval
        }
    }

    open func show(string: String = "") {
        startRotation(type: .loading, string: string)
    }

    open func done(string: String = "", completion: (() -> Void)? = nil) {
        startDismissAnimation(type: .done, string: string, completion: completion)
    }

    open func info(string: String = "", completion: (() -> Void)? = nil) {
        startDismissAnimation(type: .info, string: string, completion: completion)
    }

    open func err(string: String = "", completion: (() -> Void)? = nil) {
        startDismissAnimation(type: .err, string: string, completion: completion)
    }

    open func custom(image: UIImage?, imageRenderingMode: UIImageRenderingMode = .alwaysTemplate, string: String = "", isRotation: Bool = false, completion: (() -> Void)? = nil) {
        if isRotation {
            startRotation(type: .custom(image, imageRenderingMode), string: string)
        } else {
            startDismissAnimation(type: .custom(image, imageRenderingMode), string: string, completion: completion)
        }
    }

    open func dismiss(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: fadeOutAnimationDuration, animations: { [weak self] in
            self?.setAlpha(0)
            }, completion: { [weak self] _ in
                self?.remove()
                completion?()
        })
    }
}

private extension AppProgressView {
    struct SettingInformation: Equatable {
        let id = UUID().uuidString
        let mark: MarkType
        let string: String
        let colorType: AppProgress.ColorType
        let backgroundStyle: AppProgress.BackgroundStyle

        init(mark: MarkType, string: String, colorType: AppProgress.ColorType, backgroundStyle: AppProgress.BackgroundStyle) {
            self.mark = mark
            self.string = string
            self.colorType = colorType
            self.backgroundStyle = backgroundStyle
        }

        var markImageSize: CGSize {
            switch backgroundStyle {
            case .full, .none, .customFull( _, _, _, _):
                return mark.size
            }
        }

        var spaceMarkAndLabel: CGFloat {
            return (mark.size.height - markImageSize.height) / 3
        }
    }

    func startRotation(type: MarkType, string: String) {
        let isEqual = settingInfo == SettingInformation(mark: type, string: string, colorType: colorType, backgroundStyle: backgroundStyle)

        start(type: type, string: string, isRotation: true, animations: { [weak self] in
            if !isEqual || self?.markView?.isRotationing != true {
                self?.markView?.startRotation()
            }
        })
    }

    func startDismissAnimation(type: MarkType, string: String, completion: (() -> Void)?) {
        func dismissTimeInterval(string: String) -> TimeInterval {
            return max(TimeInterval(string.count) * TimeInterval(0.06) + TimeInterval(0.5), minimumDismissTimeInterval)
        }

        start(type: type, string: string, isRotation: false, animations: { [weak self] in
            guard let `self` = self else { return }

            if let count = self.markView?.animationImages?.count, count > 0 {
                self.markView?.animationDuration = self.fadeInAnimationDuration
                self.markView?.startAnimating()
            }
            }, completion: { [weak self] in
                guard let `self` = self else { return }

                let dismissId = self.settingInfo?.id
                self.delayStart(second: dismissTimeInterval(string: string), animations: {() -> Void in
                    if let id = self.settingInfo?.id, id == dismissId {
                        self.dismiss(completion: completion)
                    }
                })
        })
    }

    func start(type: MarkType, string: String,
                       isRotation: Bool,
                       animations: @escaping () -> Void,
                       completion: (() -> Void)? = nil) {
        let settingInfo = SettingInformation(mark: type, string: string, colorType: colorType, backgroundStyle: backgroundStyle)

        if self.settingInfo == settingInfo && (markView?.isRotationing ?? false) == isRotation {
            if let backgroundView = backgroundView {
                self.bringSubview(toFront: backgroundView)
            }

            return
        }

        let isDisplaying = backgroundView != nil
        remove(isReleaseMarkView: !(self.settingInfo == settingInfo && (markView?.isRotationing ?? false) == isRotation))

        self.settingInfo = settingInfo

        prepare()

        if isDisplaying {
            animations()
            completion?()
        } else {
            setAlpha(0)
            backgroundView?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)

            UIView.animate(withDuration: fadeInAnimationDuration, delay: 0, options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState], animations: { [weak self] in
                self?.backgroundView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                self?.setAlpha(1)

                animations()
                }, completion: { finished in
                    completion?()
            })
        }
    }

    func remove(isReleaseMarkView: Bool = true) {
        settingInfo = nil

        markView?.removeFromSuperview()

        //同じ画像が呼ばれた時はアニメーションを継続するために解放しない
        if isReleaseMarkView {
            markView?.releaseAll()
            markView = nil
        }

        backgroundView?.releaseAll()
        backgroundView = nil

        stringLabel?.releaseAll()
        stringLabel = nil
    }

    func setAlpha(_ alpha: CGFloat) {
        markView?.alpha = alpha
        backgroundView?.alpha = alpha
        stringLabel?.alpha = alpha
    }

    func prepare() {
        guard let settingInfo = settingInfo else { return }

        //アニメーションが続いていなければ再作成
        if markView?.isRotationing != true {
            markView = MarkView(type: settingInfo.mark, tintColor: colorType.tintColor)
        }

        backgroundView = BackgroundView(backgroundColor: colorType.backgroundColor)

        stringLabel = StringLabel(string: settingInfo.string, tintColor: colorType.tintColor)

        guard let markView = markView, let backgroundView = backgroundView, let stringLabel = stringLabel else { return }

        self.addSubview(backgroundView)
        backgroundView.addSubview(markView)
        backgroundView.addSubview(stringLabel)

        setAnchor()

        self.backgroundColor = .clear
        self.isUserInteractionEnabled = settingInfo.backgroundStyle != .none
    }

    func setAnchor() {
        guard let settingInfo = settingInfo,
            let markView = markView,
            let backgroundView = backgroundView,
            let stringLabel = stringLabel else { return }

        stringLabel.setAnchor(backgroundView: backgroundView, spaceMarkAndLabel: settingInfo.spaceMarkAndLabel, markImageSize: settingInfo.markImageSize, backgroundStyle: settingInfo.backgroundStyle, viewSize: self.frame.size)

        backgroundView.setAnchor(view: self, markOriginalSize: settingInfo.mark.size, backgroundStyle: settingInfo.backgroundStyle, stringLabel: stringLabel)

        markView.setAnchor(backgroundView: backgroundView, spaceMarkAndLabel: settingInfo.spaceMarkAndLabel, markImageSize: settingInfo.markImageSize, stringLabel: stringLabel)
    }
}

extension AppProgressView: AnimationDelayable {}
