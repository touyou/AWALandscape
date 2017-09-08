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
    
    func setSlider(_ ratio: CGFloat, position: Int)
}

class PlayerViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectScrollBarView: UIView!
    @IBOutlet weak var thumbView: UIView!
    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var sliderConstraint: NSLayoutConstraint! {
        
        didSet {
            
            sliderConstraint.constant = 0
        }
    }
    @IBOutlet weak var playConstraint: NSLayoutConstraint! {
        
        didSet {
            
            playConstraint.constant = 0
        }
    }
    @IBOutlet weak var previewConstraint: NSLayoutConstraint! {
      
        didSet {
            
            previewConstraint.constant = 0
        }
    }
    @IBOutlet weak var shareButton: UIButton! {
        
        didSet {
            
            shareButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 24.0)
            shareButton.setTitle(String.fontAwesomeIcon(name: .shareSquareO), for: .normal)
        }
    }
    @IBOutlet weak var moreButton: UIButton! {
        
        didSet {
            
            moreButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 24.0)
            moreButton.setTitle(String.fontAwesomeIcon(name: .bars), for: .normal)
        }
    }
    
    
    let musicManager = MusicManager.shared
    let selectionFeedback = UISelectionFeedbackGenerator()
    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    weak var delegate: PlayerViewControllerDelegate!
    var items: [MPMediaItem]?
    var currentAlbum: Int = 0 {
        
        didSet {
            
            items = musicManager.playlists![currentAlbum].items
            musicManager.currentAlbum = currentAlbum
        }
    }
    var currentItem: Int = -1 {
        
        didSet {
            
            if oldValue == currentItem {
                
                return
            }
            
            musicManager.currentItem = currentItem
            
            if artworkImageView != nil {
                
                artworkImageView.image = items![currentItem].artwork?.image(at: artworkImageView.frame.size)
            }
        }
    }
    var selectorPosition: Int = -1 {
        
        didSet {
            
            if oldValue != selectorPosition {
                
                previewImageView.image = items?[selectorPosition].artwork?.image(at: previewImageView.frame.size)
                selectionFeedback.selectionChanged()
            }
        }
    }
    var selectFlag: Bool = false {
        
        didSet {
            
            if oldValue != selectFlag && selectFlag {
                
                impactFeedback.impactOccurred()
            }
        }
    }
    var artworkListViewController: ArtworkListViewController!
    var infoPageViewController: PlayerContentPageViewController!
    var isTouching = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        currentAlbum = 10
        // MARK: ArtworkContainer
        artworkListViewController = storyboard!.instantiateViewController(withIdentifier: "Artwork") as! ArtworkListViewController
        delegate = artworkListViewController
        artworkListViewController.items = items
        addChildViewController(artworkListViewController)
        artworkListViewController.view.frame = containerView.bounds
        containerView.addSubview(artworkListViewController.view)
        containerView.alpha = 0.0
        previewImageView.alpha = 0.0
        
        // MARK: InfoContainer
        infoPageViewController = storyboard!.instantiateViewController(withIdentifier: "InfoPage") as! PlayerContentPageViewController
        addChildViewController(infoPageViewController)
        infoPageViewController.view.frame = infoContainerView.bounds
        infoContainerView.addSubview(infoPageViewController.view)
        
        selectionFeedback.prepare()
        impactFeedback.prepare()
        
        // MARK: 再生状態監視
        musicManager.addObserve(self)
    }
    
    deinit {
        
        musicManager.removeObserve(self)
    }
}

// MARK: - Music

extension PlayerViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "currentItem" {
            
            currentItem = change?[.newKey] as! Int
        }
    }
}

// MARK: - Touch

extension PlayerViewController {
    
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
            
            playConstraint.constant += touch.location(in: view).x - touch.previousLocation(in: view).x
            if playConstraint.constant > 0 {
                
                updateSliderConstraint(touch)
                playConstraint.constant = 0
                selectFlag = false
            } else if playConstraint.constant > -20.0 {
                
                updateSliderConstraint(touch)
                selectFlag = false
            } else if playConstraint.constant < -180.0 {
                
                currentItem = selectorPosition
                isTouching = false
                selectFlag = false
            } else {
                
                let rate = playConstraint.constant / -180.0
                containerView.alpha = 1 - rate
                if rate > 0.5 {
                    
                    previewConstraint.constant = -150 * (rate - 0.5) * 2
                    selectFlag = true
                } else {
                    
//                    updateSliderConstraint(touch)
                    previewImageView.alpha = rate * 2
                    selectFlag = false
                }
            }
        }
    }
    
    func updateSliderConstraint(_ touch: UITouch) {
        
        sliderConstraint.constant += touch.location(in: view).y - touch.previousLocation(in: view).y
        if sliderConstraint.constant < 0 {
            
            sliderConstraint.constant = 0
        } else if sliderConstraint.constant > selectScrollBarView.frame.height - thumbView.frame.height {
            
            sliderConstraint.constant = selectScrollBarView.frame.height - thumbView.frame.height
        }
        setPosition()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isTouching {
            
            isTouching = false
            UIView.animate(withDuration: 0.3, animations: {
                
                self.containerView.alpha = 0.0
            })
            if playConstraint.constant < -100.0 {
                
                self.previewConstraint.constant = -150
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                    
                    self.previewImageView.layoutIfNeeded()
                }, completion: { _ in
                
                    self.currentItem = self.selectorPosition
                })
            }
        }
        
        previewImageView.alpha = 0.0
        previewConstraint.constant = 0.0
        playConstraint.constant = 0.0
        selectFlag = false
    }
    
    private func isInside(inView: UIView, point: CGPoint) -> Bool {
        
        return point.x >= inView.frame.origin.x - 10.0 && point.y >= inView.frame.origin.y - 10.0 &&
            point.x <= inView.frame.origin.x + inView.frame.width + 10.0 &&
            point.y <= inView.frame.origin.y + inView.frame.height + 10.0
    }
    
    private func setPosition() {
        
        let unit = (selectScrollBarView.frame.height - thumbView.frame.height) / CGFloat(items!.count)
        guard Int(floor(sliderConstraint.constant / unit)) < items!.count else {
            
            return
        }
        
        selectorPosition = Int(floor(sliderConstraint.constant / unit))
        
        delegate.setSlider(sliderConstraint.constant / (selectScrollBarView.frame.height - thumbView.frame.height), position: selectorPosition)
    }
}

extension PlayerViewController: StoryboardInstantiable {
    
    static var storyboardName: String {
        
        return String(describing: self)
    }
}

