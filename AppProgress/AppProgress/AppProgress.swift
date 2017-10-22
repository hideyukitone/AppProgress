//
//  AppProgress.swift
//
//  Created by hideyuki okuni on 2016/11/02.
//  Copyright © 2016年 hideyuki. All rights reserved.
//

import Foundation
import UIKit

open class AppProgress: AppProgressShowable, AppProgressPropertyEditable {
    private static let appProgressUI = AppProgressUI()
    
    //AppProgressShowable
    
    open static func show(view: UIView, string: String = "") {
        syncMain {
            appProgressUI.displayRotationAnimation(type: .loading, view: view, string: string)
        }
    }
    
    open static func done(view: UIView, string: String = "", completion: (() -> Void)? = nil) {
        syncMain {
            appProgressUI.displayAnimationWithDismiss(type: .done, view: view, string: string, completion: completion)
        }
    }
    
    open static func info(view: UIView, string: String = "", completion: (() -> Void)? = nil) {
        syncMain {
            appProgressUI.displayAnimationWithDismiss(type: .info, view: view, string: string, completion: completion)
        }
    }
    
    open static func err(view: UIView, string: String = "", completion: (() -> Void)? = nil) {
        syncMain {
            appProgressUI.displayAnimationWithDismiss(type: .err, view: view, string: string, completion: completion)
        }
    }
    
    open static func custom(view: UIView, image: UIImage?, imageRenderingMode: UIImageRenderingMode = .alwaysTemplate, string: String = "", isRotation: Bool = false, completion: (() -> Void)? = nil) {
        syncMain {
            if isRotation {
                appProgressUI.displayRotationAnimation(type: .custom(image, imageRenderingMode), view: view, string: string)
            } else {
                appProgressUI.displayAnimationWithDismiss(type: .custom(image, imageRenderingMode), view: view, string: string, completion: completion)
            }
        }
    }
    
    open static func dismiss(completion: (() -> Void)? = nil) {
        syncMain {
            appProgressUI.dismiss(completion: completion)
        }
    }
    
    //AppProgressPropertyEditable
    
    open static func setColorType(type: AppProgressColor) {
        appProgressUI.setColorType(type: type)
    }
    
    open static func setBackgroundStyle(style: AppProgressBackgroundStyle) {
        appProgressUI.setBackgroundStyle(style: style)
    }
    
    open static func setMinimumDismissTimeInterval(timeInterval: TimeInterval) {
        appProgressUI.setMinimumDismissTimeInterval(timeInterval: timeInterval)
    }
    
    //private
    
    private static func syncMain(block: () -> Void) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync() { () -> Void in
                block()
            }
        }
    }
}

public enum AppProgressColor: Equatable {
    case blackAndWhite
    case whiteAndBlack
    case grayAndWhite
    case lightGrayAndWhite
    case custom(UIColor, UIColor) //(tintColor, backgroundColor)
    
    fileprivate var tintColor: UIColor? {
        switch self {
        case .grayAndWhite:
            return #colorLiteral(red: 0.5176470588, green: 0.5176470588, blue: 0.5176470588, alpha: 1)
        case .whiteAndBlack:
            return .white
        case .lightGrayAndWhite:
            return #colorLiteral(red: 0.6549019608, green: 0.6509803922, blue: 0.6509803922, alpha: 1)
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
            return #colorLiteral(red: 0.137254902, green: 0.137254902, blue: 0.137254902, alpha: 0.89)
        case .lightGrayAndWhite:
            return UIColor.white.withAlphaComponent(0.99)
        case .blackAndWhite:
            return UIColor.white.withAlphaComponent(0.99)
        case .custom(_, let color):
            return color
        }
    }

    public static func == (lhs: AppProgressColor, rhs: AppProgressColor) -> Bool {
        return lhs.tintColor == rhs.tintColor && lhs.backgroundColor == rhs.backgroundColor
    }
}

public enum AppProgressBackgroundStyle: Equatable {
    case none
    case full
    case customFull(CGFloat, CGFloat, CGFloat, CGFloat) //constant (top, bottom, leading, trailing)

    public static func == (lhs: AppProgressBackgroundStyle, rhs: AppProgressBackgroundStyle) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none), (.full, .full):
            return true
        case (.customFull(let lTop, let lBottom, let lLeading, let lTrailing), .customFull(let rTop, let rBottom, let rLeading, let rTrailing)) where lTop == rTop && lBottom == rBottom && lLeading == rLeading && lTrailing == rTrailing:
            return true
        default:
            return false
        }
    }
}

// MARK: - AppProgressUI

fileprivate class AppProgressUI: AnimationDelayable {
    var markView: MarkView?
    var backgroundView: BackgroundView?
    var stringLabel: StringLabel?
    
    func displayRotationAnimation(type: MarkType, view: UIView, string: String) {
        let isEqual = _settingInfo == SettingInformation(mark: type, string: string, colorType: colorType, backgroundStyle: backgroundStyle)

        displayAnimation(type: type, view: view, string: string, isRotation: true, animations: { [weak self] in
            if !isEqual || self?.markView?.isRotationing != true {
                self?.markView?.startRotation()
            }
        }, completion: {
            
        })
    }
    
    func displayAnimationWithDismiss(type: MarkType, view: UIView, string: String, completion: (() -> Void)? = nil) {
        func dismissTimeInterval(string: String) -> TimeInterval {
            return max(TimeInterval(string.characters.count) * TimeInterval(0.06) + TimeInterval(0.5), minimumDismissTimeInterval)
        }
        
        displayAnimation(type: type, view: view, string: string, isRotation: false, animations: { [weak self] in
            guard let `self` = self else { return }

            if let count = self.markView?.animationImages?.count, count > 0 {
                self.markView?.animationDuration = self.fadeInAnimationDuration
                self.markView?.startAnimating()
            }
        }, completion: { [weak self] in
            guard let `self` = self else { return }

            let dismissId = self._settingInfo?.id
            self.delayStart(second: dismissTimeInterval(string: string), animations: {() -> Void in
                if let id = self._settingInfo?.id , id == dismissId {
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
    
    func setColorType(type: AppProgressColor) {
        colorType = type
    }
    
    func setBackgroundStyle(style: AppProgressBackgroundStyle) {
        backgroundStyle = style
    }
    
    func setMinimumDismissTimeInterval(timeInterval: TimeInterval) {
        minimumDismissTimeInterval = timeInterval
    }
    
    private var colorType = AppProgressColor.whiteAndBlack
    private var backgroundStyle = AppProgressBackgroundStyle.full
    private var minimumDismissTimeInterval: TimeInterval = 0.5
    
    private let fadeInAnimationDuration: TimeInterval = 0.15
    private let fadeOutAnimationDuration: TimeInterval = 0.15
    
    private var _settingInfo: SettingInformation?
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
    
    private func displayAnimation(
        type: MarkType
        , view: UIView
        , string: String
        , isRotation: Bool
        , animations: @escaping () -> Void
        , completion: @escaping () -> Void) {
        
        let settingInfo = SettingInformation(mark: type, string: string, colorType: colorType, backgroundStyle: backgroundStyle)
        
        if _settingInfo == settingInfo && (markView?.isRotationing ?? false) == isRotation {
            if let backgroundView = backgroundView {
                backgroundView.superview?.bringSubview(toFront: backgroundView)
            }
            
            return
        }
        
        let isDisplaying = backgroundView != nil
        remove(isReleaseMarkView: !(_settingInfo == settingInfo && (markView?.isRotationing ?? false) == isRotation))
        
        _settingInfo = settingInfo
        
        prepare(view: view)
        
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
    
    private func prepare(view: UIView) {
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
        
        setAnchor()
        
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
    }
    
    private func setAnchor() {
        guard let _settingInfo = _settingInfo, let markView = markView, let backgroundView = backgroundView, let stringLabel = stringLabel, let view = backgroundView.superview else {
            return
        }
        
        stringLabel.setAnchor(spaceMarkAndLabel: _settingInfo.spaceMarkAndLabel, markImageSize: _settingInfo.markImageSize, backgroundStyle: _settingInfo.backgroundStyle, viewSize: view.frame.size)
        
        backgroundView.setAnchor(markOriginalSize: _settingInfo.mark.size, backgroundStyle: _settingInfo.backgroundStyle, stringLabel: stringLabel)
        
        markView.setAnchor(spaceMarkAndLabel: _settingInfo.spaceMarkAndLabel, markImageSize: _settingInfo.markImageSize, stringLabel: stringLabel)
    }
}

fileprivate class MarkView: UIImageView, ViewRotationable, ViewReleasable {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(type: MarkType, tintColor: UIColor?) {
        let images = type.images(tintColor: tintColor)

        switch images.count {
        case 1:
            super.init(image: images.first)
        case let count where count > 1:
            super.init(image: images.last)
            self.animationImages = images
            self.animationRepeatCount = 1
            self.tintColor = tintColor
        default:
            super.init(image: nil)
        }
        
        self.tintColor = tintColor
    }
    
    private var widthMarkLayoutConstraint: NSLayoutConstraint?
    private var heightMarkLayoutConstraint: NSLayoutConstraint?
    
    func setAnchor(spaceMarkAndLabel: CGFloat, markImageSize: CGSize, stringLabel: StringLabel) {
        guard let backgroundView = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: stringLabel.topAnchor, constant: -spaceMarkAndLabel).isActive = true
        
        if let widthMarkLayoutConstraint = widthMarkLayoutConstraint, let heightMarkLayoutConstraint = heightMarkLayoutConstraint {
            widthMarkLayoutConstraint.constant = markImageSize.width
            heightMarkLayoutConstraint.constant = markImageSize.height
        } else {
            widthMarkLayoutConstraint = self.widthAnchor.constraint(equalToConstant: markImageSize.width)
            heightMarkLayoutConstraint = self.heightAnchor.constraint(equalToConstant: markImageSize.height)
            
            widthMarkLayoutConstraint?.isActive = true
            heightMarkLayoutConstraint?.isActive = true
        }
    }
}

fileprivate class BackgroundView: UIView, ViewReleasable, AnimationDelayable {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(backgroundColor: UIColor?) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
    }
    
    func setAnchor(markOriginalSize: CGSize, backgroundStyle: AppProgressBackgroundStyle, stringLabel: StringLabel) {
        guard let view = self.superview else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        switch backgroundStyle {
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
}

fileprivate class StringLabel: UILabel, ViewReleasable {
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
    func setAnchor(spaceMarkAndLabel: CGFloat, markImageSize: CGSize, backgroundStyle: AppProgressBackgroundStyle, viewSize: CGSize) {
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
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor, constant: markImageSize.height / 2 + spaceMarkAndLabel).isActive = true
        
        if let widthLabelAnchor = widthLabelAnchor, let heightLabelAnchor = heightLabelAnchor {
            widthLabelAnchor.constant = self.frame.size.width
            heightLabelAnchor.constant = self.frame.size.height
        } else {
            widthLabelAnchor = self.widthAnchor.constraint(equalToConstant: self.frame.size.width)
            widthLabelAnchor?.isActive = true
            
            heightLabelAnchor = self.heightAnchor.constraint(equalToConstant: self.frame.size.height)
            heightLabelAnchor?.isActive = true
        }
    }
}

// MARK: - fileprivate protocol

fileprivate protocol ViewRotationable {
    var forKey: String { get }
    func startRotation()
    func stopRotation()
    var isRotationing: Bool { get }
}

fileprivate extension ViewRotationable where Self: UIView {
    var forKey: String {
        return "loadingAnimation"
    }

    func startRotation() {
        self.stopRotation()

        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = CGFloat(Double.pi) * 2
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
}

fileprivate protocol ViewReleasable {
    func releaseAll()
}

fileprivate extension ViewReleasable where Self: UIView {
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

fileprivate protocol AnimationDelayable {
    func delayStart(second: Double, animations: @escaping () -> Void)
}

fileprivate extension AnimationDelayable {
    func delayStart(second: Double, animations: @escaping () -> Void) {
        let dispatchTime = DispatchTime.now() + Double(Int64(second * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            animations()
        })
    }
}

fileprivate protocol AppProgressShowable {
    static func show(view: UIView, string: String)
    static func done(view: UIView, string: String, completion: (() -> Void)?)
    static func info(view: UIView, string: String, completion: (() -> Void)?)
    static func err(view: UIView, string: String, completion: (() -> Void)?)
    static func custom(view: UIView, image: UIImage?, imageRenderingMode: UIImageRenderingMode, string: String, isRotation: Bool, completion: (() -> Void)?)
    static func dismiss(completion: (() -> Void)?)
}

fileprivate protocol AppProgressPropertyEditable {
    static func setColorType(type: AppProgressColor)
    static func setBackgroundStyle(style: AppProgressBackgroundStyle)
    static func setMinimumDismissTimeInterval(timeInterval: TimeInterval)
}

// MARK: - fileprivate enum

fileprivate enum MarkType: Equatable {
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
    
    private func infoImage(tintColor: UIColor?) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        let space: CGFloat = 13
        let bounds = CGRect(x: space, y: space, width: size.width - space * 2, height: size.height - space * 2)
        let center = CGPoint(x: bounds.origin.x + bounds.size.width / 2, y: bounds.origin.y + bounds.size.height / 2)
        let radius = min(bounds.size.width, bounds.size.height) / 2
        
        let path = UIBezierPath()
        
        path.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi) * 2, clockwise: true)
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
        
        path.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: ((CGFloat(Double.pi) * 2) / 200) * 175, clockwise: true)
        
        tintColor?.setStroke()
        
        path.lineWidth = 2
        path.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.withRenderingMode(.alwaysTemplate)
    }
}
