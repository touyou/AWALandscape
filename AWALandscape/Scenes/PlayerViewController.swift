//
//  PlayerViewController.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/06.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import MediaPlayer
import FontAwesome_swift

// MARK: - Protocol

protocol PlayerViewControllerDelegate: class {
    
    func setSlider(_ ratio: CGFloat, position: Int)
}

protocol PlayerViewControllerToMasterDelegate: class {
    
    func switchPlaylistViewController(_ oldViewController: UIViewController)
    func hideMasterView()
    func showMasterView()
}

class PlayerViewController: UIViewController {
    
    // MARK: - Property
    // MARK: Outlet
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectScrollBarView: UIView! {
        
        didSet {
            
            selectScrollBarView.alpha = 0.0
        }
    }
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
    @IBOutlet weak var exitButton: UIButton! {
        
        didSet {
            
            exitButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 30.0)
            exitButton.setTitle(String.fontAwesomeIcon(name: .arrowLeft), for: .normal)
        }
    }
    @IBOutlet weak var playHelperLabel: UILabel! {
        
        didSet {
            
            let font = UIFont.fontAwesome(ofSize: 30)
            let text = String.fontAwesomeIcon(name: .playCircle)
            playHelperLabel.text = text
            playHelperLabel.font = font
            animTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(animLabel), userInfo: nil, repeats: true)
            animTimer.fire()
        }
    }
    @IBOutlet weak var helperConstraint: NSLayoutConstraint! {
        
        didSet {
            
            helperConstraint.constant = -18
        }
    }
    
    // MARK: Constant
    
    let musicManager = MusicManager.shared
    let selectionFeedback = UISelectionFeedbackGenerator()
    let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    // MARK: Variable
    
    weak var delegate: PlayerViewControllerDelegate!
    weak var masterDelegate: PlayerViewControllerToMasterDelegate!
    var items: [MPMediaItem]?
    var currentAlbum: Int = -1 {
        
        didSet {
            
            if oldValue == currentAlbum || currentAlbum == -1 {
                
                return
            }
            
            musicManager.currentAlbum = currentAlbum
            items = musicManager.playlist?.items
            currentItem = -1
            
            if artworkListViewController != nil {
                
                artworkListViewController.items = items
            }
        }
    }
    var currentItem: Int = -1 {
        
        didSet {
            
            if oldValue == currentItem || currentItem == -1 {
                
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
    var animTimer: Timer!
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // MARK: ArtworkContainer
        artworkListViewController = storyboard!.instantiateViewController(withIdentifier: "Artwork") as! ArtworkListViewController
        artworkListViewController.items = items ?? []
        delegate = artworkListViewController
        addChildViewController(artworkListViewController)
        artworkListViewController.view.frame = containerView.bounds
        artworkListViewController.delegate = self
        containerView.addSubview(artworkListViewController.view)
        containerView.alpha = 0.0
        previewImageView.alpha = 0.0
        
        // MARK: InfoContainer
        infoPageViewController = storyboard!.instantiateViewController(withIdentifier: "InfoPage") as! PlayerContentPageViewController
        addChildViewController(infoPageViewController)
        infoPageViewController.view.frame = infoContainerView.bounds
        infoContainerView.addSubview(infoPageViewController.view)
        infoPageViewController.prepare()
        
        selectionFeedback.prepare()
        impactFeedback.prepare()
        
        // MARK: 再生状態監視
        musicManager.addObserve(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if currentAlbum != -1 {
            
            currentItem = 0
        }
    }
    
    deinit {
        
        musicManager.removeObserve(self)
        if animTimer.isValid {
            
            animTimer.invalidate()
        }
    }
    
    // MARK: - Timer
    
    func animLabel() {
        
        UIView.animate(withDuration: 1.0, animations: {
            
            self.playHelperLabel.alpha = 0.2
        }) { _ in
            
            UIView.animate(withDuration: 1.0, animations: {
                
                self.playHelperLabel.alpha = 1.0
            })
        }
    }
    
    // MARK: - Action
    
    @IBAction func touchUpInsideExitButton(_ sender: Any) {
        
        masterDelegate.switchPlaylistViewController(self)
    }
}

// MARK: - Scroll

extension PlayerViewController: ArtworkListScrollDelegate {
    
    func scrolled(_ ratio: CGFloat) {
        
        sliderConstraint.constant = (selectScrollBarView.frame.height - thumbView.frame.height) * ratio
        
        let unit = (selectScrollBarView.frame.height - thumbView.frame.height)  / CGFloat(items!.count > 0 ? items!.count - 1 : 0)
        
        var judge = -unit / 2
        for i in 0 ..< items!.count {
            
            if judge <= sliderConstraint.constant && sliderConstraint.constant < judge + unit {
                
                selectorPosition = i
            }
            judge += unit
        }

    }
}

// MARK: - Music

extension PlayerViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "currentItem" {
            
            currentItem = change?[.newKey] as! Int
        } else if keyPath == "currentAlbum" {
            
            sliderConstraint.constant = 0.0
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
            helperConstraint.constant = 90
            UIView.animate(withDuration: 0.5, animations: {
                
                self.containerView.alpha = 1.0
                self.selectScrollBarView.alpha = 1.0
                self.masterDelegate.hideMasterView()
                self.playHelperLabel.layoutIfNeeded()
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
                    
                    previewConstraint.constant = -180 * (rate - 0.5) * 2
                    selectFlag = true
                } else {
                    
                    previewImageView.alpha = rate * 2
                    selectFlag = false
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isTouching {
            
            isTouching = false
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
        helperConstraint.constant = -18
        UIView.animate(withDuration: 0.5, animations: {
            
            self.containerView.alpha = 0.0
            self.selectScrollBarView.alpha = 0.0
            self.masterDelegate.showMasterView()
            self.playHelperLabel.layoutIfNeeded()
        })
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
    
    private func isInside(inView: UIView, point: CGPoint) -> Bool {
        
        return point.x >= inView.frame.origin.x - 10.0 && point.y >= inView.frame.origin.y - 10.0 &&
            point.x <= inView.frame.origin.x + inView.frame.width + 10.0 &&
            point.y <= inView.frame.origin.y + inView.frame.height + 10.0
    }
    
    private func setPosition() {
        
        let unit = (selectScrollBarView.frame.height - thumbView.frame.height)  / CGFloat(items!.count > 0 ? items!.count - 1 : 0)
        
        var judge = -unit / 2
        for i in 0 ..< items!.count {
            
            if judge <= sliderConstraint.constant && sliderConstraint.constant < judge + unit {
                
                selectorPosition = i
            }
            judge += unit
        }
        
        delegate.setSlider(sliderConstraint.constant / (selectScrollBarView.frame.height - thumbView.frame.height), position: selectorPosition)
    }
}

// MARK: - Storyboard Instantiable

extension PlayerViewController: StoryboardInstantiable {
    
    static var storyboardName: String {
        
        return String(describing: self)
    }
}

