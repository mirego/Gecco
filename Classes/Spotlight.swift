//
//  Spotlight.swift
//  Gecco
//
//  Created by yukiasai on 2016/01/17.
//  Copyright (c) 2016 yukiasai. All rights reserved.
//

import UIKit

public protocol SpotlightType {
    var frame: CGRect { get }
    var center: CGPoint { get }
    var path: UIBezierPath { get }
    var infinitesmalPath: UIBezierPath { get }
    var message: String { get }
    var title: String { get }
    var hasNoShape: Bool { get }
}

public extension SpotlightType {
    var center: CGPoint {
        return CGPoint(x: frame.midX, y: frame.midY)
    }

    var infinitesmalPath: UIBezierPath {
        return UIBezierPath(roundedRect: CGRect(origin: center, size: CGSize.zero), cornerRadius: 0)
    }

    var hasNoShape: Bool {
        return false
    }
}

open class Spotlight {
    open class Oval: SpotlightType {
        open var frame: CGRect
        open var message: String
        open var title: String
        public init(frame: CGRect, message: String, title: String) {
            self.frame = frame
            self.message = message
            self.title = title
        }

        public convenience init(center: CGPoint, diameter: CGFloat, message: String, title: String) {
            let frame = CGRect(x: center.x - diameter / 2, y: center.y - diameter / 2, width: diameter, height: diameter)
            self.init(frame: frame, message: message, title: title)
        }

        public convenience init(view: UIView, margin: CGFloat, message: String, title: String) {
            let origin = view.superview!.convert(view.frame.origin, to: view.window!.screen.fixedCoordinateSpace)
            let center = CGPoint(x: origin.x + view.bounds.width / 2, y: origin.y + view.bounds.height / 2)
            let diameter = max(view.bounds.width, view.bounds.height) + margin * 2
            self.init(center: center, diameter: diameter, message: message, title: title)
        }

        open var path: UIBezierPath {
            return UIBezierPath(roundedRect: frame, cornerRadius: frame.width / 2)
        }
    }

    open class Rect: SpotlightType {
        open var frame: CGRect
        open var message: String
        open var title: String
        public init(frame: CGRect, message: String, title: String) {
            self.frame = frame
            self.message = message
            self.title = title
        }

        public init(center: CGPoint, size: CGSize, message: String, title: String) {
            let frame = CGRect(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
            self.frame = frame
            self.message = message
            self.title = title
        }

        public init(view: UIView, margin: CGFloat, message: String, title: String) {
            let viewOrigin = view.superview!.convert(view.frame.origin, to: view.window!.screen.fixedCoordinateSpace)
            let origin = CGPoint(x: viewOrigin.x - margin, y: viewOrigin.y - margin)
            let size = CGSize(width: view.bounds.width + margin * 2, height: view.bounds.height + margin * 2)
            self.frame = CGRect(origin: origin, size: size)
            self.message = message
            self.title = title
        }

        open var path: UIBezierPath {
            return UIBezierPath(roundedRect: frame, cornerRadius: 0)
        }
    }

    open class RoundedRect: Rect {
        open var cornerRadius: CGFloat
        public init(center: CGPoint, size: CGSize, cornerRadius: CGFloat, message: String, title: String) {
            self.cornerRadius = cornerRadius
            super.init(center: center, size: size, message: message, title: title)
        }

        public init(view: UIView, margin: CGFloat, cornerRadius: CGFloat, message: String, title: String) {
            self.cornerRadius = cornerRadius
            super.init(view: view, margin: margin, message: message, title: title)
        }

        open override var path: UIBezierPath {
            return UIBezierPath(roundedRect: frame, cornerRadius: cornerRadius)
        }
    }

    open class NoShape: SpotlightType {
        open var message: String
        open var title: String
        public init(message: String, title: String) {
            self.message = message
            self.title = title
        }

        open var path: UIBezierPath {
            return UIBezierPath(rect: frame)
        }

        open var frame: CGRect {
            return CGRect.zero
        }

        open var hasNoShape: Bool {
            return true
        }
    }
}
