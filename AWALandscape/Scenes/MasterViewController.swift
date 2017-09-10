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

class MasterViewController: UIViewController {
    
    // MARK: - Property
    // MARK: Outlet
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
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
            isPlaylist = false
            miniCollectionView.delegate = self
            miniCollectionView.dataSource = self
            miniCollectionView.emptyDataSetSource = self
            miniCollectionView.emptyDataSetDelegate = self
            let layout = ArtworkCollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            miniCollectionView.collectionViewLayout = layout
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
            
            guard let items = musicManager.playlists?[musicManager.currentAlbum].items else {
                
                return
            }
            
            titleLabel.text = items[currentItem].title
            artistLabel.text = items[currentItem].artist
            let image = items[currentItem].artwork?.image(at: playButton.bounds.size)
            playButton.setBackgroundImage(image?.darken(), for: .normal)
            playButton.setTitle(String.fontAwesomeIcon(name: .pause), for: .normal)
            playingSlider.maximumValue = Float(musicManager.duration)
            playingSlider.setValue(0.0, animated: true)
        }
    }
    var centerThreshold: CGFloat = 0.0
    var isPlaylist: Bool! {
        
        didSet {
            
            if isPlaylist {
                
                centerThreshold = miniCollectionView.bounds.width / 6
            } else {
                
                centerThreshold = miniCollectionView.bounds.width / 6
            }
            miniCollectionView.reloadData()
            UIView.animate(withDuration: 0.5, animations: {
                
//                if self.miniCollectionView.numberOfItems(inSection: 0) == 0 {
                    
                    self.miniCollectionView.contentOffset = CGPoint(x: 0.0, y: 0.0)
//                } else if self.isPlaylist {
//                    
//                    let indexPath = IndexPath(row: MusicManager.shared.currentAlbum, section: 0)
//                    self.miniCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
//                } else {
//                    
//                    let indexPath = IndexPath(row: MusicManager.shared.currentItem, section: 0)
//                    self.miniCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
//                }
            })
        }
    }
    var playlistListViewController: PlaylistListViewController!
    var playerViewController: PlayerViewController!
    
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
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        timer.fire()
        
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
    
    deinit {
        
        musicManager.removeObserve(self)
        if timer.isValid {
            
            timer.invalidate()
        }
    }
    
    // MARK: - Notification and Timer
    
    func updateSlider() {
        
        playingSlider.setValue(Float(musicManager.playPosition), animated: true)
        let sliderLength = playingSlider.frame.width
        let ratio = musicManager.playPosition / musicManager.duration
        timeConstraint.constant = sliderLength * CGFloat(ratio)
        let s = Int(musicManager.playPosition) % 60
        let m = Int((musicManager.playPosition - Double(s)) / 60) % 60
        timeLabel.text = String(format: "%02d:%02d", m, s)
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
            
            return musicManager.playlists?.count ?? 0
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
            return cell
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtworkCollectionViewCell.defaultReuseIdentifier, for: indexPath) as! ArtworkCollectionViewCell
            let items = musicManager.playlist?.items
            cell.artworkModel = ArtworkModel(image: items![indexPath.row].artwork?.image(at: CGSize(width: 100, height: 100)), title: items![indexPath.row].title, artist: items![indexPath.row].artist)
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

extension MasterViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemHeight = miniCollectionView.bounds.height / 1.5
        if isPlaylist {
            
            return CGSize(width: itemHeight * 3 / 2, height: itemHeight)
        } else {
         
            return CGSize(width: itemHeight, height: itemHeight + 14.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let itemHeight = miniCollectionView.bounds.height / 1.5
        var horizontalInset: CGFloat = 0.0
        if isPlaylist {
            
            horizontalInset = (miniCollectionView.bounds.width - itemHeight * 3 / 2) / 2
        } else {
            
            horizontalInset = (miniCollectionView.bounds.width - itemHeight) / 2
        }
        return UIEdgeInsetsMake(0.0, horizontalInset, -10.0, horizontalInset)
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
        
        playerViewController.currentAlbum = sender
    
        UIView.animate(withDuration: 0.5, animations: {
            
            self.playerViewController.view.center.x = self.kWidth / 2
        }, completion: { _ in
            
            self.playerViewController.currentItem = 0
            self.isPlaylist = true
        })
    }
}

extension MasterViewController: PlayerViewControllerToMasterDelegate {
    
    func switchPlaylistViewController(_ oldViewController: UIViewController) {
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.playerViewController.view.center.x += self.kWidth
        }, completion: { _ in
            
            self.isPlaylist = false
        })
    }
    
    func hideMasterView() {
        
        playerView.alpha = 0.0
        playButton.alpha = 0.0
        forwardButton.alpha = 0.0
        backwardButton.alpha = 0.0
        playingSlider.alpha = 0.0
        miniCollectionView.alpha = 0.0
    }
    
    func showMasterView() {
        
        playerView.alpha = 1.0
        playButton.alpha = 1.0
        forwardButton.alpha = 1.0
        backwardButton.alpha = 1.0
        playingSlider.alpha = 1.0
        miniCollectionView.alpha = 1.0
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

