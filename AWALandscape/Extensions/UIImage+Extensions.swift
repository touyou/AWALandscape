//
//  UIImage+Extensions.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/08.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit

extension UIImage {
    
    func darken() -> UIImage {
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0)
        self.draw(in: rect)
        self.draw(in: rect, blendMode: .difference, alpha: 0.3)
        let blendedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return blendedImage
    }
}
