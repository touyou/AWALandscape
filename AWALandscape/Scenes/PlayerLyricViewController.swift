//
//  PlayerLyricViewController.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/07.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit

class PlayerLyricViewController: UIViewController {

    let musicManager = MusicManager.shared
    
    var timer: Timer!
    
    @IBOutlet weak var lyricTextView: UITextView! {
        
        didSet {
            
            lyricTextView.text = musicManager.lyric ?? "歌詞情報がありません"
            lyricTextView.setContentOffset(CGPoint(x: 0, y: -100), animated: false)
            
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(scrolling), userInfo: nil, repeats: true)
            timer.fire()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    deinit {
        
        if timer.isValid {
            
            timer.invalidate()
        }
    }
    
    func prepare() {
    }
    
    func scrolling() {
        
        let ratio = musicManager.playPosition / (musicManager.duration == 0 ? 1 : musicManager.duration)
        let nextY = -100 + 300 * ratio
        lyricTextView.setContentOffset(CGPoint(x: 0, y: nextY), animated: true)
    }
}

extension PlayerLyricViewController: StoryboardInstantiable {
    
    static var storyboardName: String {
        
        return String(describing: self)
    }
}
