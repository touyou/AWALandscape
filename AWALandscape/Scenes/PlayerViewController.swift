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
    func selectMusic(_ ratio: CGFloat, position: Int, rect: CGRect) -> CGRect
    func cancelSelected()
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
            
            let font = UIFont.fontAwesome(ofSize: 33)
            let text = String.fontAwesomeIcon(name: .playCircle)
            playHelperLabel.text = text
            playHelperLabel.font = font
            playHelperLabel.textColor = UIColor.AWA.awaOrange
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
    var previewImageView: UIImageView!
    var items: [TYMediaItem]?
    var currentAlbum: Int = -1 {
        
        didSet {
            
            if oldValue == currentAlbum || currentAlbum == -1 {
                
                return
            }
            
            musicManager.currentAlbum = currentAlbum
            items = musicManager.items
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
                
                artworkImageView.kf.setImage(with: items?[currentItem].artwork, placeholder: #imageLiteral(resourceName: "artwork_sample"))
                //                artworkImageView.image = items![currentItem].artwork?.image(at: artworkImageView.frame.size)
            }
        }
    }
    var selectorPosition: Int = -1 {
        
        didSet {
            
            if oldValue != selectorPosition {
                
                previewImageView.kf.setImage(with: items?[selectorPosition].artwork, placeholder: #imageLiteral(resourceName: "artwork_sample"))
                //                previewImageView.image = items?[selectorPosition].artwork?.image(at: CGSize(width: 1024, height: 1024))
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
    var isReturning = false
    var isDragging = false
    var animTimer: Timer!
    var blurView: UIVisualEffectView!
    var nextRect = CGRect()
    var animateView: UIView!
    var helperTimer: Timer!
    var timerCount = 0
    
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
        
        // Blur
        let lightBlur = UIBlurEffect(style: .regular)
        blurView = UIVisualEffectView(effect: lightBlur)
        blurView.frame = view.bounds
        view.addSubview(blurView)
        view.insertSubview(blurView, belowSubview: containerView)
        blurView.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if currentAlbum != -1 {
            
            currentItem = 0
        }
        // preview用
        previewImageView = UIImageView()
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        view.insertSubview(previewImageView, belowSubview: playHelperLabel)
        previewImageView.alpha = 0
        
        animateView = UIView()
        animateView.backgroundColor = UIColor(displayP3Red: 255, green: 255, blue: 255, alpha: 0.7)
        animateView.frame = thumbView.bounds
        animateView.cornerRadius = animateView.bounds.width / 2
        view.insertSubview(animateView, belowSubview: thumbView)
    }
    
    deinit {
        
        musicManager.removeObserve(self)
        if animTimer.isValid {
            
            animTimer.invalidate()
        }
    }
    
    // MARK: - Timer and Gesture
    
    func animLabel() {
        
        UIView.animate(withDuration: 1.0, animations: {
            
            self.playHelperLabel.alpha = 0.2
        }) { _ in
            
            UIView.animate(withDuration: 1.0, animations: {
                
                self.playHelperLabel.alpha = 1.0
            })
        }
    }
    
    func helperTimerExec() {
        
        if timerCount < 2 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.15) {
                
                UIView.animate(withDuration: 0.7, animations: {
                    
                    self.animateView.center.x = self.playHelperLabel.center.x + 5
                }) { _ in
                    
                    self.animateView.center.x = self.selectScrollBarView.center.x
                }
            }
        }
    }
    
    // MARK: - Action
    
    @IBAction func touchUpInsideExitButton(_ sender: Any) {
        
        masterDelegate.switchPlaylistViewController(self)
    }
    
    @IBAction func touchUpInsideShareButton(_ sender: Any) {
        
        let text = "\(musicManager.playing!.artist)の『\(musicManager.playing!.title)』を聞いています"
        var items: [Any] = [text]
        musicManager.playing?.assetURL.map { items.append($0) }
        artworkImageView.image.map { items.append($0) }
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func touchUpInsideMoreButton(_ sender: Any) {
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.containerView.alpha = 1.0
            self.selectScrollBarView.alpha = 1.0
            self.blurView.alpha = 1.0
            self.view.layoutIfNeeded()
        })
        masterDelegate.hideMasterView()
    }
}

// MARK: - Scroll

extension PlayerViewController: ArtworkListScrollDelegate {
    
    func scrolled(_ ratio: CGFloat) {
        
        sliderConstraint.constant = (selectScrollBarView.frame.height - thumbView.frame.height) * ratio
        animateView.center.y = thumbView.center.y
        
        let unit = (selectScrollBarView.frame.height - thumbView.frame.height)  / CGFloat(items!.count > 0 ? items!.count - 1 : 0)
        
        var judge = -unit / 2
        for i in 0 ..< items!.count {
            
            if judge <= sliderConstraint.constant && sliderConstraint.constant < judge + unit {
                
                selectorPosition = i
            }
            judge += unit
        }
        delegate.setSlider(ratio, position: selectorPosition)
    }
    
    func dragEnded(_ ratio: CGFloat) {
        
        isDragging = false
        
        if playConstraint.constant > 0 {
            
            playConstraint.constant = 0
            selectFlag = false
        } else if playConstraint.constant > -20.0 {
            
            selectFlag = false
        } else if playConstraint.constant < -180.0 {
            
            currentItem = selectorPosition
            selectFlag = false
        } else {
            
            let rate = playConstraint.constant / -180.0
            previewImageView.alpha = 1
            if rate > 0.5 {
                
                let xDist = artworkImageView.frame.origin.x - nextRect.origin.x
                let yDist = artworkImageView.frame.origin.y - nextRect.origin.y
                let nextOrigin = CGPoint(x: xDist * (rate - 0.5) * 2 + nextRect.origin.x, y: yDist * (rate - 0.5) * 2 + nextRect.origin.y)
                previewImageView.frame.origin = nextOrigin
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.containerView.alpha = 0
                    self.blurView.alpha = 0
                })
                selectFlag = true
            } else {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.containerView.alpha = 1
                    self.blurView.alpha = 1
                })
                nextRect = delegate.selectMusic(rate * 2, position: selectorPosition, rect: artworkImageView.bounds)
                previewImageView.frame = nextRect
                selectFlag = false
            }
        }
        
    }
    
    func scrollEnded(_ ratio: CGFloat) {
        
        isDragging = true
        previewImageView.alpha = 0
        delegate.cancelSelected()
    }
    
    func selected(_ select: Int) {
        
        currentItem = select
        resetAnimation()
    }
}

// MARK: - Music

extension PlayerViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "currentItem" {
            
            currentItem = change?[.newKey] as! Int
        } else if keyPath == "currentAlbum" {
            
            sliderConstraint.constant = 0.0
            view.layoutIfNeeded()
            if animateView != nil {
                
                animateView.center = thumbView.center
            }
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
                self.blurView.alpha = 1.0
                self.view.layoutIfNeeded()
            })
            masterDelegate.hideMasterView()
            helperTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(helperTimerExec), userInfo: false, repeats: true)
            helperTimer.fire()
        } else {
            
            isReturning = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            
            return
        }
        
        if isTouching && !isDragging {
            
            playConstraint.constant += touch.location(in: view).x - touch.previousLocation(in: view).x
            previewImageView.alpha = 0
            if playConstraint.constant > 0 {
                
                updateSliderConstraint(touch)
                playConstraint.constant = 0
                selectFlag = false
                delegate.cancelSelected()
            } else if playConstraint.constant > -20.0 {
                
                updateSliderConstraint(touch)
                selectFlag = false
                delegate.cancelSelected()
            } else if playConstraint.constant < -180.0 {
                
                currentItem = selectorPosition
                isTouching = false
                selectFlag = false
            } else {
                
                let rate = playConstraint.constant / -180.0
                previewImageView.alpha = 1
                artworkImageView.alpha = 1 - rate
                if rate > 0.5 {
                    
                    let xDist = artworkImageView.frame.origin.x - nextRect.origin.x
                    let yDist = artworkImageView.frame.origin.y - nextRect.origin.y
                    let nextOrigin = CGPoint(x: xDist * (rate - 0.5) * 2 + nextRect.origin.x, y: yDist * (rate - 0.5) * 2 + nextRect.origin.y)
                    previewImageView.frame.origin = nextOrigin
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        self.containerView.alpha = 0
                        self.blurView.alpha = 0
                    })
                    selectFlag = true
                } else {
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        
                        self.containerView.alpha = 1
                        self.blurView.alpha = 1
                    })
                    nextRect = delegate.selectMusic(rate * 2, position: selectorPosition, rect: artworkImageView.bounds)
                    previewImageView.frame = nextRect
                    selectFlag = false
                }
            }
        } else if isReturning {
            
            view.center.x += touch.location(in: view).x - touch.previousLocation(in: view).x
            if view.center.x < UIScreen.main.bounds.width / 2 {
                
                view.center.x = UIScreen.main.bounds.width / 2
            } else if view.center.x > UIScreen.main.bounds.width / 2 * 3 {
                
                masterDelegate.switchPlaylistViewController(self)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isTouching {
            
            isTouching = false
            if playConstraint.constant < -100.0 {
                
                playConstraint.constant = 0.0
                selectFlag = false
                helperConstraint.constant = -18
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.previewImageView.frame.origin = self.artworkImageView.frame.origin
                    self.containerView.alpha = 0.0
                    self.selectScrollBarView.alpha = 0.0
                    self.blurView.alpha = 0.0
                    self.artworkImageView.alpha = 0.0
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                    
                    self.currentItem = self.selectorPosition
                    self.previewImageView.alpha = 0.0
                    self.artworkImageView.alpha = 1.0
                })
                masterDelegate.showMasterView()
                timerCount += 1
            } else {
                
                resetAnimation()
            }
        } else if isReturning {
            
            if view.center.x > UIScreen.main.bounds.width {
                
                masterDelegate.switchPlaylistViewController(self)
            } else {
                
                UIView.animate(withDuration: 0.5, animations: {
                    
                    self.view.center.x = UIScreen.main.bounds.width / 2
                })
            }
            resetAnimation()
        } else {
            
            resetAnimation()
        }
        
        if helperTimer != nil && helperTimer.isValid {
            
            animateView.center.x = selectScrollBarView.center.x
            helperTimer.invalidate()
        }
    }
    
    func resetAnimation() {
        
        playConstraint.constant = 0.0
        previewImageView.alpha = 0.0
        artworkImageView.alpha = 1.0
        selectFlag = false
        helperConstraint.constant = -18
        UIView.animate(withDuration: 0.5, animations: {
            
            self.containerView.alpha = 0.0
            self.selectScrollBarView.alpha = 0.0
            self.blurView.alpha = 0.0
            self.view.layoutIfNeeded()
        })
        masterDelegate.showMasterView()
    }
    
    func updateSliderConstraint(_ touch: UITouch) {
        
        sliderConstraint.constant += touch.location(in: view).y - touch.previousLocation(in: view).y
        if sliderConstraint.constant < 0 {
            
            sliderConstraint.constant = 0
        } else if sliderConstraint.constant > selectScrollBarView.frame.height - thumbView.frame.height {
            
            sliderConstraint.constant = selectScrollBarView.frame.height - thumbView.frame.height
        }
        animateView.center.y = thumbView.center.y
        setPosition()
    }
    
    private func isInside(inView: UIView, point: CGPoint) -> Bool {
        
        return point.x >= inView.frame.origin.x - 10.0 && point.y >= inView.frame.origin.y - 10.0 &&
            point.x <= inView.frame.origin.x + inView.frame.width + 10.0 &&
            point.y <= inView.frame.origin.y + inView.frame.height + 10.0
    }
    
    fileprivate func setPosition() {
        
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

