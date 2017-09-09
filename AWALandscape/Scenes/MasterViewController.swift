//
//  ViewController.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/06.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import FontAwesome_swift

class MasterViewController: UIViewController {
    
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
    
    let musicManager = MusicManager.shared
    
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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let playlistViewController = PlaylistListViewController.instantiate()
        addChildViewController(playlistViewController)
        playlistViewController.view.frame = mainContainerView.bounds
        mainContainerView.addSubview(playlistViewController.view)
        playlistViewController.delegate = self
        
        playButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 30.0)
        playButton.titleLabel?.textAlignment = .center
        playButton.setTitle(String.fontAwesomeIcon(name: .play), for: .normal)
        
        forwardButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25.0)
        forwardButton.setTitle(String.fontAwesomeIcon(name: .forward), for: .normal)
        backwardButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25.0)
        backwardButton.setTitle(String.fontAwesomeIcon(name: .backward), for: .normal)
        
        let image = UIImage.colorImage(color: UIColor.AWA.awaOrange, size: CGSize(width: 5, height: 5))
        playingSlider.setThumbImage(image, for: .normal)
        playingSlider.tintColor = UIColor.AWA.awaOrange
        playingSlider.value = 0.0
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        timer.fire()
        
        musicManager.addObserve(self)
        NotificationCenter.default.addObserver(self, selector: #selector(videoStarted), name: .UIWindowDidBecomeVisible, object: view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(videoEnded), name: .UIWindowDidBecomeHidden, object: view.window)
    }
    
    deinit {
        
        musicManager.removeObserve(self)
        if timer.isValid {
            
            timer.invalidate()
        }
    }
    
    func updateSlider() {
        
        playingSlider.setValue(Float(musicManager.playPosition), animated: true)
    }
    
    func videoStarted() {
        
        _ = musicManager.pause()
    }
    
    func videoEnded() {
        
        _ = musicManager.play()
    }
    
    @IBAction func valueChangedPlayingSlider(_ sender: Any) {
        
        musicManager.setTime(TimeInterval(playingSlider.value))
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
}

extension MasterViewController: PlaylistListViewControllerDelegate {
    
    func switchPlayerViewController(_ oldViewController: UIViewController, sender: Int) {
        
        oldViewController.willMove(toParentViewController: nil)
        let playerViewController = PlayerViewController.instantiate()
        playerViewController.currentAlbum = sender
        playerViewController.masterDelegate = self
        addChildViewController(playerViewController)
        playerViewController.view.frame = mainContainerView.bounds
        mainContainerView.addSubview(playerViewController.view)
        playerViewController.view.alpha = 0
        playerViewController.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            
            playerViewController.view.alpha = 1
            oldViewController.view.alpha = 0
        }, completion: { _ in
            
            oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParentViewController()
            playerViewController.didMove(toParentViewController: self)
        })
    }
}

extension MasterViewController: PlayerViewControllerToMasterDelegate {
    
    func switchPlaylistViewController(_ oldViewController: UIViewController) {
        
        oldViewController.willMove(toParentViewController: nil)
        let playlistViewController = PlaylistListViewController.instantiate()
        addChildViewController(playlistViewController)
        playlistViewController.view.frame = mainContainerView.bounds
        mainContainerView.addSubview(playlistViewController.view)
        playlistViewController.delegate = self
        playlistViewController.view.alpha = 0
        playlistViewController.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            
            playlistViewController.view.alpha = 1
            oldViewController.view.alpha = 0
        }, completion: { _ in
            
            oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParentViewController()
            playlistViewController.didMove(toParentViewController: self)
        })
    }
    
    func hideMasterView() {
        
        playerView.alpha = 0.0
        playButton.alpha = 0.0
        forwardButton.alpha = 0.0
        backwardButton.alpha = 0.0
        playingSlider.alpha = 0.0
    }
    
    func showMasterView() {
        
        playerView.alpha = 1.0
        playButton.alpha = 1.0
        forwardButton.alpha = 1.0
        backwardButton.alpha = 1.0
        playingSlider.alpha = 1.0
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

