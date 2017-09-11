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
    
    @IBOutlet weak var lyricTextView: UITextView! {
        
        didSet {
            
            lyricTextView.text = musicManager.lyric ?? "歌詞情報がありません"
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    func prepare() {
    }
}

extension PlayerLyricViewController: StoryboardInstantiable {
    
    static var storyboardName: String {
        
        return String(describing: self)
    }
}
