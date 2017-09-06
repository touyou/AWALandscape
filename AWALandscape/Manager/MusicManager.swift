//
//  MusicManager.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/06.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class MusicManager {
    
    static let shared = MusicManager()
    private let albumsQuery = MPMediaQuery.albums()
    
    var player: AVAudioPlayer?
    var albums: [MPMediaItemCollection]? {
        
        get {
            
            return albumsQuery.collections
        }
    }
    
    init() {
    }
    
    public func setMusic(_ music: MPMediaItem) {
        
        guard let url = music.assetURL else {
            
            return
        }
        
        do {
            
            player = try AVAudioPlayer(contentsOf: url)
        } catch {
        }
    }
    
    public func play() {
        
        player?.play()
    }
    
    public func pause() {
        
        player?.pause()
    }
}
