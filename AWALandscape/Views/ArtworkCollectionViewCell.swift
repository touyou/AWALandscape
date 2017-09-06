//
//  ArtworkCollectionViewCell.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/06.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit

class ArtworkCollectionViewCell: UICollectionViewCell, Reusable, NibLoadable {
    
    var artworkModel: ArtworkModel? {
        
        didSet {
            
            imageView.image = artworkModel?.image
            titleLabel.text = artworkModel?.title
            artistLabel.text = artworkModel?.artist
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
}
