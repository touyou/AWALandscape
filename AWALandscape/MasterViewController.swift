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
    
    let musicManager = MusicManager.shared
    
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
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let playerViewController = PlayerViewController.instantiate()
        addChildViewController(playerViewController)
        playerViewController.view.frame = mainContainerView.bounds
        mainContainerView.addSubview(playerViewController.view)
        
        playButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 30.0)
        playButton.titleLabel?.textAlignment = .center
        playButton.setTitle(String.fontAwesomeIcon(name: .play), for: .normal)
        
        forwardButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25.0)
        forwardButton.setTitle(String.fontAwesomeIcon(name: .forward), for: .normal)
        backwardButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 25.0)
        backwardButton.setTitle(String.fontAwesomeIcon(name: .backward), for: .normal)
        
        musicManager.addObserve(self)
    }
    
    deinit {
        
        musicManager.removeObserve(self)
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

// MARK: - Music

extension MasterViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "currentItem" {
            
            currentItem = change?[.newKey] as! Int
        }
    }
}

