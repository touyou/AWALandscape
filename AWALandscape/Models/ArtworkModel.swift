//
//  ArtworkModel.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/06.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import Foundation
import UIKit

class ArtworkModel: NSObject {
    
    var image: UIImage?
    var title: String?
    var artist: String?
    
    init(image: UIImage?, title: String?, artist: String?) {
        
        self.image = image
        self.title = title
        self.artist = artist
    }
}
