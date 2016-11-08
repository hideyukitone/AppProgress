//
//  AppProgress.swift
//
//  Created by hideyuki okuni on 2016/11/02.
//  Copyright © 2016年 hideyuki. All rights reserved.
//

import Foundation
import UIKit

open class AppProgress: ShowAppProgressAvility, EditableAppProgressProperty {
    private static let appProgressUI = AppProgressUI()
    
    //ShowAppProgressAvility
    
    open static func show(view: UIView, string: String = "", keyboardHeight: CGFloat = 0) {
        appProgressUI.displayRotationAnimation(type: .loading, view: view, string: string, keyboardHeight: keyboardHeight)
    }
    
    open static func done(view: UIView, string: String = "", keyboardHeight: CGFloat = 0, completion: (() -> Void)? = nil) {
        appProgressUI.displayAnimationWithDismiss(type: .done, view: view, string: string, keyboardHeight: keyboardHeight, completion: completion)
    }
    
    open static func info(view: UIView, string: String = "", keyboardHeight: CGFloat = 0, completion: (() -> Void)? = nil) {
        appProgressUI.displayAnimationWithDismiss(type: .info, view: view, string: string, keyboardHeight: keyboardHeight, completion: completion)
    }
    
    open static func err(view: UIView, string: String = "", keyboardHeight: CGFloat = 0, completion: (() -> Void)? = nil) {
        appProgressUI.displayAnimationWithDismiss(type: .err, view: view, string: string, keyboardHeight: keyboardHeight, completion: completion)
    }
    
    open static func custom(view: UIView, image: UIImage?, imageRenderingMode: UIImageRenderingMode = .alwaysTemplate, string: String = "", keyboardHeight: CGFloat = 0, isRotation: Bool = false, completion: (() -> Void)? = nil) {
        if isRotation {
            appProgressUI.displayRotationAnimation(type: .custom(image, imageRenderingMode), view: view, string: string, keyboardHeight: keyboardHeight)
        }else {
            appProgressUI.displayAnimationWithDismiss(type: .custom(image, imageRenderingMode), view: view, string: string, keyboardHeight: keyboardHeight, completion: completion)
        }
    }
    
    open static func dismiss(completion: (() -> Void)? = nil) {
        appProgressUI.dismiss(completion: completion)
    }
    
    //EditableAppProgressProperty
    
    open static func setColorType(type: AppProgressColor) {
        appProgressUI.setColorType(type: type)
    }
    
    open static func setBackgroundStyle(style: AppProgressBackgroundStyle) {
        appProgressUI.setBackgroundStyle(style: style)
    }
    
    open static func setMinimumDismissTimeInterval(timeInterval: TimeInterval) {
        appProgressUI.setMinimumDismissTimeInterval(timeInterval: timeInterval)
    }
}

public enum AppProgressColor {
    case blackAndWhite
    case whiteAndBlack
    case grayAndWhite
    case lightGrayAndWhite
    case custom(UIColor, UIColor) //(tintColor, backgroundColor)
    
    fileprivate var tintColor: UIColor? {
        switch self {
        case .grayAndWhite:
            return .make(hex: "848484")
        case .whiteAndBlack:
            return .white
        case .lightGrayAndWhite:
            return .make(hex: "A7A6A6")
        case .blackAndWhite:
            return .black
        case .custom(let color, _):
            return color
        }
    }
    
    fileprivate var backgroundColor: UIColor? {
        switch self {
        case .grayAndWhite:
            return UIColor.white.withAlphaComponent(0.99)
        case .whiteAndBlack:
            return .make(hex: "232323", alpha: 0.89)
        case .lightGrayAndWhite:
            return UIColor.white.withAlphaComponent(0.99)
        case .blackAndWhite:
            return UIColor.white.withAlphaComponent(0.99)
        case .custom(_, let color):
            return color
        }
    }
    
    fileprivate func isEqual(type: AppProgressColor) -> Bool {
        return self.tintColor == type.tintColor && self.backgroundColor == type.backgroundColor
    }
}

public enum AppProgressBackgroundStyle {
    case basic
    case none
    case full
    case customFull(CGFloat, CGFloat, CGFloat, CGFloat) //constant (top, bottom, leading, trailing)
    
    fileprivate func isEqual(type: AppProgressBackgroundStyle) -> Bool {
        switch self {
        case .basic:
            if case .basic = type {
                return true
            }
        case .none:
            if case .none = type {
                return true
            }
        case .full:
            if case .full = type {
                return true
            }
        case .customFull(let top1, let bottom1, let leading1, let trailing1):
            if case .customFull(let top2, let bottom2, let leading2, let trailing2) = type {
                return top1 == top2 && bottom1 == bottom2 && leading1 == leading2 && trailing1 == trailing2
            }
        }
        
        return false
    }
}

//****************************************************
// MARK: - AppProgressUI
//****************************************************

fileprivate class AppProgressUI: DelayAvility {
    var markView: MarkView?
    var backgroundView: BackgroundView?
    var stringLabel: StringLabel?
    
    func displayRotationAnimation(type: MarkType, view: UIView, string: String, keyboardHeight: CGFloat) {
        let isEqualImage = _settingInfo?.isEqualImage(setting: SettingInfomation(mark: type, string: string, colorType: colorType, backgroundStyle: backgroundStyle)) ?? false
        
        displayAnimation(type: type, view: view, string: string, keyboardHeight: keyboardHeight, isRotation: true, animations: {
            if !isEqualImage || !(self.markView?.isRotationing ?? false) {
                self.markView?.startRotation()
            }
        }, completion: { finished in
            
        })
    }
    
    func displayAnimationWithDismiss(type: MarkType, view: UIView, string: String, keyboardHeight: CGFloat, completion: (() -> Void)? = nil) {
        func dismissTimeInterval(string: String) -> TimeInterval {
            return max(TimeInterval(string.characters.count) * TimeInterval(0.06) + TimeInterval(0.5), minimumDismissTimeInterval)
        }
        
        displayAnimation(type: type, view: view, string: string, keyboardHeight: keyboardHeight, isRotation: false, animations: {
            if let count = self.markView?.animationImages?.count, count > 0 {
                self.markView?.animationDuration = self.fadeInAnimationDuration
                self.markView?.startAnimating()
            }
        }, completion: { finished in
            let dismissId = self._settingInfo?.id
            self.delayStart(second: dismissTimeInterval(string: string), animations: {() -> Void in
                if let id = self._settingInfo?.id , id == dismissId {
                    self.dismiss(completion: completion)
                }
            })
        })
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: fadeOutAnimationDuration, animations: {
            self.setAlpha(0)
        }, completion: { finished in
            self.remove()
            NotificationCenter.default.removeObserver(self)
            
            completion?()
        })
    }
    
    func setColorType(type: AppProgressColor) {
        colorType = type
    }
    
    func setBackgroundStyle(style: AppProgressBackgroundStyle) {
        backgroundStyle = style
    }
    
    func setMinimumDismissTimeInterval(timeInterval: TimeInterval) {
        minimumDismissTimeInterval = timeInterval
    }
    
    private var colorType = AppProgressColor.blackAndWhite
    private var backgroundStyle = AppProgressBackgroundStyle.basic
    private var minimumDismissTimeInterval: TimeInterval = 0.5
    
    private let fadeInAnimationDuration: TimeInterval = 0.15
    private let fadeOutAnimationDuration: TimeInterval = 0.15
    
    private var _settingInfo: SettingInfomation?
    private struct SettingInfomation {
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
        
        func isEqualImage(setting: SettingInfomation) -> Bool {
            return mark.isEqual(type: setting.mark) && colorType.tintColor == setting.colorType.tintColor
        }
        
        func isEqual(setting: SettingInfomation) -> Bool {
            return mark.isEqual(type: setting.mark) && string == setting.string && colorType.isEqual(type: setting.colorType) && backgroundStyle.isEqual(type: setting.backgroundStyle)
        }
    }
    
    private func displayAnimation(
        type: MarkType
        , view: UIView
        , string: String
        , keyboardHeight: CGFloat
        , isRotation: Bool
        , animations: @escaping () -> Void
        , completion: @escaping () -> Void) {
        
        let settingInfo = SettingInfomation(mark: type, string: string, colorType: colorType, backgroundStyle: backgroundStyle)
        
        if _settingInfo?.isEqual(setting: settingInfo) ?? false && (markView?.isRotationing ?? false) == isRotation {
            if let backgroundView = backgroundView {
                backgroundView.superview?.bringSubview(toFront: backgroundView)
            }
            
            return
        }
        
        let isDisplaying = backgroundView != nil
        
        remove(isReleaseMarkView: !(_settingInfo?.isEqualImage(setting: settingInfo) ?? false && (markView?.isRotationing ?? false) == isRotation))
        
        _settingInfo = settingInfo
        
        prepare(view: view, keyboardHeight: keyboardHeight)
        
        if isDisplaying {
            animations()
            completion()
        }else {
            setAlpha(0)
            backgroundView?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
            UIView.animate(withDuration: fadeInAnimationDuration, delay: 0, options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState], animations: {
                self.backgroundView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.setAlpha(1)
                
                animations()
            }, completion: { finished in
                completion()
            })
        }
    }
    
    private func remove(isReleaseMarkView: Bool = true) {
        _settingInfo = nil
        
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
    
    private func registNotifications() {
        NotificationCenter.default.removeObserver(self)
        
        NotificationCenter.default.addObserver(
            self
            , selector: #selector(self.setPosition(notification:))
            , name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation
            , object: nil
        )
        
        NotificationCenter.default.addObserver(
            self
            , selector: #selector(self.setPosition(notification:))
            , name: NSNotification.Name.UIApplicationDidBecomeActive
            , object: nil
        )
        
        NotificationCenter.default.addObserver(
            self
            , selector: #selector(self.setPosition(notification:))
            , name: NSNotification.Name.UIDeviceOrientationDidChange
            , object: nil
        )
        
        NotificationCenter.default.addObserver(
            self
            , selector: #selector(self.setPositionForKeyboard(notification:))
            , name: NSNotification.Name.UIKeyboardWillHide
            , object: nil
        )
        
        NotificationCenter.default.addObserver(
            self
            , selector: #selector(self.setPositionForKeyboard(notification:))
            , name: NSNotification.Name.UIKeyboardWillShow
            , object: nil
        )
    }
    
    @objc func setPosition(notification: NSNotification) {
        if let markView = markView
            , let view = backgroundView?.superview
            , let _settingInfo = _settingInfo
            , let stringLabel = stringLabel {
            stringLabel.setAnchor(markOriginalSize: _settingInfo.mark.size, markImageSize: markView.frame.size, backgroundStyle: _settingInfo.backgroundStyle, viewSize: view.frame.size)
            
            backgroundView?.setAnchor(markOriginalSize: _settingInfo.mark.size, backgroundStyle: _settingInfo.backgroundStyle, stringLabel: stringLabel, keyboardHeight: nil)
            
            markView.setAnchor(markOriginalSize: _settingInfo.mark.size, markImageSize: markView.frame.size, stringLabel: stringLabel)
        }
    }
    
    @objc func setPositionForKeyboard(notification: NSNotification) {
        var keyboardHeight: CGFloat {
            if notification.name == NSNotification.Name.UIKeyboardDidHide || notification.name == NSNotification.Name.UIKeyboardWillHide {
                return 0
            }else {
                return (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
            }
        }
        
        let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
        
        backgroundView?.move(keyboardHeight: keyboardHeight, keyboardAnimationDuration: keyboardAnimationDuration)
    }
    
    private func prepare(view: UIView, keyboardHeight: CGFloat) {
        guard let _settingInfo = _settingInfo else {
            return
        }
        
        //アニメーションが続いていなければ再作成
        if !(markView?.isRotationing ?? false) {
            markView = MarkView(type: _settingInfo.mark, tintColor: colorType.tintColor)
        }
        
        backgroundView = BackgroundView(backgroundColor: colorType.backgroundColor)
        
        stringLabel = StringLabel(string: _settingInfo.string, tintColor: colorType.tintColor)
        
        guard let markView = markView, let backgroundView = backgroundView, let stringLabel = stringLabel else {
            return
        }
        
        view.addSubview(backgroundView)
        backgroundView.addSubview(markView)
        backgroundView.addSubview(stringLabel)
        
        var markImageSize: CGSize {
            switch backgroundStyle {
            case .basic:
                if _settingInfo.string == "" {
                    return _settingInfo.mark.size
                }else {
                    return CGSize(width: (_settingInfo.mark.size.width / 4) * 3, height: (_settingInfo.mark.size.height / 4) * 3)
                }
            case .full, .none, .customFull( _, _, _, _):
                return _settingInfo.mark.size
            }
            
        }
        
        stringLabel.setAnchor(markOriginalSize: _settingInfo.mark.size, markImageSize: markImageSize, backgroundStyle: _settingInfo.backgroundStyle, viewSize: view.frame.size)
        
        backgroundView.setAnchor(markOriginalSize: _settingInfo.mark.size, backgroundStyle: _settingInfo.backgroundStyle, stringLabel: stringLabel, keyboardHeight: keyboardHeight)
        
        markView.setAnchor(markOriginalSize: _settingInfo.mark.size, markImageSize: markImageSize, stringLabel: stringLabel)
        
        func setUserInteractionEnabled(isEnabled: Bool) {
            backgroundView.isUserInteractionEnabled = isEnabled
            markView.isUserInteractionEnabled = isEnabled
            stringLabel.isUserInteractionEnabled = isEnabled
        }
        
        switch _settingInfo.backgroundStyle {
        case .none:
            setUserInteractionEnabled(isEnabled: false)
        default:
            setUserInteractionEnabled(isEnabled: true)
        }
        
        registNotifications()
    }
}

fileprivate class MarkView: UIImageView, RotationAvility, ReleaseAvility {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(type: MarkType, tintColor: UIColor?) {
        let images = type.images(tintColor: tintColor)
        
        if images.count >= 1 {
            if images.count == 1 {
                super.init(image: images.first)
            }else {
                super.init(image: images.last)
                self.animationImages = images
                self.animationRepeatCount = 1
                self.tintColor = tintColor
            }
        }else {
           super.init(image: nil)
        }
        
        self.tintColor = tintColor
    }
    
    private var forKey = "loadingAnimation"
    
    func startRotation() {
        self.stopRotation()
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = CGFloat(M_PI) * 2
        animation.duration = 1.17
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.repeatCount = MAXFLOAT
        animation.isCumulative = true
        animation.autoreverses = false
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        self.layer.add(animation, forKey: forKey)
    }
    
    func stopRotation() {
        self.layer.removeAnimation(forKey: forKey)
    }
    
    var isRotationing: Bool {
        return self.layer.animationKeys()?.filter({$0 == forKey}).count ?? 0 > 0
    }
    
    private var widthMarkLayoutConstraint: NSLayoutConstraint?
    private var heightMarkLayoutConstraint: NSLayoutConstraint?
    
    func setAnchor(markOriginalSize: CGSize, markImageSize: CGSize, stringLabel: StringLabel) {
        guard let backgroundView = self.superview else {
            return
        }
        
        var spaceMarkAndLabel: CGFloat {
            return (markOriginalSize.height - markImageSize.height) / 3
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: stringLabel.topAnchor, constant: -spaceMarkAndLabel).isActive = true
        
        if let widthMarkLayoutConstraint = widthMarkLayoutConstraint, let heightMarkLayoutConstraint = heightMarkLayoutConstraint {
            widthMarkLayoutConstraint.constant = markImageSize.width
            heightMarkLayoutConstraint.constant = markImageSize.height
        }else {
            widthMarkLayoutConstraint = self.widthAnchor.constraint(equalToConstant: markImageSize.width)
            heightMarkLayoutConstraint = self.heightAnchor.constraint(equalToConstant: markImageSize.height)
            
            widthMarkLayoutConstraint?.isActive = true
            heightMarkLayoutConstraint?.isActive = true
        }
    }
}

fileprivate class BackgroundView: UIView, ReleaseAvility, DelayAvility {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(backgroundColor: UIColor?) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
    }
    
    private var centerYLayoutConstraint: NSLayoutConstraint?
    private var widthLayoutConstraint: NSLayoutConstraint?
    private var heightLayoutConstraint: NSLayoutConstraint?
    
    func setAnchor(markOriginalSize: CGSize, backgroundStyle: AppProgressBackgroundStyle, stringLabel: StringLabel, keyboardHeight: CGFloat?) {
        let constant = constatnt_CenterYLayoutConstraint(keyboardHeight: keyboardHeight)
        
        guard let view = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        switch backgroundStyle {
        case .basic:
            let space: CGFloat = 20
            let size = CGSize(width: max(markOriginalSize.width, stringLabel.frame.size.width), height: markOriginalSize.height + stringLabel.frame.size.height)
            
            var width: CGFloat {
                if stringLabel.text == "" {
                    return size.width + space * 2
                }else {
                    return max(size.width + space * 1, markOriginalSize.width * 2)
                }
            }
            var height: CGFloat {
                if stringLabel.text == "" {
                    return size.height + space * 2
                }else {
                    return size.height + space * 1
                }
            }
            
            if let centerYLayoutConstraint = centerYLayoutConstraint
                , let widthLayoutConstraint = widthLayoutConstraint
                , let heightLayoutConstraint = heightLayoutConstraint {
                centerYLayoutConstraint.constant = constant
                widthLayoutConstraint.constant = width
                heightLayoutConstraint.constant = height
            }else {
                centerYLayoutConstraint = self.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant)
                centerYLayoutConstraint?.isActive = true
                
                widthLayoutConstraint = self.widthAnchor.constraint(equalToConstant: width)
                widthLayoutConstraint?.isActive = true
                heightLayoutConstraint = self.heightAnchor.constraint(equalToConstant: height)
                heightLayoutConstraint?.isActive = true
            }
            
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            
            self.layer.cornerRadius = 15
        case .none:
            self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            self.backgroundColor = .clear
        case .full:
            self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        case .customFull(let top, let bottom, let leading, let trailing):
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: top).isActive = true
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom).isActive = true
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading).isActive = true
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailing).isActive = true
        }
    }
    
    private var scheduleConstant: CGFloat?
    func move(keyboardHeight: CGFloat, keyboardAnimationDuration:TimeInterval) {
        guard let centerYLayoutConstraint = centerYLayoutConstraint else {
            return
        }
        
        let constant = constatnt_CenterYLayoutConstraint(keyboardHeight: keyboardHeight)
        
        if scheduleConstant ?? centerYLayoutConstraint.constant != constant {
            scheduleConstant = constant
            
            //キーボードが出たまま前のViewControllerに戻った時の動きが不自然であったためこちらに変更
            let last = Int(keyboardAnimationDuration / 0.005)
            let diff = constant - centerYLayoutConstraint.constant
            let endConstant = constant
            
            func animationTimeInterval(total: TimeInterval, now: Int, last: Int) -> TimeInterval {
                //途中に加速してよりアニメーションらしい動きにしています。
                guard 1 <= now && now <= last else {
                    return 0
                }
                
                let avg = (total / TimeInterval(last))
                
                let hiStart = (last / 12) + 1
                let slowStart = last - (last / 12) + 1
                
                let slowTimeInterval = TimeInterval(avg * 2.5)
                let slowCount = hiStart - 1 + last - slowStart + 1
                let hiTimeInterval = (total - slowTimeInterval * TimeInterval(slowCount)) / TimeInterval(last - slowCount)
                
                var rtn: TimeInterval = 0
                for i in 1...now {
                    switch i {
                    case let int where (1 <= int && int < hiStart) || slowStart <= int:
                        rtn += slowTimeInterval
                    default:
                        rtn += hiTimeInterval
                    }
                }
                
                return rtn
            }
            
            if last >= 1 {
                for i in 1...last {
                    delayStart(second: animationTimeInterval(total: keyboardAnimationDuration, now: i, last: last), animations: {
                        //割り切れない場合に微妙に値が変わるためIntにする
                        if Int(centerYLayoutConstraint.constant + (diff / CGFloat(last)) * CGFloat(last - i + 1)) == Int(endConstant), let scheduleConstant = self.scheduleConstant, scheduleConstant == endConstant {
                            centerYLayoutConstraint.constant += diff / CGFloat(last)
                            if i == last {
                                self.scheduleConstant = nil
                            }
                        }else {
                            //他で変更があればここでは変更しない
                            self.scheduleConstant = nil
                        }
                    })
                }
            }else {
                centerYLayoutConstraint.constant = constant
            }
            
            /*
             UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: [.allowUserInteraction], animations: {
             
             if let scheduleConstant = scheduleConstant, scheduleConstant == constant {
             backgroundView?.frame.origin.y = (backgroundView?.superview?.center.y ?? 0) + constant - ((backgroundView?.frame.size.height ?? 0) / 2)
             }
             }, completion: { finished in
             if let scheduleConstant = scheduleConstant, scheduleConstant == constant {
             centerYLayoutConstraint.constant = constant
             }
             
             scheduleConstant = nil
             })
             */
        }
    }
    
    private var beforeSetKeyboardHeight: CGFloat = 0
    private func constatnt_CenterYLayoutConstraint(keyboardHeight: CGFloat?) -> CGFloat {
        let heightSuperview = self.superview?.frame.size.height ?? 0
        let activeHeight = heightSuperview - (keyboardHeight ?? beforeSetKeyboardHeight)
        let diff = heightSuperview / 2 - activeHeight / 2
        
        var constatntDef_CenterYLayoutConstraint: CGFloat {
            if keyboardHeight ?? beforeSetKeyboardHeight > 0 {
                return activeHeight / 65
            }else {
                return activeHeight / 20
            }
        }
        
        if let keyboardHeight = keyboardHeight {
            beforeSetKeyboardHeight = keyboardHeight
        }
        
        return -constatntDef_CenterYLayoutConstraint - diff
    }
}

fileprivate class StringLabel: UILabel, ReleaseAvility {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(string: String, tintColor: UIColor?) {
        super.init(frame: .zero)
        
        self.numberOfLines = 0
        self.text = string
        self.textColor = tintColor
        self.font = UIFont.systemFont(ofSize: 15)
        self.textAlignment = .center
    }
    
    private var widthLabelAnchor: NSLayoutConstraint?
    private var heightLabelAnchor: NSLayoutConstraint?
    func setAnchor(markOriginalSize: CGSize, markImageSize: CGSize, backgroundStyle: AppProgressBackgroundStyle, viewSize: CGSize) {
        guard let backgroundView = self.superview else {
            return
        }
        
        self.frame.size = .zero
        
        if self.text != "" {
            self.frame.size = .zero
            self.sizeToFit()
        }
        
        var maxLabelWidth: CGFloat {
            let space: CGFloat = 70
            
            switch backgroundStyle {
            case .basic:
                return 196.666666666667
            case .full, .none:
                return viewSize.width - space
            case .customFull( _, _, let leading, let trailing):
                return viewSize.width - leading - trailing - space
            }
        }
        
        if self.frame.size.width > maxLabelWidth {
            let size = CGSize(width: maxLabelWidth, height: self.frame.size.height)
            self.frame.size = self.sizeThatFits(size)
            self.lineBreakMode = .byWordWrapping
        }
        
        var spaceMarkAndLabel: CGFloat {
            return (markOriginalSize.height - markImageSize.height) / 3
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: markImageSize.height / 2 + spaceMarkAndLabel).isActive = true
        
        if let widthLabelAnchor = widthLabelAnchor, let heightLabelAnchor = heightLabelAnchor {
            widthLabelAnchor.constant = self.frame.size.width
            heightLabelAnchor.constant = self.frame.size.height
        }else {
            widthLabelAnchor = self.widthAnchor.constraint(equalToConstant: self.frame.size.width)
            widthLabelAnchor?.isActive = true
            
            heightLabelAnchor = self.heightAnchor.constraint(equalToConstant: self.frame.size.height)
            heightLabelAnchor?.isActive = true
        }
    }
}

//****************************************************
// MARK: - fileprivate protocol
//****************************************************

fileprivate protocol RotationAvility {
    func startRotation()
    func stopRotation()
    var isRotationing: Bool { get }
}

fileprivate protocol ReleaseAvility {
    func releaseAll()
}

fileprivate extension ReleaseAvility where Self: UIView {
    func releaseAll() {
        self.removeFromSuperview()
        self.isHidden = true
        
        if let imageView = self as? UIImageView {
            imageView.stopAnimating()
            imageView.image = nil
            imageView.animationImages = nil
        }
    }
}

fileprivate protocol DelayAvility {
    func delayStart(second: Double, animations: @escaping () -> Void)
}

fileprivate extension DelayAvility {
    func delayStart(second: Double, animations: @escaping () -> Void) {
        let dispatchTime = DispatchTime.now() + Double(Int64(second * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            animations()
        })
    }
}

fileprivate protocol ShowAppProgressAvility {
    static func show(view: UIView, string: String, keyboardHeight: CGFloat)
    static func done(view: UIView, string: String, keyboardHeight: CGFloat, completion: (() -> Void)?)
    static func info(view: UIView, string: String, keyboardHeight: CGFloat, completion: (() -> Void)?)
    static func err(view: UIView, string: String, keyboardHeight: CGFloat, completion: (() -> Void)?)
    static func custom(view: UIView, image: UIImage?, imageRenderingMode: UIImageRenderingMode, string: String, keyboardHeight: CGFloat, isRotation: Bool, completion: (() -> Void)?)
    static func dismiss(completion: (() -> Void)?)
}

fileprivate protocol EditableAppProgressProperty {
    static func setColorType(type: AppProgressColor)
    static func setBackgroundStyle(style: AppProgressBackgroundStyle)
    static func setMinimumDismissTimeInterval(timeInterval: TimeInterval)
}

//****************************************************
// MARK: - fileprivate enum
//****************************************************

fileprivate enum MarkType {
    case loading
    case done
    case err
    case info
    case custom(UIImage?, UIImageRenderingMode)
    
    var size: CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    func images(tintColor: UIColor?) -> [UIImage] {
        switch self {
        case .loading:
            return [loadingImage(tintColor: tintColor)].flatMap{$0}
        case .err:
            return [errImage(tintColor: tintColor)].flatMap{$0}
        case .done:
            return doneImages(tintColor: tintColor)
        case .info:
            return [infoImage(tintColor: tintColor)].flatMap{$0}
        case .custom(let image, let mode):
            return [image?.withRenderingMode(mode)].flatMap{$0}
        }
    }
    
    func isEqual(type: MarkType) -> Bool {
        switch self {
        case .custom(let image1, let mode1):
            if case .custom(let image2, let mode2) = type {
                return image1 == image2 && mode1 == mode2
            }
        case .done:
            if case .done = type {
                return true
            }
        case .err:
            if case .err = type {
                return true
            }
        case .info:
            if case .info = type {
                return true
            }
        case .loading:
            if case .loading = type {
                return true
            }
        }
        
        return false
    }
    
    private func infoImage(tintColor: UIColor?) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let space: CGFloat = 13
        let bounds = CGRect(x: space, y: space, width: size.width - space * 2, height: size.height - space * 2)
        let center = CGPoint(x: bounds.origin.x + bounds.size.width / 2, y: bounds.origin.y + bounds.size.height / 2)
        let radius = min(bounds.size.width, bounds.size.height) / 2
        
        let path = UIBezierPath()
        
        path.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI) * 2, clockwise: true)
        path.close()
        
        let topSpace: CGFloat = 8
        path.move(to: CGPoint(x: center.x, y: space + topSpace))
        path.addLine(to: CGPoint(x: center.x, y: space + topSpace))
        path.close()
        
        path.move(to: CGPoint(x: center.x, y: space + topSpace + 5))
        path.addLine(to: CGPoint(x: center.x, y: size.height - space - topSpace))
        path.close()
        
        tintColor?.setStroke()
        
        path.lineJoinStyle = .round
        path.lineCapStyle = .round
        path.lineWidth = 2
        path.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.withRenderingMode(.alwaysTemplate)
    }
    
    private func doneImages(tintColor: UIColor?) -> [UIImage] {
        enum LineType {
            case left(CGFloat)
            case leftEnd
            case right(CGFloat)
            case rightEnd
            
            static var leftStartx: CGFloat {
                return 12.6
            }
            
            static var leftEndx: CGFloat {
                return 23.2
            }
            
            static var rightStartx: CGFloat {
                return 22.2
            }
            
            static var rightEndx: CGFloat {
                return 47.14
            }
            
            func addLine(path: UIBezierPath) {
                switch self {
                case .left(let x):
                    addLineLeft(path: path, x: x)
                case .leftEnd:
                    addLineLeft(path: path, x: LineType.leftEndx)
                case .right(let x):
                    addLineLeft(path: path, x: LineType.leftEndx)
                    addLineRight(path: path, x: x)
                case .rightEnd:
                    addLineLeft(path: path, x: LineType.leftEndx)
                    addLineRight(path: path, x: LineType.rightEndx)
                }
            }
            
            private func addLineLeft(path: UIBezierPath, x: CGFloat) {
                path.move(to: leftDoneImagePoint(x: LineType.leftStartx))
                path.addLine(to: leftDoneImagePoint(x: x))
                path.close()
            }
            
            private func addLineRight(path: UIBezierPath, x: CGFloat) {
                path.move(to: rightDoneImagePoint(x: LineType.rightStartx))
                path.addLine(to: rightDoneImagePoint(x: x))
                path.close()
            }
            
            private func leftDoneImagePoint(x: CGFloat) -> CGPoint {
                return CGPoint(x: x, y: (11 / 10.6) * (x - 12.6) + 32.3)
            }
            
            private func rightDoneImagePoint(x: CGFloat) -> CGPoint {
                return CGPoint(x: x, y: (-24.8 / 24.94) * (x - 22.2) + 43.3)
            }
        }
        
        func doneImage(tintColor: UIColor?, lineType: LineType) -> UIImage? {
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            
            let path = UIBezierPath()
            
            lineType.addLine(path: path)
            
            tintColor?.setStroke()
            
            path.lineWidth = 2
            path.stroke()
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image?.withRenderingMode(.alwaysTemplate)
        }
        
        let leftCount: CGFloat = 20
        let diffLeft = (LineType.leftEndx - LineType.leftStartx) / leftCount
        
        let rightCount: CGFloat = 20
        let diffRight = (LineType.rightEndx - LineType.rightStartx) / rightCount
        
        let lineLeftTypes = (1...(Int(leftCount) - 1)).map{LineType.left(LineType.leftStartx + CGFloat($0) * diffLeft)} + [LineType.leftEnd]
        let lineRightTypes = (1...(Int(rightCount) - 1)).map{LineType.right(LineType.rightStartx + CGFloat($0) * diffRight)} + [LineType.rightEnd]
        
        return (lineLeftTypes + lineRightTypes).flatMap{doneImage(tintColor: tintColor, lineType: $0)}
    }
    
    private func errImage(tintColor: UIColor?) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let space: CGFloat = 14.7
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: space, y: space))
        path.addLine(to: CGPoint(x: size.width - space, y: size.height - space))
        path.close()
        
        path.move(to: CGPoint(x: space, y: size.height - space))
        path.addLine(to: CGPoint(x: size.width - space, y: space))
        path.close()
        
        tintColor?.setStroke()
        
        path.lineWidth = 2
        path.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.withRenderingMode(.alwaysTemplate)
    }
    
    private func loadingImage(tintColor: UIColor?) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let space: CGFloat = 6
        let bounds = CGRect(x: space, y: space, width: size.width - space * 2, height: size.height - space * 2)
        let center = CGPoint(x: bounds.origin.x + bounds.size.width / 2, y: bounds.origin.y + bounds.size.height / 2)
        let radius = min(bounds.size.width, bounds.size.height) / 2
        
        let path = UIBezierPath()
        
        path.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: ((CGFloat(M_PI) * 2) / 200) * 175, clockwise: true)
        
        tintColor?.setStroke()
        
        path.lineWidth = 2
        path.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.withRenderingMode(.alwaysTemplate)
    }
}

//****************************************************
// MARK: - fileprivate extension
//****************************************************

fileprivate extension UIColor {
    static func make(hex: String, alpha: CGFloat = 1) -> UIColor? {
        let scanner = Scanner(string: hex)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: alpha)
        }else {
            return nil
        }
    }
}
