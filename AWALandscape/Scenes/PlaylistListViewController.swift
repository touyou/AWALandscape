
//
//  PlaylistListViewController.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/08.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit

class PlaylistListViewController: UIViewController {
    
    let musicManager = MusicManager.shared

    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
}

extension PlaylistListViewController: StoryboardInstantiable {
    
    static var storyboardName: String {
        
        return String(describing: self)
    }
}
