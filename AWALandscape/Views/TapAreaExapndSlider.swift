//
//  TapAreaExapndSlider.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/12.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit

@IBDesignable class TapAreaExpandSlider: UISlider {
    
    @IBInspectable var thumbImage: UIImage? {
        didSet {
            setThumbImage(thumbImage, for: .normal)
        }
    }
    
    @IBInspectable var dotLineColor: UIColor = .black
    
    @IBInspectable var top: CGFloat {
        get { return expandEdgeInsets.top }
        set { expandEdgeInsets.top = newValue }
    }
    @IBInspectable var left: CGFloat {
        get { return expandEdgeInsets.left }
        set { expandEdgeInsets.left = newValue }
    }
    @IBInspectable var bottom: CGFloat {
        get { return expandEdgeInsets.bottom }
        set { expandEdgeInsets.bottom = newValue }
    }
    @IBInspectable var right: CGFloat {
        get { return expandEdgeInsets.right }
        set { expandEdgeInsets.right = newValue }
    }
    
    var expandEdgeInsets = UIEdgeInsets.zero
    
    var expandedThumbBounds: CGRect {
        return CGRect(x: thumbBounds.origin.x - expandEdgeInsets.left,
                      y: thumbBounds.origin.y - expandEdgeInsets.top,
                      width: thumbBounds.size.width + expandEdgeInsets.left + expandEdgeInsets.right,
                      height: thumbBounds.size.height + expandEdgeInsets.top + expandEdgeInsets.bottom)
    }
    
    var expandedThumbFrame: CGRect {
        return CGRect(x: thumbFrame.origin.x - expandEdgeInsets.left,
                      y: thumbFrame.origin.y - expandEdgeInsets.top,
                      width: thumbBounds.size.width + expandEdgeInsets.left + expandEdgeInsets.right,
                      height: thumbBounds.size.height + expandEdgeInsets.top + expandEdgeInsets.bottom)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return expandedThumbBounds.contains(point)
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
//        return expandedThumbBounds.contains(location)
        return true
    }
    
    //IB上でのみ実行される処理
    override func prepareForInterfaceBuilder() {
        setThumbImage(thumbImage, for: .normal)
        if expandEdgeInsets == UIEdgeInsets.zero { return }
        let tapGuideView = UIView(frame: expandedThumbBounds)
        let lineLayer = CAShapeLayer()
        lineLayer.frame = tapGuideView.bounds
        lineLayer.strokeColor = dotLineColor.cgColor
        lineLayer.lineWidth = 1
        lineLayer.lineDashPattern = [2, 2]
        lineLayer.fillColor = nil
        lineLayer.path = UIBezierPath(rect: lineLayer.frame).cgPath
        tapGuideView.isUserInteractionEnabled = false
        tapGuideView.backgroundColor = UIColor.clear
        tapGuideView.isHidden = false
        tapGuideView.layer.addSublayer(lineLayer)
        addSubview(tapGuideView)
    }
}

extension UISlider {
    
    var trackBounds: CGRect {
        return trackRect(forBounds: bounds)
    }
    
    var trackFrame: CGRect {
        guard let superView = superview else { return CGRect.zero }
        return self.convert(trackBounds, to: superView)
    }
    
    var thumbBounds: CGRect {
        return thumbRect(forBounds: frame, trackRect: trackBounds, value: value)
    }
    
    var thumbFrame: CGRect {
        return thumbRect(forBounds: bounds, trackRect: trackFrame, value: value)
    }
}
