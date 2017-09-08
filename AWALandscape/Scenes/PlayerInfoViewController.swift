//
//  PlayerInfoViewController.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/07.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit

class PlayerInfoViewController: UIViewController {
    
    let musicManager = MusicManager.shared
    
    @IBOutlet weak var titleLabel: UILabel! {
        
        didSet {
            
            titleLabel.text = musicManager.playing?.title ?? "-----"
        }
    }
    @IBOutlet weak var artistLabel: UILabel! {
        
        didSet {
            
            artistLabel.text = musicManager.playing?.artist ?? "---"
        }
    }
    
    var currentItem: Int = 0 {
        
        didSet {
            
            guard let items = musicManager.playlists?[musicManager.currentAlbum].items else {
                
                return
            }
            
            titleLabel.text = items[currentItem].title
            artistLabel.text = items[currentItem].artist
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        musicManager.addObserve(self)
    }
    
    deinit {
        
        musicManager.removeObserve(self)
    }
    
    func setUI() {
    }
}

extension PlayerInfoViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "currentItem" {
            
            currentItem = change?[.newKey] as! Int
        }
    }
}

extension PlayerInfoViewController: StoryboardInstantiable {
    
    static var storyboardName: String {
        
        return String(describing: self)
    }
}
