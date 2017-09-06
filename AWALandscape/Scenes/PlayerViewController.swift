//
//  PlayerViewController.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/06.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import MediaPlayer

protocol PlayerViewControllerDelegate: class {
    
    func setSlider(_ ratio: CGFloat)
}

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
    
    weak var delegate: PlayerViewControllerDelegate!
    
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
    var selectorPosition: Int = 0
    var artworkListViewController: ArtworkListViewController!
    var isTouching = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        currentAlbum = 0
        artworkListViewController = storyboard!.instantiateViewController(withIdentifier: "Artwork") as! ArtworkListViewController
        delegate = artworkListViewController
        artworkListViewController.items = items
        addChildViewController(artworkListViewController)
        artworkListViewController.view.frame = containerView.bounds
        containerView.addSubview(artworkListViewController.view)
        containerView.alpha = 0.0
    }
    
    // MARK: - Touch
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            
            return
        }
        
        if isInside(inView: thumbView, point: touch.location(in: view)) {
            
            isTouching = true
            UIView.animate(withDuration: 0.3, animations: {
                
                self.containerView.alpha = 1.0
            })
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
            } else if sliderConstraint.constant > selectScrollBarView.frame.height - thumbView.frame.height {
                
                sliderConstraint.constant = selectScrollBarView.frame.height - thumbView.frame.height
            }
            setPosition()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            
            return
        }
        
        if isTouching {
            
            isTouching = false
            UIView.animate(withDuration: 0.3, animations: {
            
                self.containerView.alpha = 0.0
            })
        }
    }
    
    private func isInside(inView: UIView, point: CGPoint) -> Bool {
        
        return point.x >= inView.frame.origin.x - 10.0 && point.y >= inView.frame.origin.y - 10.0 &&
            point.x <= inView.frame.origin.x + inView.frame.width + 10.0 &&
            point.y <= inView.frame.origin.y + inView.frame.height + 10.0
    }
    
    private func setPosition() {
        
        let unit = selectScrollBarView.frame.height / CGFloat(items!.count)
        selectorPosition = Int(sliderConstraint.constant / unit)
        
        delegate.setSlider(sliderConstraint.constant / selectScrollBarView.frame.height)
    }
}

