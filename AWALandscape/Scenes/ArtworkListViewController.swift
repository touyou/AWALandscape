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
    
    var length: CGFloat = 0.0
    var items: [MPMediaItem]! {
        
        didSet {
            
            length = ArtworkCollectionViewFlowLayout.kItemLength * CGFloat(items.count)
            if items.count > 0 {
                
                length += 10.0 * CGFloat(items.count - 1)
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
        return cell
    }
}

extension ArtworkListViewController: PlayerViewControllerDelegate {
    
    func setSlider(_ ratio: CGFloat) {
        
        collectionView.contentOffset = CGPoint(x: length * ratio, y: collectionView.contentOffset.y)
    }
}
