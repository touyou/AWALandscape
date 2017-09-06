//
//  PlayerViewController.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/06.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import MediaPlayer

class PlayerViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectScrollBarView: UIView!
    @IBOutlet weak var thumbView: UIView!
    @IBOutlet weak var sliderConstraint: NSLayoutConstraint! {
        
        didSet {
            
            sliderConstraint.constant = 0
        }
    }
    
    let musicManager = MusicManager.shared
    var items: [MPMediaItem]?
    var currentAlbum: Int = 0 {
        
        didSet {
            
            items = musicManager.albums![currentAlbum].items
        }
    }
    var currentItem: Int = 0 {
        
        didSet {
            
            musicManager.pause()
            musicManager.setMusic(items![currentItem])
            musicManager.play()
        }
    }
    var artworkListViewController: ArtworkListViewController!
    var isTouching = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        artworkListViewController = ArtworkListViewController()
        addChildViewController(artworkListViewController)
        artworkListViewController.view.frame = containerView.bounds
        containerView.addSubview(artworkListViewController.view)
//        artworkListViewController.collectionView.dataSource = self
        containerView.alpha = 0.0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            
            return
        }
        
        if isInside(inView: thumbView, point: touch.location(in: view)) {
            
            isTouching = true
            print("isTouching")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            
            return
        }
        
        if isTouching {
            
            sliderConstraint.constant += touch.location(in: view).y - touch.previousLocation(in: view).y
            if sliderConstraint.constant < 0 {
                sliderConstraint.constant = 0
            } else if sliderConstraint.constant > selectScrollBarView.frame.height {
                sliderConstraint.constant = selectScrollBarView.frame.height
            }
        }
    }
    
    private func isInside(inView: UIView, point: CGPoint) -> Bool {
        
        return point.x >= inView.frame.origin.x - 10.0 && point.y >= inView.frame.origin.y - 10.0 &&
            point.x <= inView.frame.origin.x + inView.frame.width + 10.0 &&
            point.y <= inView.frame.origin.y + inView.frame.height + 10.0
    }
}

class ArtworkListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.register(ArtworkCollectionViewCell.self)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
}

extension PlayerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return items?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtworkCollectionViewCell.defaultReuseIdentifier, for: indexPath) as! ArtworkCollectionViewCell
        
        cell.artworkModel = ArtworkModel(image: items![indexPath.row].artwork?.image(at: CGSize(width: 100, height: 100)), title: items![indexPath.row].title, artist: items![indexPath.row].artist)
        return cell
    }
}
