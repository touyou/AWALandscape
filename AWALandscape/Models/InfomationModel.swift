//
//  InfomationModel.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/07.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import Foundation

class InfomationModel {
    
    var currentAlbum: Int?
    var currentItem: Int?
    
    init(currentAlbum: Int, currentItem: Int) {
        
        self.currentAlbum = currentAlbum
        self.currentItem = currentItem
    }
    
}
