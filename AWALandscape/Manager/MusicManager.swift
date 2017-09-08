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

class MusicManager: NSObject {
    
    static let shared = MusicManager()
    private let albumsQuery = MPMediaQuery.albums()
    private let playlistQuery = MPMediaQuery.playlists()
    
    fileprivate var player: AVAudioPlayer?
    var albums: [MPMediaItemCollection]? {
        
        get {
            
            return albumsQuery.collections
        }
    }
    var playlists: [MPMediaItemCollection]? {
        
        get {
            
            return playlistQuery.collections
        }
    }
    var playing: MPMediaItem?
    var lyric: String?
    var playPosition: TimeInterval {
        
        get {
            
            return player?.currentTime ?? 0.0
        }
    }
    var isPlaying: Bool {
        
        get {
            
            return player?.isPlaying ?? false
        }
    }
    
    // MARK: KVO監視する
    dynamic var currentItem: Int = 0 {
        
        didSet {
            
            guard let items = playlists?[currentAlbum].items else {
                
                return
            }
            
            _ = pause()
            setMusic(items[currentItem])
            _ = play()
            print("再生")
        }
    }
    var currentAlbum: Int = 0
    
    override init() {
    }
    
    public func setMusic(_ music: MPMediaItem) {
        
        guard let url = music.assetURL else {
            
            return
        }
        
        playing = music
        
        do {
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.delegate = self
        } catch {
            
            player = nil
        }
    }
    
    public func play() -> Bool {
        
        return player?.play() ?? false
    }
    
    public func pause() -> Bool {
        
        if let player = player {
            
            player.pause()
            return true
        } else {
            
            return false
        }
    }
    
    public func nextMusic() {
        
        guard let items = playlists?[currentAlbum].items else {
            
            return
        }
        
        if currentItem < items.count - 1 {
            
            currentItem += 1
        }
    }
    
    public func previousMusic() {
        
        if currentItem > 0 {
            
            currentItem -= 1
        }
    }
    
    public func addObserve(_ observer: NSObject) {
        
        MusicManager.shared.addObserver(observer, forKeyPath: "currentItem", options: [.new], context: nil)
    }
    
    public func removeObserve(_ observer: NSObject) {
        
        MusicManager.shared.removeObserver(observer, forKeyPath: "currentItem")
    }
}

extension MusicManager: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        guard let items = playlists?[currentAlbum].items else {
            
            return
        }
        
        if currentItem >= items.count - 1 {
            
            _ = pause()
            self.player = nil
        } else {
            
            currentItem += 1
        }
    }
}
