//
//  ShadowStyleLabel.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/11.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit

class ShadowStyleLabel: UILabel {

    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.setShadow(offset: CGSize(width: 0.5, height: 0.5), blur: 6)
        super.draw(rect)
        context?.restoreGState()
    }
}
