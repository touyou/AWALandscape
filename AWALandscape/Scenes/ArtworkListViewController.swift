//
//  ArtworkListViewController.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/06.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import MediaPlayer

class ArtworkListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.register(ArtworkCollectionViewCell.self)
            collectionView.dataSource = self
        }
    }
    @IBOutlet weak var flowLayout: ArtworkCollectionViewFlowLayout!
    
    var length: CGFloat = 0.0
    var items: [MPMediaItem]! {
        
        didSet {
            
            length = ArtworkCollectionViewFlowLayout.kItemLength * CGFloat(items.count) + ArtworkCollectionViewFlowLayout.kItemLength * 0.5
            if items.count > 0 {
                
                length += 20.0 * CGFloat(items.count - 1)
            }
        }
    }
    var selected: Int = 0 {
        
        didSet {
            
            if oldValue != selected {
                
                collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
}

extension ArtworkListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return items?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtworkCollectionViewCell.defaultReuseIdentifier, for: indexPath) as! ArtworkCollectionViewCell
        
        cell.artworkModel = ArtworkModel(image: items![indexPath.row].artwork?.image(at: CGSize(width: 100, height: 100)), title: items![indexPath.row].title, artist: items![indexPath.row].artist)
        
        if selected == indexPath.row {
            
            cell.artistLabel.isHidden = false
            cell.titleLabel.isHidden = false
        } else {
            
            cell.artistLabel.isHidden = true
            cell.titleLabel.isHidden = true
        }
        
        return cell
    }
}

extension ArtworkListViewController: PlayerViewControllerDelegate {
    
    func setSlider(_ ratio: CGFloat, position: Int) {
        
        flowLayout.position = position
        selected = position
        collectionView.contentOffset = CGPoint(x: length * ratio, y: collectionView.contentOffset.y)
    }
}
