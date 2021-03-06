//
//  ArtworkCollectionViewCell.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/06.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import Lottie
import MarqueeLabel
import PureLayout

class ArtworkCollectionViewCell: UICollectionViewCell, Reusable, NibLoadable {
    
    var artworkModel: ArtworkModel? {
        
        didSet {
            
            imageView.kf.setImage(with: artworkModel?.image, placeholder: #imageLiteral(resourceName: "artwork_sample"))
//            imageView.image = artworkModel?.image
            titleLabel.text = artworkModel?.title
            artistLabel.text = artworkModel?.artist
            miniTitleLabel.text = artworkModel?.title
        }
    }
    
    @IBOutlet weak var imageView: UIImageView! {
        
        didSet {
            
            animationView = LOTAnimationView(name: "trail_loading")
            var size = imageView.bounds.size
            size.width /= 4
            size.height /= 4
            animationView.frame = CGRect(origin: .zero, size: size)
//            var center = imageView.bounds.origin
//            center.x += imageView.bounds.width / 8 * 5
//            center.y += imageView.bounds.height / 8 * 5
//            animationView.center = center
            animationView.loopAnimation = true
            animationView.contentMode = .scaleAspectFit
            animationView.animationSpeed = 1
            
            contentView.addSubview(animationView)
            animationView.autoPinEdge(.bottom, to: .bottom, of: imageView)
            animationView.autoPinEdge(.trailing, to: .trailing, of: imageView)
            animationView.autoMatch(.height, to: .height, of: imageView, withMultiplier: 0.25)
            animationView.autoMatch(.width, to: .width, of: imageView, withMultiplier: 0.25)
        }
    }
    @IBOutlet weak var titleLabel: MarqueeLabel! {
        
        didSet {
            
            titleLabel.fadeLength = 0.0
            titleLabel.type = .continuous
        }
    }
    @IBOutlet weak var artistLabel: MarqueeLabel! {
        
        didSet {
            
            artistLabel.fadeLength = 0.0
            artistLabel.type = .continuous
        }
    }
    @IBOutlet weak var miniTitleLabel: MarqueeLabel! {
        
        didSet {
            
            miniTitleLabel.type = .continuous
        }
    }
    @IBOutlet weak var selectedView: UIView! {
        
        didSet {
            
            selectedView.backgroundColor = UIColor.black
            selectedView.alpha = 0.7
        }
    }
    
    let windowCenter = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
    
    var animationView: LOTAnimationView!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
    
    deinit {
        
        animationView.pause()
    }
    
    func animate(_ collectionView: UICollectionView, _ sourceView: UIView, ratio: CGFloat, size: CGSize, threshold: CGFloat) -> CGRect {
        
        let scaleRatio = max(size.width / imageView.bounds.width, size.height / imageView.bounds.height)
        if threshold * 0.4 < (scaleRatio - 1) * ratio {
            
            self.transform = CGAffineTransform(scaleX: (scaleRatio - 1) * ratio + 1, y: (scaleRatio - 1) * ratio + 1)
        }
        imageView.alpha = 0.0
        return imageView.frame
    }
}
