//
//  PlaylistCollectionViewCell.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/08.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import MediaPlayer
import Lottie
import Kingfisher

class PlaylistCollectionViewCell: UICollectionViewCell, NibLoadable, Reusable {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var sub1ImageView: UIImageView!
    @IBOutlet weak var sub2ImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var miniTitleLabel: UILabel!
    @IBOutlet weak var selectionView: UIView! {
        
        didSet {
            
            selectionView.backgroundColor = UIColor.black
            selectionView.alpha = 0.7
        }
    }
    @IBOutlet weak var playingView: UIView! {
        
        didSet {
            
            animationView = LOTAnimationView(name: "trail_loading")
            animationView.frame = CGRect(origin: .zero, size: playingView.bounds.size)
            animationView.center = contentView.center
            animationView.loopAnimation = true
            animationView.contentMode = .scaleAspectFit
            animationView.animationSpeed = 1
            
            contentView.addSubview(animationView)
            animationView.play()
        }
    }
    @IBOutlet weak var infoView: UIView!
    
    let musicManager = MusicManager.shared
    
    var animationView: LOTAnimationView!
    var images = [URL]()
    var currentAlbum: Int = 0 {
        
        didSet {
            
            let items = musicManager.playlists[currentAlbum].items
            
            titleLabel.text = musicManager.playlists[currentAlbum].playlistName
//            titleLabel.text = musicManager.playlists[currentAlbum].value(forKeyPath: MPMediaPlaylistPropertyName) as? String
            miniTitleLabel.text = titleLabel.text
            images.removeAll()
            for item in items {
                
                if let image = item.artwork {
                    
                    images.append(image)
                }
            }
            
            mainImageView.kf.setImage(with: images[0], placeholder: #imageLiteral(resourceName: "artwork_sample"))
            sub1ImageView.kf.setImage(with: images[1], placeholder: #imageLiteral(resourceName: "artwork_sample"))
            sub2ImageView.kf.setImage(with: images[2], placeholder: #imageLiteral(resourceName: "artwork_sample"))
//            mainImageView.image = imagesIterator.next() ?? #imageLiteral(resourceName: "artwork_sample")
//            sub1ImageView.image = imagesIterator.next() ?? #imageLiteral(resourceName: "artwork_sample")
//            sub2ImageView.image = imagesIterator.next() ?? #imageLiteral(resourceName: "artwork_sample")
        }
    }
    var animTimer: Timer?

    override func awakeFromNib() {
        
        super.awakeFromNib()
    }
}
