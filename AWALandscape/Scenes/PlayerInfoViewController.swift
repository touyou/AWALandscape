//
//  PlayerInfoViewController.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/07.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit
import MediaPlayer

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
    @IBOutlet weak var playlistNameLabel: UILabel!
    @IBOutlet weak var playlistDescriptionLabel: UILabel!
    @IBOutlet weak var dummyLikeButton: UIButton!
    
    var currentItem: Int = 0 {
        
        didSet {
            
            guard let items = musicManager.playlist?.items else {
                
                return
            }
            
            titleLabel.text = items[currentItem].title
            artistLabel.text = items[currentItem].artist
            playlistNameLabel.text = musicManager.playlist?.value(forKey: MPMediaPlaylistPropertyName) as? String
            playlistDescriptionLabel.text = "僕たちがやりました / サイレーン 刑事×彼女×完全悪女 / CRISIS 公安起動操作隊特捜班 / あなたのことはそれほど / ドクターX~外科医・大門未知子~ / セシルのもくろみ / あなたのことはそれほど / 山田孝之のカンヌ映画祭 / 家政婦のミタ   プレイリスト公開：2017/8/30  随時更新"
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        dummyLikeButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 17.0)
        dummyLikeButton.setTitle(String.fontAwesomeIcon(name: .starO) + "255", for: .normal)
        
        musicManager.addObserve(self)
    }
    
    deinit {
        
        musicManager.removeObserve(self)
    }
    
    @IBAction func touchUpInsideDummyLikeButton(_ sender: Any) {
        
        if dummyLikeButton.title(for: .normal) == String.fontAwesomeIcon(name: .starO) + "255" {
            
            dummyLikeButton.setTitle(String.fontAwesomeIcon(name: .star) + "256", for: .normal)
        } else {
            
            dummyLikeButton.setTitle(String.fontAwesomeIcon(name: .starO) + "255", for: .normal)
        }
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
