//
//  MarkView.swift
//  AppProgress
//
//  Created by 大國嗣元 on 2018/05/19.
//  Copyright © 2018年 hideyuki. All rights reserved.
//

import UIKit

final class MarkView: UIImageView, ViewRotationable, ViewReleasable {
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
        self.isUserInteractionEnabled = false
    }

    private var widthMarkLayoutConstraint: NSLayoutConstraint?
    private var heightMarkLayoutConstraint: NSLayoutConstraint?

    func setAnchor(backgroundView: UIView, spaceMarkAndLabel: CGFloat, markImageSize: CGSize, stringLabel: StringLabel) {
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

private extension MarkType {
    func images(tintColor: UIColor?) -> [UIImage] {
        switch self {
        case .loading:
            return [loadingImage(tintColor: tintColor)].compactMap{$0}
        case .err:
            return [errImage(tintColor: tintColor)].compactMap{$0}
        case .done:
            return doneImages(tintColor: tintColor)
        case .info:
            return [infoImage(tintColor: tintColor)].compactMap{$0}
        case .custom(let image, let mode):
            return [image?.withRenderingMode(mode)].compactMap{$0}
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

        return (lineLeftTypes + lineRightTypes).compactMap{doneImage(tintColor: tintColor, lineType: $0)}
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
