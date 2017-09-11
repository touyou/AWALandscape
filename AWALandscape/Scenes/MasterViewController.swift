//
//  ViewController.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/06.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import FontAwesome_swift
import DZNEmptyDataSet
import Lottie
import MarqueeLabel

class MasterViewController: UIViewController {
    
    // MARK: - Property
    // MARK: Outlet
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var titleLabel: MarqueeLabel! {
        
        didSet {
            
            titleLabel.fadeLength = 10.0
            titleLabel.type = .continuous
        }
    }
    @IBOutlet weak var artistLabel: MarqueeLabel! {
        
        didSet {
            
            artistLabel.fadeLength = 10.0
            artistLabel.type = .continuous
        }
    }
    @IBOutlet weak var playButton: UIButton! {
        
        didSet {
            
            playButton.cornerRadius = playButton.bounds.width / 2
        }
    }
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var playingSlider: UISlider!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var miniCollectionView: UICollectionView! {
        
        didSet {
            
            miniCollectionView.register(ArtworkCollectionViewCell.self)
            miniCollectionView.register(PlaylistCollectionViewCell.self)
            miniCollectionView.delegate = self
            miniCollectionView.dataSource = self
            miniCollectionView.emptyDataSetSource = self
            miniCollectionView.emptyDataSetDelegate = self
            
            let itemHeight = miniCollectionView.bounds.height / 1.5
            playlistLayout = ArtworkCollectionViewFlowLayout()
            playlistLayout.itemSize = CGSize(width: itemHeight * 3 / 2, height: itemHeight)
            playlistLayout.minimumLineSpacing = 5.0
            playlistLayout.minimumInteritemSpacing = 5.0
            playlistLayout.sectionInset = UIEdgeInsetsMake(0.0, (miniCollectionView.bounds.width - itemHeight * 3 / 2) / 2, -10.0, (miniCollectionView.bounds.width - itemHeight * 3 / 2) / 2)
            playlistLayout.scrollDirection = .horizontal
            
            artworkLayout = ArtworkCollectionViewFlowLayout()
            artworkLayout.itemSize = CGSize(width: itemHeight, height: itemHeight + 14.0)
            artworkLayout.minimumLineSpacing = 5.0
            artworkLayout.minimumInteritemSpacing = 5.0
            artworkLayout.sectionInset = UIEdgeInsetsMake(0.0, (miniCollectionView.bounds.width - itemHeight) / 2, -10.0, (miniCollectionView.bounds.width - itemHeight) / 2)
            artworkLayout.scrollDirection = .horizontal
            
            miniCollectionView.collectionViewLayout = playlistLayout
            
            isPlaylist = false
        }
    }
    @IBOutlet weak var popupImageView: UIImageView! {
        
        didSet {
            
            popupImageView.alpha = 0
        }
    }
    @IBOutlet weak var timeLabel: UILabel! {
        
        didSet {
            
            timeLabel.alpha = 0
        }
    }
    @IBOutlet weak var timeConstraint: NSLayoutConstraint!
    
    
    // MARK: Constant
    let musicManager = MusicManager.shared
    let kWidth = UIScreen.main.bounds.width
    
    // MARK: Variable
    var timer: Timer!
    var currentItem: Int = 0 {
        
        didSet {
            
            guard let items = musicManager.items else {
                
                return
            }
            
            titleLabel.text = items[currentItem].title
            artistLabel.text = items[currentItem].artist
//            let image = items[currentItem].artwork?.image(at: playButton.bounds.size)
//            playButton.setBackgroundImage(image?.darken(), for: .normal)
            playButton.kf.setBackgroundImage(with: items[currentItem].artwork, for: .normal, completionHandler: {
                (image, _, _, _) in
            
                if let image = image {
                    
                    self.playButton.setBackgroundImage(image.darken(), for: .normal)
                }
            })
            playButton.setTitle(String.fontAwesomeIcon(name: .pause), for: .normal)
            playingSlider.maximumValue = Float(musicManager.duration)
            playingSlider.setValue(0.0, animated: true)
        }
    }
    var centerThreshold: CGFloat = 0.0
    var isPlaylist: Bool! {
        
        didSet {
            
            miniCollectionView.reloadData()

            if isPlaylist {
                
                miniCollectionView.collectionViewLayout = playlistLayout
            } else {
                
                miniCollectionView.collectionViewLayout = artworkLayout
            }
            UIView.animate(withDuration: 0.5, animations: {
                
                self.miniCollectionView.contentOffset = CGPoint(x: 0.0, y: self.miniCollectionView.contentOffset.y)
            })
        }
    }
    var playlistListViewController: PlaylistListViewController!
    var playerViewController: PlayerViewController!
    var playlistLayout: ArtworkCollectionViewFlowLayout!
    var artworkLayout: ArtworkCollectionViewFlowLayout!
    var isHide = false

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // MARK: ViewController
        playlistListViewController = PlaylistListViewController.instantiate()
        addChildViewController(playlistListViewController)
        playlistListViewController.view.frame = mainContainerView.bounds
        mainContainerView.addSubview(playlistListViewController.view)
        playlistListViewController.delegate = self
        
        playerViewController = PlayerViewController.instantiate()
        addChildViewController(playerViewController)
        playerViewController.view.frame = mainContainerView.bounds
        mainContainerView.addSubview(playerViewController.view)
        playerViewController.masterDelegate = self
        playerViewController.view.center.x += kWidth
        // 影
        playerViewController.view.layer.masksToBounds = false
        playerViewController.view.layer.shadowOffset = CGSize(width: -2, height: 0)
        playerViewController.view.layer.shadowRadius = 3
        playerViewController.view.layer.shadowOpacity = 0.8
        
        // MARK: Button
        playButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 30.0)
        playButton.titleLabel?.textAlignment = .center
        playButton.setTitle(String.fontAwesomeIcon(name: .play), for: .normal)
        forwardButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25.0)
        forwardButton.setTitle(String.fontAwesomeIcon(name: .forward), for: .normal)
        backwardButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25.0)
        backwardButton.setTitle(String.fontAwesomeIcon(name: .backward), for: .normal)
        
        let image = #imageLiteral(resourceName: "circle")
        playingSlider.setThumbImage(image, for: .normal)
        playingSlider.tintColor = UIColor.AWA.awaOrange
        playingSlider.value = 0.0
        
        musicManager.addObserve(self)
        NotificationCenter.default.addObserver(self, selector: #selector(videoStarted), name: .UIWindowDidBecomeVisible, object: view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(videoEnded), name: .UIWindowDidBecomeHidden, object: view.window)
        
        // MARK: テスト用
        //        let animationView = LOTAnimationView(name: "equalizer_bounce")
        //        animationView.frame = view.bounds
        //        animationView.center = view.center
        //        animationView.loopAnimation = true
        //        animationView.contentMode = .scaleAspectFit
        //        animationView.animationSpeed = 1
        //
        //        view.addSubview(animationView)
        //
        //        animationView.play()
    }
    @IBOutlet weak var playerViewPosition: NSLayoutConstraint!
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    deinit {
        
        musicManager.removeObserve(self)
        if timer.isValid {
            
            timer.invalidate()
        }
    }
    
    // MARK: - Notification and Timer
    
    func updateSlider() {
        
        playingSlider.setValue(Float(musicManager.playPosition), animated: true)
        let sliderLength = playingSlider.bounds.width
        let ratio = musicManager.playPosition / musicManager.duration
        timeConstraint.constant = sliderLength * CGFloat(ratio)
        let s = Int(musicManager.playPosition) % 60
        let m = Int((musicManager.playPosition - Double(s)) / 60) % 60
        timeLabel.text = String(format: "%02d:%02d", m, s)
        
        if musicManager.isPlaying {
            
            playButton.setTitle(String.fontAwesomeIcon(name: .pause), for: .normal)
        } else {
            
            playButton.setTitle(String.fontAwesomeIcon(name: .play), for: .normal)
        }
    }
    
    func videoStarted() {
        
        _ = musicManager.pause()
    }
    
    func videoEnded() {
        
        _ = musicManager.play()
    }
    
    // MARK: - Action
    
    @IBAction func valueChangedPlayingSlider(_ sender: Any) {
        
        musicManager.setTime(TimeInterval(playingSlider.value))
    }
    
    @IBAction func touchDownPlayingSlider(_ sender: Any) {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.popupImageView.alpha = 1
            self.timeLabel.alpha = 1
        })
    }
    
    @IBAction func touchUpInsidePlayingSlider(_ sender: Any) {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.popupImageView.alpha = 0
            self.timeLabel.alpha = 0
        })
    }
    
    
    @IBAction func touchUpInsidePlayButton(_ sender: Any) {
        
        if musicManager.isPlaying {
            
            if musicManager.pause() {
                
                playButton.setTitle(String.fontAwesomeIcon(name: .play), for: .normal)
            }
        } else {
            
            if musicManager.play() {
                
                playButton.setTitle(String.fontAwesomeIcon(name: .pause), for: .normal)
            }
        }
    }
    
    @IBAction func touchUpInsideForwardButton(_ sender: Any) {
        
        musicManager.nextMusic()
    }
    
    @IBAction func touchUpInsideBackwardButton(_ sender: Any) {
        
        musicManager.previousMusic()
    }
    
    @IBAction func touchUpInsidePlayerButton(_ sender: Any) {
        
        if !isPlaylist {
            
            if musicManager.playlist == nil {
                
                return
            }
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.playerViewController.view.center.x = self.kWidth / 2
            }, completion: { _ in
                
                self.isPlaylist = true
            })
        } else {
            
            switchPlaylistViewController(playerViewController)
        }
    }
    
}

// MARK: - CollectionView

extension MasterViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if isPlaylist {
            
            return musicManager.playlists.count 
        } else {
            
            return musicManager.playlist?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if isPlaylist {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCollectionViewCell.defaultReuseIdentifier, for: indexPath) as! PlaylistCollectionViewCell
            cell.currentAlbum = indexPath.row
            cell.titleLabel.isHidden = true
            cell.selectionView.isHidden = true
            cell.animationView.isHidden = true
            cell.infoView.isHidden = true
            return cell
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtworkCollectionViewCell.defaultReuseIdentifier, for: indexPath) as! ArtworkCollectionViewCell
            let items = musicManager.items
            cell.artworkModel = ArtworkModel(image: items![indexPath.row].artwork, title: items![indexPath.row].title, artist: items![indexPath.row].artist)
            cell.artistLabel.isHidden = true
            cell.titleLabel.isHidden = true
            cell.animationView.isHidden = true
            cell.selectedView.isHidden = true
            return cell
        }
    }
}

extension MasterViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isPlaylist {
            
            playerViewController.currentAlbum = indexPath.row
            playerViewController.currentItem = 0
        } else {
            
            musicManager.currentItem = indexPath.row
        }
    }
}

extension MasterViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = "プレイリストが選択されていません。"
        let font = UIFont.systemFont(ofSize: 13)
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
    }
}

// MARK: - Child Transition

extension MasterViewController: PlaylistListViewControllerDelegate {
    
    func switchPlayerViewController(_ oldViewController: UIViewController, sender: Int) {
        
        var flag = true
        if playerViewController.currentAlbum == sender {
            
            flag = false
        }
        playerViewController.currentAlbum = sender
        playerViewController.animateView.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.playerViewController.view.center.x = self.kWidth / 2
            self.showMasterView()
        }, completion: { _ in
            
            self.playerViewController.animateView.center = self.playerViewController.thumbView.center
            self.playerViewController.animateView.alpha = 1
            if flag {
                
                self.playerViewController.currentItem = 0
            }
            self.isPlaylist = true
            self.playlistListViewController.animateCell(self.playlistListViewController.collectionView)
        })
    }
}

extension MasterViewController: PlayerViewControllerToMasterDelegate {
    
    func switchPlaylistViewController(_ oldViewController: UIViewController) {
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.playerViewController.view.center.x = self.kWidth / 2 * 3
        }, completion: { _ in
            
            self.isPlaylist = false
            self.playlistListViewController.isActive = true
        })
    }
    
    func hideMasterView() {
        
        if !isHide {
            
            playerViewPosition.constant = -100
            
            UIView.animate(withDuration: 0.5, animations: {
                
                self.view.layoutIfNeeded()
            })
            isHide = true
        }
    }
    
    func showMasterView() {
        
        if isHide {
            
            playerViewPosition.constant = 0
            UIView.animate(withDuration: 0.5, animations: {
            
                self.view.layoutIfNeeded()
            })
            isHide = false
        }
    }
}

// MARK: - Music

extension MasterViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "currentItem" {
            
            currentItem = change?[.newKey] as! Int
        }
    }
}

