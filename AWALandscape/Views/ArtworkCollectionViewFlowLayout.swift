//
//  ArtworkCollectionViewFlowLayout.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/06.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit

class ArtworkCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    static let kItemLength: CGFloat = UIScreen.main.bounds.size.height / 2
    static let horizontalInset = (UIScreen.main.bounds.size.width - kItemLength) / 2
    static let verticalInset = (UIScreen.main.bounds.size.height - kItemLength) / 2
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        let itemLength = ArtworkCollectionViewFlowLayout.kItemLength
        let verticalInset = ArtworkCollectionViewFlowLayout.verticalInset
        let horizontalInset = ArtworkCollectionViewFlowLayout.horizontalInset
        
        self.itemSize = CGSize(width: itemLength, height: itemLength + 50)
        self.minimumLineSpacing = 10.0
        self.scrollDirection = .horizontal
        
        self.sectionInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset)
    }
    
//    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
//        
//        
//    }
}
