//
//  PlayerVideoViewController.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/07.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit

class PlayerVideoViewController: UIViewController {

    let musicManager = MusicManager.shared
    
    @IBOutlet weak var videoImageView: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    @IBAction func touchUpInsideVideoPlay(_ sender: Any) {
    }
    
    func setUI() {
        
        
    }
}

extension PlayerVideoViewController: StoryboardInstantiable {
    
    static var storyboardName: String {
        
        return String(describing: self)
    }
}
