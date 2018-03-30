//
//  SpotlightView.swift
//  Gecco
//
//  Created by yukiasai on 2016/01/16.
//  Copyright (c) 2016 yukiasai. All rights reserved.
//

import UIKit

open class SpotlightView: UIView {
    @objc open static let defaultAnimateDuration: TimeInterval = 0.25
    fileprivate let spotlightPadding: CGFloat = 20
    fileprivate let messageViewMargin: CGFloat = 20
    fileprivate let messageViewPadding: CGFloat = 20
    fileprivate let messageTitleMargin: CGFloat = 10
    fileprivate let messageViewTextMaxWidthMargin: CGFloat = 250
    
    @objc public let messageLabel: UILabel = UILabel()
    @objc public let titleLabel: UILabel = UILabel()
    @objc public let messageView: UIView = UIView()
    @objc public let closeView: UIImageView = UIImageView()
    
    @objc open var currentTargetCenter : CGPoint = CGPoint.zero
    fileprivate lazy var maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillRule = kCAFillRuleEvenOdd
        layer.fillColor = UIColor.black.cgColor
        return layer
    }()
    
    var spotlight: SpotlightType?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    @objc open func currentSpotlightCenter() -> CGPoint {
        return currentTargetCenter
    }
    
    fileprivate func commonInit() {
        layer.mask = maskLayer
        
        messageView.contentScaleFactor = 0.0;
        messageView.backgroundColor = UIColor.black
        
        messageLabel.textColor = UIColor.white
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = NSTextAlignment.left
        messageLabel.font = UIFont.systemFont(ofSize: 16.0)
        
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = NSTextAlignment.left
        titleLabel.font = UIFont.systemFont(ofSize: 26.0)

        closeView.tintColor = UIColor.white
        closeView.sizeToFit()
        
        messageView.addSubview(messageLabel)
        messageView.addSubview(titleLabel)
        messageView.addSubview(closeView)
        addSubview(messageView)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        maskLayer.frame = frame
        if self.spotlight != nil {
            if (spotlight!.hasNoShape) {
                messageView.frame = CGRect(x: (bounds.midX - messageView.frame.size.width / 2), y: bounds.midY - messageView.frame.size.height / 2 + messageViewMargin, width: messageView.frame.size.width, height: messageView.frame.size.height)
            } else {
                if (spotlight!.center.y <= (bounds.size.height * 0.5)) {
                    messageView.frame = CGRect(x: max((spotlight!.center.x - messageView.frame.size.width), messageViewMargin) , y: spotlight!.frame.origin.y + spotlight!.frame.size.height + messageViewMargin, width: messageView.frame.size.width, height: messageView.frame.size.height)
                } else {
                    messageView.frame = CGRect(x: max((spotlight!.center.x - messageView.frame.size.width), messageViewMargin) , y: spotlight!.frame.origin.y - messageView.frame.size.height - messageViewMargin, width: messageView.frame.size.width, height: messageView.frame.size.height)
                }
            }
            
            titleLabel.frame = CGRect(x: messageViewPadding , y: messageViewPadding, width: titleLabel.bounds.size.width, height: titleLabel.bounds.size.height)
            messageLabel.frame = CGRect(x: messageViewPadding , y: messageViewPadding + titleLabel.bounds.size.height + messageTitleMargin , width: messageLabel.bounds.size.width, height: messageLabel.bounds.size.height)
            closeView.frame = CGRect(x: messageView.bounds.size.width - closeView.bounds.size.width - 10 , y: 10 , width: closeView.bounds.size.width , height: closeView.bounds.size.height)
        }
    }
    
    open func appear(_ spotlight: SpotlightType, duration: TimeInterval = SpotlightView.defaultAnimateDuration) {
        showMessageFromSpotlight(spotlight, duration: duration);
        maskLayer.add(appearAnimation(duration, spotlight: spotlight), forKey: nil);
        self.spotlight = spotlight
    }
    
    fileprivate func showMessageFromSpotlight(_ spotlight: SpotlightType, duration: TimeInterval) {
        messageLabel.text = spotlight.message;
        let messageSize = messageLabel.sizeThatFits(CGSize(width: messageViewTextMaxWidthMargin, height: CGFloat.greatestFiniteMagnitude))
        messageLabel.frame = CGRect(x: messageLabel.frame.origin.x , y: messageLabel.frame.origin.y , width: messageSize.width , height: messageSize.height)
        
        titleLabel.text = spotlight.title
        let titleSize = titleLabel.sizeThatFits(CGSize(width: messageViewTextMaxWidthMargin, height: CGFloat.greatestFiniteMagnitude))
        titleLabel.frame = CGRect(x: titleLabel.frame.origin.x , y: titleLabel.frame.origin.y , width: titleSize.width , height: titleSize.height)
        
        messageView.frame = CGRect(x: messageView.frame.origin.x , y: messageView.frame.origin.y ,
                                        width: max(messageSize.width, titleSize.width + closeView.frame.size.width) + (messageViewPadding * 2) ,
                                        height: titleSize.height + messageSize.height + messageTitleMargin + (messageViewPadding * 2))
        messageView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0);
        
        UIView .animate(withDuration: duration, animations: {
            self.messageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0);
        }) 
    }
    
    @objc open func disappear(_ duration: TimeInterval = SpotlightView.defaultAnimateDuration) {
        maskLayer.add(disappearAnimation(duration), forKey: nil)
    }
    
    @objc open func appearOnViewCircle(_ target: UIView, message: String, title: String) {
        currentTargetCenter = target.center;
        appear(Spotlight.Oval(center: target.superview!.convert(target.center, to: self.superview), diameter: target.frame.size.width + spotlightPadding, message: message, title:title));
    }
    
    @objc open func appearOnViewRectangle(_ target: UIView, message: String, title: String) {
        currentTargetCenter = target.center;
        appear(Spotlight.RoundedRect(center: target.superview!.convert(target.center, to: self.superview), size: CGSize(width:target.frame.size.width - spotlightPadding,  height:target.frame.size.height - spotlightPadding), cornerRadius:target.frame.size.height/2, message: message, title:title));
    }
    
    @objc open func appearFloating(message: String, title: String) {
        appear(Spotlight.NoShape(message: message, title:title));
    }
    
    open func move(_ toSpotlight: SpotlightType, duration: TimeInterval = SpotlightView.defaultAnimateDuration, moveType: SpotlightMoveType = .direct) {
        showMessageFromSpotlight(toSpotlight, duration: duration);
        
        switch moveType {
            case .direct:
                moveDirect(toSpotlight, duration: duration)
            case .disappear:
                moveDisappear(toSpotlight, duration: duration)
        }
    }
    
    @objc open func moveToView(_ target: UIView, message: String, title: String) {
        move(Spotlight.Oval(center: target.superview!.convert(target.center, to: self.superview), diameter: target.frame.size.width + spotlightPadding, message: message, title:title));
    }
}

extension SpotlightView {
    fileprivate func moveDirect(_ toSpotlight: SpotlightType, duration: TimeInterval = SpotlightView.defaultAnimateDuration) {
        maskLayer.add(moveAnimation(duration, toSpotlight: toSpotlight), forKey: nil)
        spotlight = toSpotlight
    }
    
    fileprivate func moveDisappear(_ toSpotlight: SpotlightType, duration: TimeInterval = SpotlightView.defaultAnimateDuration) {
        UIView.animate(withDuration: duration, animations: {
            self.messageView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0);
        }) 
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.appear(toSpotlight, duration: duration)
            self.spotlight = toSpotlight
        }
        disappear(duration)
        CATransaction.commit()
    }
    
    fileprivate func maskPath(_ path: UIBezierPath) -> UIBezierPath {
        return [path].reduce(UIBezierPath(rect: frame)) {
            $0.append($1)
            return $0
        }
    }
    
    fileprivate func appearAnimation(_ duration: TimeInterval, spotlight: SpotlightType) -> CAAnimation {
        let beginPath = maskPath(spotlight.infinitesmalPath)
        let endPath = maskPath(spotlight.path)
        return pathAnimation(duration, beginPath:beginPath, endPath: endPath)
    }
    
    fileprivate func disappearAnimation(_ duration: TimeInterval) -> CAAnimation {
        if (spotlight != nil) {
            let endPath = maskPath(spotlight!.infinitesmalPath)
            return pathAnimation(duration, beginPath:nil, endPath: endPath)
        } else {
            return pathAnimation(duration, beginPath:nil, endPath: UIBezierPath())
        }
    }
    
    fileprivate func moveAnimation(_ duration: TimeInterval, toSpotlight: SpotlightType) -> CAAnimation {
        let endPath = maskPath(toSpotlight.path)
        return pathAnimation(duration, beginPath:nil, endPath: endPath)
    }
    
    fileprivate func pathAnimation(_ duration: TimeInterval, beginPath: UIBezierPath?, endPath: UIBezierPath) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(controlPoints: 0.66, 0, 0.33, 1)
        if let path = beginPath {
            animation.fromValue = path.cgPath
        }
        animation.toValue = endPath.cgPath
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        return animation
    }
}

public enum SpotlightMoveType {
    case direct
    case disappear
}
