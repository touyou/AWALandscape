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
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    func setUI() {
        
        titleLabel.text = musicManager.playing?.title ?? "-----"
        artistLabel.text = musicManager.playing?.artist ?? "---"
    }
}

extension PlayerInfoViewController: StoryboardInstantiable {
    
    static var storyboardName: String {
        
        return String(describing: self)
    }
}
