//
//  AppProgress.swift
//
//  Created by hideyuki okuni on 2016/11/02.
//  Copyright © 2016年 hideyuki. All rights reserved.
//

import Foundation
import UIKit

enum AppProgressColor {
    case grayAndWhite
    case lightGrayAndWhite
    case whiteAndBlack
    case blackAndWhite
    case custom(UIColor, UIColor) //(tintColor, backgroundColor)
    
    var tintColor: UIColor? {
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
    
    var backgroundColor: UIColor? {
        switch self {
        case .grayAndWhite:
            return .white
        case .whiteAndBlack:
            return .make(hex: "232323", alpha: 0.89)
        case .lightGrayAndWhite:
            return .white
        case .blackAndWhite:
            return .white
        case .custom(_, let color):
            return color
        }
    }
    
    func isEqual(type: AppProgressColor) -> Bool {
        return self.tintColor == type.tintColor && self.backgroundColor == type.backgroundColor
    }
}

enum AppProgressBackgroundStyle {
    case basic
    case none
    case full
    case customFull(CGFloat, CGFloat, CGFloat, CGFloat) //constant (top, bottom, leading, trailing)
    
    func isEqual(type: AppProgressBackgroundStyle) -> Bool {
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

class AppProgress {
    static var colorType = AppProgressColor.grayAndWhite
    static var backgroundStyle = AppProgressBackgroundStyle.basic
    static let minimumDismissTimeInterval: TimeInterval = 0.5
    
    static func show(view: UIView, string: String = "", keyboardHeight: CGFloat = 0) {
        displayRotationAnimation(type: .loading, view: view, string: string, keyboardHeight: keyboardHeight)
    }
    
    static func done(view: UIView, string: String = "", keyboardHeight: CGFloat = 0) {
        displayAnimationWithDismiss(type: .done, view: view, string: string, keyboardHeight: keyboardHeight)
    }
    
    static func info(view: UIView, string: String = "", keyboardHeight: CGFloat = 0) {
        displayAnimationWithDismiss(type: .info, view: view, string: string, keyboardHeight: keyboardHeight)
    }
    
    static func err(view: UIView, string: String = "", keyboardHeight: CGFloat = 0) {
        displayAnimationWithDismiss(type: .err, view: view, string: string, keyboardHeight: keyboardHeight)
    }
    
    static func custom(view: UIView, image: UIImage?, imageRenderingMode: UIImageRenderingMode = .alwaysTemplate, string: String = "", keyboardHeight: CGFloat = 0, isRotation: Bool = false) {
        if isRotation {
            displayRotationAnimation(type: .custom(image, imageRenderingMode), view: view, string: string, keyboardHeight: keyboardHeight)
        }else {
            displayAnimationWithDismiss(type: .custom(image, imageRenderingMode), view: view, string: string, keyboardHeight: keyboardHeight)
        }
    }
    
    static func dismiss() {
        UIView.animate(withDuration: fadeOutAnimationDuration, animations: {
            setAlpha(0)
        }, completion: { finished in
            remove()
        })
    }
    
    //****************************************************
    // MARK: - private
    //****************************************************
    
    private static var markView: UIImageView?
    private static var backgroundView: UIView?
    private static var stringLabel: UILabel?
    
    private static let loadingAnimationKey = "loadingAnimation"
    
    private static let fadeInAnimationDuration: TimeInterval = 0.15
    private static let fadeOutAnimationDuration: TimeInterval = 0.15
    
    private static var _isRotationAnimation = false
    private static var _settingInfo: SettingInfomation?
    private struct SettingInfomation {
        let mark: MarkType
        let string: String
        let colorType: AppProgressColor
        let backgroundStyle: AppProgressBackgroundStyle
        
        init(mark: MarkType, string: String) {
            self.mark = mark
            self.string = string
            colorType = AppProgress.colorType
            backgroundStyle = AppProgress.backgroundStyle
        }
        
        func isEqualImage(setting: SettingInfomation) -> Bool {
            return mark.isEqual(type: setting.mark) && colorType.tintColor == setting.colorType.tintColor
        }
        
        func isEqual(setting: SettingInfomation) -> Bool {
            return mark.isEqual(type: setting.mark) && string == setting.string && colorType.isEqual(type: setting.colorType) && backgroundStyle.isEqual(type: setting.backgroundStyle)
        }
    }
    
    private enum MarkType {
        case loading
        case done
        case err
        case info
        case custom(UIImage?, UIImageRenderingMode)
        
        var size: CGSize {
            return CGSize(width: 60, height: 60)
        }
        
        var imageView: UIImageView {
            //return UIImageView(image: image)
            
            switch self {
            case .loading:
                return loadingView
            case .err:
                return errView
            case .done:
                return doneView
            case .info:
                return infoView
            case .custom(let image, let mode):
                let imageView = UIImageView(image: image?.withRenderingMode(mode))
                imageView.tintColor = colorType.tintColor
                imageView.contentMode = .scaleAspectFit
                imageView.sizeToFit()
                
                return imageView
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
        
        private var infoView: UIImageView {
            let view = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
            
            let space: CGFloat = 13
            let bounds = CGRect(x: space, y: space, width: view.frame.size.width - space * 2, height: view.frame.size.height - space * 2)
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
            
            colorType.tintColor?.setStroke()
            
            path.lineJoinStyle = .round
            path.lineCapStyle = .round
            path.lineWidth = 2
            path.stroke()
            
            view.layer.contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
            UIGraphicsEndImageContext()
            
            return view
        }
        
        private var doneView: UIImageView {
            let view = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)

            let space: CGFloat = 14.7
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: space - 2.1, y: space + 17.6))
            path.addLine(to: CGPoint(x: space + 8.5, y: size.height - space - 2))
            path.close()
            
            path.move(to: CGPoint(x: space + 7.5, y: size.height - space - 2))
            path.addLine(to: CGPoint(x: size.width - space + 1.84, y: space + 3.8))
            path.close()
            
            colorType.tintColor?.setStroke()
            
            path.lineWidth = 2
            path.stroke()
            
            view.layer.contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
            UIGraphicsEndImageContext()
            
            return view
        }
        
        private var errView: UIImageView {
            let view = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
            
            let space: CGFloat = 14.7
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: space, y: space))
            path.addLine(to: CGPoint(x: size.width - space, y: size.height - space))
            path.close()
            
            path.move(to: CGPoint(x: space, y: size.height - space))
            path.addLine(to: CGPoint(x: size.width - space, y: space))
            path.close()
            
            colorType.tintColor?.setStroke()
            
            path.lineWidth = 2
            path.stroke()
            
            view.layer.contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
            UIGraphicsEndImageContext()
            
            return view
        }
        
        private var loadingView: UIImageView {
            let view = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            
            UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
            
            let space: CGFloat = 6
            let bounds = CGRect(x: space, y: space, width: view.frame.size.width - space * 2, height: view.frame.size.height - space * 2)
            let center = CGPoint(x: bounds.origin.x + bounds.size.width / 2, y: bounds.origin.y + bounds.size.height / 2)
            
            let radius = min(bounds.size.width, bounds.size.height) / 2
            let path = UIBezierPath()
            path.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: ((CGFloat(M_PI) * 2) / 200) * 175, clockwise: true)
            colorType.tintColor?.setStroke()
            
            path.lineWidth = 2
            path.stroke()
            
            view.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return view
        }
    }
    
    private static var isHavingAnimationKey: Bool {
        return markView?.layer.animationKeys()?.filter({$0 == loadingAnimationKey}).count ?? 0 > 0
    }
    
    private static func displayAnimation(
        type: MarkType
        , view: UIView
        , string: String
        , keyboardHeight: CGFloat
        , animations: @escaping () -> Void
        , completion: @escaping () -> Void) {
        
        let settingInfo = SettingInfomation(mark: type, string: string)
        
        if _settingInfo?.isEqual(setting: settingInfo) ?? false && isHavingAnimationKey == _isRotationAnimation {
            if let backgroundView = backgroundView {
                backgroundView.superview?.bringSubview(toFront: backgroundView)
            }
            
            return
        }
        
        let isDisplaying = backgroundView != nil
        
        remove(isReleaseMarkView: !(_settingInfo?.isEqualImage(setting: settingInfo) ?? false && isHavingAnimationKey == _isRotationAnimation))
        
        _settingInfo = settingInfo
        prepare(view: view, keyboardHeight: keyboardHeight)
        
        if isDisplaying {
            animations()
            completion()
        }else {
            setAlpha(0)
            backgroundView?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
            UIView.animate(withDuration: fadeInAnimationDuration, delay: 0, options: [.allowUserInteraction, .curveEaseOut, .beginFromCurrentState], animations: {
                backgroundView?.transform = CGAffineTransform(scaleX: 1, y: 1)
                setAlpha(1)
                
                animations()
            }, completion: { finished in
                completion()
            })
        }
    }
    
    private static func displayRotationAnimation(type: MarkType, view: UIView, string: String, keyboardHeight: CGFloat) {
        let isEqualImage = _settingInfo?.isEqualImage(setting: SettingInfomation(mark: type, string: string)) ?? false
        
        _isRotationAnimation = true
        displayAnimation(type: type, view: view, string: string, keyboardHeight: keyboardHeight, animations: {
            if !isEqualImage || !_isRotationAnimation {
                markView?.rotationAnimation(forKey: loadingAnimationKey)
            }
        }, completion: { finished in
            
        })
    }
    
    private static func displayAnimationWithDismiss(type: MarkType, view: UIView, string: String, keyboardHeight: CGFloat) {
        func dismissTimeInterval(string: String) -> TimeInterval {
            return max(TimeInterval(string.characters.count) * TimeInterval(0.06) + TimeInterval(0.5), minimumDismissTimeInterval)
        }
        
        _isRotationAnimation = false
        displayAnimation(type: type, view: view, string: string, keyboardHeight: keyboardHeight, animations: {
            
        }, completion: { finished in
            delayStart(second: dismissTimeInterval(string: string), animations: {() -> Void in
                if _settingInfo?.isEqual(setting: SettingInfomation(mark: type, string: string)) ?? false && isHavingAnimationKey == _isRotationAnimation {
                    dismiss()
                }
            })
        })
    }
    
    private static func setAlpha(_ alpha: CGFloat) {
        markView?.alpha = alpha
        backgroundView?.alpha = alpha
        stringLabel?.alpha = alpha
    }
    
    private static func remove(isReleaseMarkView: Bool = true) {
        _settingInfo = nil
        
        markView?.removeFromSuperview()
        
        //同じ画像が呼ばれた時はアニメーションを継続するために解放しない
        if isReleaseMarkView {
            markView?.layer.removeAnimation(forKey: loadingAnimationKey)
            markView?.isHidden = true
            markView?.image = nil
            markView = nil
            
            _isRotationAnimation = false
        }
        
        backgroundView?.removeFromSuperview()
        backgroundView?.isHidden = true
        backgroundView = nil
        
        stringLabel?.removeFromSuperview()
        stringLabel?.isHidden = true
        stringLabel = nil
        
        NotificationCenter.default.removeObserver(self)
    }
    
    private static var widthMarkLayoutConstraint: NSLayoutConstraint?
    private static var heightMarkLayoutConstraint: NSLayoutConstraint?
    private static var centerYMarkLayoutConstraint: NSLayoutConstraint?

    private static func prepare(view: UIView, keyboardHeight: CGFloat) {
        guard let _settingInfo = _settingInfo else {
            return
        }
        
        //nilでない時はアニメーションが続いている可能性があるのでそのままにしておく
        if markView == nil {
            markView = _settingInfo.mark.imageView
        }
        
        backgroundView = UIView(frame: view.frame)
        backgroundView?.backgroundColor = colorType.backgroundColor
        
        stringLabel = UILabel()
        stringLabel?.numberOfLines = 0
        stringLabel?.text = _settingInfo.string
        stringLabel?.textColor = colorType.tintColor
        stringLabel?.font = UIFont.systemFont(ofSize: 15)
        stringLabel?.textAlignment = .center
        
        if _settingInfo.string == "" {
            stringLabel?.frame.size = .zero
        }else {
            stringLabel?.sizeToFit()
        }
        
        let maxLabelWidth: CGFloat = 196.666666666667
        if let labelSize = stringLabel?.frame.size, labelSize.width > maxLabelWidth {
            let size = CGSize(width: maxLabelWidth, height: stringLabel?.frame.size.height ?? 0)
            stringLabel?.frame.size = stringLabel?.sizeThatFits(size) ?? .zero
            stringLabel?.lineBreakMode = .byWordWrapping
        }
        
        guard let markView = markView, let backgroundView = backgroundView, let stringLabel = stringLabel else {
            return
        }
        
        view.addSubview(backgroundView)
        backgroundView.addSubview(markView)
        backgroundView.addSubview(stringLabel)
        
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        let size = CGSize(width: max(_settingInfo.mark.size.width, stringLabel.frame.size.width), height: _settingInfo.mark.size.height + stringLabel.frame.size.height)
        
        if let centerYMarkLayoutConstraint = centerYMarkLayoutConstraint {
            backgroundView.removeConstraint(centerYMarkLayoutConstraint)
        }
        centerYMarkLayoutConstraint = nil
        
        switch backgroundStyle {
        case .none:
            centerYMarkLayoutConstraint = backgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constatnt_CenterYMarkLayoutConstraint(keyboardHeight: keyboardHeight))
            backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            centerYMarkLayoutConstraint?.isActive = true
            backgroundView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
            backgroundView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
            backgroundView.backgroundColor = .clear
        case .basic:
            centerYMarkLayoutConstraint = backgroundView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constatnt_CenterYMarkLayoutConstraint(keyboardHeight: keyboardHeight))
            
            let space: CGFloat = 20
            backgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            centerYMarkLayoutConstraint?.isActive = true
            
            if _settingInfo.string == "" {
                backgroundView.widthAnchor.constraint(equalToConstant: size.width + space * 2).isActive = true
                backgroundView.heightAnchor.constraint(equalToConstant: size.height + space * 2).isActive = true
            }else {
                backgroundView.widthAnchor.constraint(equalToConstant: max(size.width + space * 1, _settingInfo.mark.size.width * 2)).isActive = true
                backgroundView.heightAnchor.constraint(equalToConstant: size.height + space * 1).isActive = true
            }
            
            backgroundView.layer.cornerRadius = 15
        case .full:
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        case .customFull(let top, let bottom, let leading, let trailing):
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor, constant: top).isActive = true
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom).isActive = true
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leading).isActive = true
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailing).isActive = true
        }
        
        var markImageSize: CGSize {
            if _settingInfo.string == "" {
                return _settingInfo.mark.size
            }else {
                return CGSize(width: (_settingInfo.mark.size.width / 4) * 3, height: (_settingInfo.mark.size.height / 4) * 3)
            }
        }
        
        var spaceMarkAndLabel: CGFloat {
            return (_settingInfo.mark.size.height - markImageSize.height) / 3
        }
        
        markView.translatesAutoresizingMaskIntoConstraints = false
        markView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        markView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: -stringLabel.frame.size.height / 2 - spaceMarkAndLabel).isActive = true
        
        if let widthMarkLayoutConstraint = widthMarkLayoutConstraint, let heightMarkLayoutConstraint = heightMarkLayoutConstraint {
            markView.removeConstraint(widthMarkLayoutConstraint)
            markView.removeConstraint(heightMarkLayoutConstraint)
        }
        widthMarkLayoutConstraint = markView.widthAnchor.constraint(equalToConstant: markImageSize.width)
        heightMarkLayoutConstraint = markView.heightAnchor.constraint(equalToConstant: markImageSize.height)
        widthMarkLayoutConstraint?.isActive = true
        heightMarkLayoutConstraint?.isActive = true
        
        stringLabel.translatesAutoresizingMaskIntoConstraints = false
        stringLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        stringLabel.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: markImageSize.height / 2 + spaceMarkAndLabel).isActive = true
        stringLabel.widthAnchor.constraint(equalToConstant: stringLabel.frame.size.width).isActive = true
        stringLabel.heightAnchor.constraint(equalToConstant: stringLabel.frame.size.height).isActive = true
        
        registNotifications()
    }
    
    private static func delayStart(second: Double, animations: @escaping () -> Void) {
        let dispatchTime = DispatchTime.now() + Double(Int64(second * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            animations()
        })
    }
    
    private static func registNotifications() {
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
    
    @objc static func setPosition(notification: NSNotification) {
        guard let centerYMarkLayoutConstraint = AppProgress.centerYMarkLayoutConstraint else {
            return
        }
        
        centerYMarkLayoutConstraint.constant = constatnt_CenterYMarkLayoutConstraint(keyboardHeight: nil)
    }
    
    private static var scheduleConstant: CGFloat?
    @objc static func setPositionForKeyboard(notification: NSNotification) {
        guard let centerYMarkLayoutConstraint = AppProgress.centerYMarkLayoutConstraint else {
                return
        }
        
        var keyboardHeight: CGFloat {
            if notification.name == NSNotification.Name.UIKeyboardDidHide || notification.name == NSNotification.Name.UIKeyboardWillHide {
                return 0
            }else {
                return (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
            }
        }
        
        let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
        
        let constant = constatnt_CenterYMarkLayoutConstraint(keyboardHeight: keyboardHeight)
        
        if scheduleConstant ?? centerYMarkLayoutConstraint.constant != constant {
            scheduleConstant = constant
            
            //キーボードが出たまま前のViewControllerに戻った時の動きが不自然であったためこちらに変更
            let last = Int(keyboardAnimationDuration / 0.005)
            let diff = constant - centerYMarkLayoutConstraint.constant
            let endConstant = constant
            
            func animationTimeInterval(total: TimeInterval, now: Int, last: Int) -> TimeInterval {
                //途中に加速してよりアニメーションらしい動きにしています。
                guard 1 <= now && now <= last else {
                    return 0
                }
                
                let avg = (total / TimeInterval(last))
                
                let hiStart = (last / 12) + 1
                let slowStart = last - (last / 12) + 1
                
                let slowTimeInterval = TimeInterval(avg * 2)
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
                        if Int(centerYMarkLayoutConstraint.constant + (diff / CGFloat(last)) * CGFloat(last - i + 1)) == Int(endConstant), let scheduleConstant = scheduleConstant, scheduleConstant == endConstant {
                            centerYMarkLayoutConstraint.constant += diff / CGFloat(last)
                            if i == last {
                                self.scheduleConstant = nil
                            }
                        }else {
                            //他で変更があればここでは変更しない
                            scheduleConstant = nil
                        }
                    })
                }
            }else {
                centerYMarkLayoutConstraint.constant = constant
            }
            
            /*
            UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: [.allowUserInteraction], animations: {
                
                if let scheduleConstant = scheduleConstant, scheduleConstant == constant {
                    backgroundView?.frame.origin.y = (backgroundView?.superview?.center.y ?? 0) + constant - ((backgroundView?.frame.size.height ?? 0) / 2)
                }
            }, completion: { finished in
                if let scheduleConstant = scheduleConstant, scheduleConstant == constant {
                    centerYMarkLayoutConstraint.constant = constant
                }
                
                scheduleConstant = nil
            })
            */
        }
    }
    
    private static var beforeSetKeyboardHeight: CGFloat = 0
    private static func constatnt_CenterYMarkLayoutConstraint(keyboardHeight: CGFloat?) -> CGFloat {
        let heightSuperview = backgroundView?.superview?.frame.size.height ?? 0
        let activeHeight = heightSuperview - (keyboardHeight ?? beforeSetKeyboardHeight)
        let diff = heightSuperview / 2 - activeHeight / 2
        
        var constatntDef_CenterYMarkLayoutConstraint: CGFloat {
            if keyboardHeight ?? beforeSetKeyboardHeight > 0 {
                return activeHeight / 65
            }else {
                return activeHeight / 20
            }
        }
        
        if let keyboardHeight = keyboardHeight {
            beforeSetKeyboardHeight = keyboardHeight
        }
        
        return -constatntDef_CenterYMarkLayoutConstraint - diff
    }
}

fileprivate extension UIImageView {
    func rotationAnimation(forKey: String, duration: CFTimeInterval = 5.6) {
        self.layer.removeAnimation(forKey: forKey)
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.fromValue = 0
        animation.toValue = self.frame.size.width / 2
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.repeatCount = MAXFLOAT
        animation.isCumulative = true
        animation.autoreverses = false
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        self.layer.add(animation, forKey: forKey)
    }
}

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
