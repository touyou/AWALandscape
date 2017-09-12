//
//  ShadowStyleLabel.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/11.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit

class ShadowStyleLabel: UILabel {
    
    @IBInspectable var shadowSize: CGFloat = 0.5

    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.setShadow(offset: CGSize(width: shadowSize, height: shadowSize), blur: 6)
        super.draw(rect)
        context?.restoreGState()
    }
}
