//
//  AppProgressView.swift
//  AppProgress
//
//  Created by 大國嗣元 on 2018/05/19.
//  Copyright © 2018年 hideyuki. All rights reserved.
//

import UIKit

extension AppProgressView {
    private struct SettingInformation: Equatable {
        let id = UUID().uuidString
        let mark: MarkType
        let string: String
        let colorType: AppProgressColor
        let backgroundStyle: AppProgressBackgroundStyle

        init(mark: MarkType, string: String, colorType: AppProgressColor, backgroundStyle: AppProgressBackgroundStyle) {
            self.mark = mark
            self.string = string
            self.colorType = colorType
            self.backgroundStyle = backgroundStyle
        }

        public static func == (lhs: SettingInformation, rhs: SettingInformation) -> Bool {
            return lhs.mark == rhs.mark &&
                lhs.string == rhs.string &&
                lhs.colorType == rhs.colorType &&
                lhs.backgroundStyle == rhs.backgroundStyle
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
}

final class AppProgressView: UIView {
    private let fadeInAnimationDuration: TimeInterval = 0.15
    private let fadeOutAnimationDuration: TimeInterval = 0.15
    private var backgroundView: BackgroundView?
    private var stringLabel: StringLabel?
    private var markView: MarkView?
    private var colorType = AppProgressColor.whiteAndBlack
    private var backgroundStyle = AppProgressBackgroundStyle.full
    private var minimumDismissTimeInterval: TimeInterval = 0.5
    private var settingInfo: SettingInformation?

    static func create(colorType: AppProgressColor?, backgroundStyle: AppProgressBackgroundStyle?, minimumDismissTimeInterval: TimeInterval?) -> AppProgressView {
        let appProgressView = AppProgressView()
        if let colorType = colorType {
            appProgressView.colorType = colorType
        }
        if let backgroundStyle = backgroundStyle {
            appProgressView.backgroundStyle = backgroundStyle
        }
        if let minimumDismissTimeInterval = minimumDismissTimeInterval {
            appProgressView.minimumDismissTimeInterval = minimumDismissTimeInterval
        }
        return appProgressView
    }

    func displayRotationAnimation(type: MarkType, string: String) {
        let isEqual = settingInfo == SettingInformation(mark: type, string: string, colorType: colorType, backgroundStyle: backgroundStyle)

        displayAnimation(type: type, string: string, isRotation: true, animations: { [weak self] in
            if !isEqual || self?.markView?.isRotationing != true {
                self?.markView?.startRotation()
            }
            }, completion: {

        })
    }

    func displayAnimationWithDismiss(type: MarkType, string: String, completion: (() -> Void)? = nil) {
        func dismissTimeInterval(string: String) -> TimeInterval {
            return max(TimeInterval(string.count) * TimeInterval(0.06) + TimeInterval(0.5), minimumDismissTimeInterval)
        }

        displayAnimation(type: type, string: string, isRotation: false, animations: { [weak self] in
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

    func dismiss(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: fadeOutAnimationDuration, animations: { [weak self] in
            self?.setAlpha(0)
            }, completion: { [weak self] _ in
                self?.remove()

                completion?()
        })
    }

    private func displayAnimation(
        type: MarkType, string: String,
        isRotation: Bool,
        animations: @escaping () -> Void,
        completion: @escaping () -> Void) {

        let settingInfo = SettingInformation(mark: type, string: string, colorType: colorType, backgroundStyle: backgroundStyle)

        if self.settingInfo == settingInfo && (markView?.isRotationing ?? false) == isRotation {
            if let backgroundView = backgroundView {
                backgroundView.superview?.bringSubview(toFront: backgroundView)
            }

            return
        }

        let isDisplaying = backgroundView != nil
        remove(isReleaseMarkView: !(self.settingInfo == settingInfo && (markView?.isRotationing ?? false) == isRotation))

        self.settingInfo = settingInfo

        prepare()

        if isDisplaying {
            animations()
            completion()
        } else {
            setAlpha(0)
            backgroundView?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)

            UIView.animate(withDuration: fadeInAnimationDuration, delay: 0, options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState], animations: { [weak self] in
                self?.backgroundView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                self?.setAlpha(1)

                animations()
                }, completion: { finished in
                    completion()
            })
        }
    }

    private func remove(isReleaseMarkView: Bool = true) {
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

    private func setAlpha(_ alpha: CGFloat) {
        markView?.alpha = alpha
        backgroundView?.alpha = alpha
        stringLabel?.alpha = alpha
    }

    private func prepare() {
        guard let settingInfo = settingInfo else { return }

        //アニメーションが続いていなければ再作成
        if !(markView?.isRotationing ?? false) {
            markView = MarkView(type: settingInfo.mark, tintColor: colorType.tintColor)
        }

        backgroundView = BackgroundView(backgroundColor: colorType.backgroundColor)

        stringLabel = StringLabel(string: settingInfo.string, tintColor: colorType.tintColor)

        guard let markView = markView, let backgroundView = backgroundView, let stringLabel = stringLabel else {
            return
        }

        self.addSubview(backgroundView)
        backgroundView.addSubview(markView)
        backgroundView.addSubview(stringLabel)

        setAnchor()

        self.backgroundColor = .clear
        self.isUserInteractionEnabled = settingInfo.backgroundStyle != .none
    }

    private func setAnchor() {
        guard let settingInfo = settingInfo, let markView = markView, let backgroundView = backgroundView, let stringLabel = stringLabel, let view = backgroundView.superview else {
            return
        }

        stringLabel.setAnchor(spaceMarkAndLabel: settingInfo.spaceMarkAndLabel, markImageSize: settingInfo.markImageSize, backgroundStyle: settingInfo.backgroundStyle, viewSize: view.frame.size)

        backgroundView.setAnchor(markOriginalSize: settingInfo.mark.size, backgroundStyle: settingInfo.backgroundStyle, stringLabel: stringLabel)

        markView.setAnchor(spaceMarkAndLabel: settingInfo.spaceMarkAndLabel, markImageSize: settingInfo.markImageSize, stringLabel: stringLabel)
    }
}

extension AppProgressView: AnimationDelayable {}
