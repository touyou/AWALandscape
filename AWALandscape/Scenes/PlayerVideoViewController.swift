//
//  PlayerVideoViewController.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/07.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class PlayerVideoViewController: UIViewController {

    let musicManager = MusicManager.shared
    let videoManager = VideoManager.shared
    
    @IBOutlet weak var playerView: YTPlayerView! {
        
        didSet {
            
            if let id = id {
                
                playerView.load(withVideoId: id)
            }
        }
    }
    
    var currentItem: Int = -1 {
        
        didSet {
            
            if oldValue == currentItem {
                
                return
            }
            
            // Videoの取得とか
            guard let items = musicManager.playlist?.items else {
                
                return
            }
            
            let title = items[currentItem].title
            let artist = items[currentItem].artist

            videoManager.getVideo(title: title ?? "", artist: artist ?? "", completion: { [weak self] id in
                
                guard let `self` = self else {
                    
                    return
                }
                
                self.id = id
                if self.playerView != nil {
                    
                    self.playerView.load(withVideoId: id)
                }
            })
        }
    }
    
    var id: String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if musicManager.playlist?.items != nil {
            
            currentItem = musicManager.currentItem
        }
    }
    
    deinit {
        
        musicManager.removeObserve(self)
    }
    
    @IBAction func touchUpInsideVideoPlay(_ sender: Any) {
    }
    
    func prepare() {
        
        musicManager.addObserve(self)
    }
}

// MARK: - Music

extension PlayerVideoViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "currentItem" {
            
            currentItem = change?[.newKey] as! Int
        }
    }
}

extension PlayerVideoViewController: StoryboardInstantiable {
    
    static var storyboardName: String {
        
        return String(describing: self)
    }
}
