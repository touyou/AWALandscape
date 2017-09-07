//
//  PlayerInfoViewController.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/07.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import UIKit

class PlayerInfoViewController: UIViewController {
    
    var infoModel = InfomationModel() {
        
        didSet {
            
            let items = MusicManager.shared.playlists[infoModel.currentAlbum].items
            let item = items![infoModel.currentItem]
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
}
