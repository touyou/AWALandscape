//
//  ArtworkListViewController.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/06.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import MediaPlayer

protocol ArtworkListScrollDelegate: class {
    
    func scrolled(_ ratio: CGFloat)
    func dragEnded(_ ratio: CGFloat)
    func scrollEnded(_ ratio: CGFloat)
    func selected(_ select: Int)
}

class ArtworkListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.register(ArtworkCollectionViewCell.self)
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.backgroundColor = UIColor.clear
            
            let itemLength = ArtworkCollectionViewFlowLayout.kItemLength
            let verticalInset = ArtworkCollectionViewFlowLayout.verticalInset
            let horizontalInset = ArtworkCollectionViewFlowLayout.horizontalInset
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: itemLength, height: itemLength + 70)
            layout.minimumLineSpacing = 20.0
            layout.minimumInteritemSpacing = 20.0
            layout.sectionInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset)
            layout.scrollDirection = .horizontal
            collectionView.collectionViewLayout = layout
        }
    }
    
    let musicManager = MusicManager.shared
    let centerThreshold: CGFloat = UIScreen.main.bounds.width / 6
    
    weak var delegate: ArtworkListScrollDelegate!
    var length: CGFloat = 0.0
    var items: [TYMediaItem]! {
        
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
        musicManager.addObserve(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(exitView))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        
        musicManager.removeObserve(self)
    }
    
    func exitView() {
        
        delegate.selected(-1)
    }
}

extension ArtworkListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return items?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtworkCollectionViewCell.defaultReuseIdentifier, for: indexPath) as! ArtworkCollectionViewCell
        
        cell.artworkModel = ArtworkModel(image: items![indexPath.row].artwork, title: items![indexPath.row].title, artist: items![indexPath.row].artist)
        
        let centerX = cell.center.x - collectionView.contentOffset.x
        let ratio = 1.0 - fabs(view.bounds.width / 2 - centerX) / centerThreshold
        if ratio > 0.0 {
            
            cell.transform = CGAffineTransform(scaleX: 1.0 + 0.4 * ratio, y: 1.0 + 0.4 * ratio)
        } else {
            
            cell.transform = .identity
        }
        
        if selected == indexPath.row {
            
            cell.selectedView.isHidden = true
            cell.titleLabel.unpauseLabel()
            cell.artistLabel.unpauseLabel()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                
                collectionView.bringSubview(toFront: cell)
            })
        } else {
            
            cell.selectedView.isHidden = false
            cell.titleLabel.pauseLabel()
            cell.artistLabel.pauseLabel()
        }
        
        if indexPath.row == musicManager.currentItem {
            
            cell.animationView.isHidden = false
            cell.animationView.play()
        } else {
            
            cell.animationView.isHidden = true
            cell.animationView.pause()
        }
        cell.miniTitleLabel.isHidden = true
        cell.miniTitleLabel.pauseLabel()
        cell.imageView.alpha = 1.0
        
        return cell
    }
}

extension ArtworkListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        let centerX = cell!.center.x - collectionView.contentOffset.x
        let ratio = 1.0 - fabs(view.bounds.width / 2 - centerX) / centerThreshold
        if ratio > 0.0 {
            
            delegate.selected(indexPath.row)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        animateCell(scrollView)
        delegate.scrollEnded(0.0)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      
        delegate.scrolled(scrollView.contentOffset.x / length)
        animateCell(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        delegate.dragEnded(scrollView.contentOffset.x / length)
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

extension ArtworkListViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "currentAlbum" {
            
            collectionView.reloadData()
            collectionView.contentOffset = CGPoint(x: 0.0, y: collectionView.contentOffset.y)
        } else if keyPath == "currentItem" {
            
            collectionView.reloadData()
        }
    }
}

extension ArtworkListViewController: PlayerViewControllerDelegate {
    
    func setSlider(_ ratio: CGFloat, position: Int) {
        
        selected = position
        collectionView.contentOffset = CGPoint(x: length * ratio, y: collectionView.contentOffset.y)
    }
    
    func selectMusic(_ ratio: CGFloat, position: Int, rect: CGRect) -> CGRect {
        
        let indexPath = IndexPath(row: position, section: 0)
        guard let cell = collectionView.cellForItem(at: indexPath) as? ArtworkCollectionViewCell else {
            
            return rect
        }
        
        let centerX = cell.center.x - collectionView.contentOffset.x
        let ratioThreshold = 1.0 - fabs(view.bounds.width / 2 - centerX) / centerThreshold
        
        let originalFrame = cell.animate(collectionView, view, ratio: ratio, size: rect.size, threshold: ratioThreshold)
        return cell.convert(originalFrame, to: view)
    }
    
    func cancelSelected() {
        
        let cells = collectionView.visibleCells
        _ = cells.map { ($0 as! ArtworkCollectionViewCell).imageView.alpha = 1 }
    }
}

extension ArtworkListViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if collectionView.indexPathForItem(at: touch.location(in: collectionView)) != nil {
            
            return false
        }
        
        return true
    }
}
