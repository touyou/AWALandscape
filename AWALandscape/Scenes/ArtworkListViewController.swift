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
            collectionView.delegate = self
            
            let itemLength = ArtworkCollectionViewFlowLayout.kItemLength
            let verticalInset = ArtworkCollectionViewFlowLayout.verticalInset
            let horizontalInset = ArtworkCollectionViewFlowLayout.horizontalInset
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: itemLength, height: itemLength + 50)
            layout.minimumLineSpacing = 20.0
            layout.minimumInteritemSpacing = 20.0
            layout.sectionInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset)
            layout.scrollDirection = .horizontal
            collectionView.collectionViewLayout = layout
        }
    }
    
    let centerThreshold: CGFloat = UIScreen.main.bounds.width / 6
    var length: CGFloat = 0.0
    var items: [MPMediaItem]! {
        
        didSet {
            
            let count = items.count
            length = (ArtworkCollectionViewFlowLayout.kItemLength + 20.0) * CGFloat(count > 0 ? count - 1 : 0)
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

extension ArtworkListViewController: UICollectionViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        animateCell(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      
        animateCell(scrollView)
    }
    
    func animateCell(_ scrollView: UIScrollView) {
        
        let cells = collectionView.visibleCells
        for cell in cells {
            
            let centerX = cell.center.x - scrollView.contentOffset.x
            let ratio = 1.0 - fabs(view.bounds.width / 2 - centerX) / centerThreshold
            if ratio > 0.0 {
                
                cell.transform = CGAffineTransform(scaleX: 1.0 + 0.4 * ratio, y: 1.0 + 0.4 * ratio)
            } else {
                
                cell.transform = .identity
            }
            if collectionView.indexPath(for: cell)!.row == selected {
                
                collectionView.bringSubview(toFront: cell)
            }
        }

    }
}

extension ArtworkListViewController: PlayerViewControllerDelegate {
    
    func setSlider(_ ratio: CGFloat, position: Int) {
        
        selected = position
        collectionView.contentOffset = CGPoint(x: length * ratio, y: collectionView.contentOffset.y)
    }
}
