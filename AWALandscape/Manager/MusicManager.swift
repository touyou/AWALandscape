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
import Alamofire
import SwiftyJSON
import RealmSwift

class MusicManager: NSObject {
    
    static let shared = MusicManager()
    let cache = UserDefaults.standard
    let realm = try! Realm()
    private let albumsQuery = MPMediaQuery.albums()
    private let playlistQuery = MPMediaQuery.playlists()
    let searchWord = ["楽しい", "悲しい", "スポーツ", "盛り上がる", "恋", "公園", "rock", "学校", "ファンク", "泡"]
    
    fileprivate var player: AVAudioPlayer?
    var albums: [MPMediaItemCollection]? {
        
        get {
            
            return albumsQuery.collections
        }
    }
    var playlists: [TYMediaItemCollection] = []
    
    var playing: TYMediaItem?
    var playlist: TYMediaItemCollection? {
        
        get {
            
            if currentAlbum != -1 {
            
                return playlists[currentAlbum]
            } else {
                
                return nil
            }
        }
    }
    var items: [TYMediaItem]? {
        
        get {
            
            return playlist?.items
        }
    }
    var lyric: String? {
        
        get {
         
            return "僕はそれとなく息をして笑った\n青紫の空は　疲れた肌をみせた\n見てたんだ　徒然の折り重なる景色の下\n１人でずっと膝を抱き　揺れる頬は愛らしさ\n\n僕はそれとなく頷いて笑った\n青く光る魂は　疲れた肌を隠した\n見てたんだ　徒然の折り重なる知識の山\n１人でずっと立ち止まり　見えるものは愛らしさ\n\n息をして　息をしてた\n息をして　息をしてた\n\n息をして　息をしてた\n息をして　息をしてた"
        }
    }
    var playPosition: TimeInterval {
        
        get {
            
            return player?.currentTime ?? 0.0
        }
    }
    var duration: TimeInterval {
        
        get {
            
            return player?.duration ?? 1.0
        }
    }
    var isPlaying: Bool {
        
        get {
            
            return player?.isPlaying ?? false
        }
    }
    var shuffleMode: Bool = false
    
    // MARK: KVO監視する
    dynamic var currentItem: Int = 0 {
        
        didSet {
            
            if currentAlbum == -1 {
                
                return
            }
            
            guard let items = items else {
                
                return
            }
            
            _ = pause()
            setMusic(items[currentItem])
            _ = play()
        }
    }
    dynamic var currentAlbum: Int = -1
    
    override init() {
        
        super.init()
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
        }
        
        do {
            try session.setActive(true)
        } catch {
        }
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.togglePlayPauseCommand.addTarget(self, action: #selector(playPause))
        commandCenter.playCommand.addTarget(self, action: #selector(play))
        commandCenter.pauseCommand.addTarget(self, action: #selector(pause))
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(nextMusic))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(previousMusic))
        
        loadSongs()
    }
    
    public func setMusic(_ music: TYMediaItem) {
        
        playing = music
        
        do {
            
//            player = try AVAudioPlayer(contentsOf: url)
            player = try AVAudioPlayer(data: music.musicData)
            player?.delegate = self
            player?.prepareToPlay()
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
    
    func playPause() {
        
        if player?.isPlaying ?? false {
            
            player?.pause()
        } else {
            
            player?.play()
        }
    }
    
    public func setTime(_ time: TimeInterval) {
        
        player?.currentTime = time
    }
    
    public func nextMusic() {
        
        guard let items = items else {
            
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
        MusicManager.shared.addObserver(observer, forKeyPath: "currentAlbum", options: [.new], context: nil)
    }
    
    public func removeObserve(_ observer: NSObject) {
        
        MusicManager.shared.removeObserver(observer, forKeyPath: "currentItem")
        MusicManager.shared.removeObserver(observer, forKeyPath: "currentAlbum")
    }
    
    func loadSongs() {
        
        if let _ = cache.object(forKey: "first") {
            
            playlists = realm.objects(TYMediaItemCollection.self).map { $0 }
        } else {
        
            playlists = []
            
            for word in searchWord {
                
                let str = word.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
                Alamofire.request("https://itunes.apple.com/search?term=\(str)&media=music&entity=song&country=jp&lang=ja_jp&limit=10").responseJSON { response in
                    
                    guard let jsonValue = response.result.value else {
                        
                        return
                    }
                    let json = JSON(jsonValue)
                    
                    let playlist = TYMediaItemCollection()
                    playlist.playlistName = "『\(word)』の曲10選"
                    
                    for itemJson in json["results"].array ?? [] {
                        
                        let item = TYMediaItem()
                        item.title = itemJson["trackName"].string ?? ""
                        item.artist = itemJson["artistName"].string ?? ""
                        let url = itemJson["artworkUrl100"].string!
                        item._artworkUrl = url.replacingOccurrences(of: "100x100bb.jpg", with: "512x512bb.jpg")
    //                    print(url.replacingOccurrences(of: "100x100bb.jpg", with: "512x512bb.jpg"))
                        item.assetURL = URL(string: itemJson["previewUrl"].string!)
                        playlist._items.append(item)
                    }
                    self.playlists.append(playlist)
                    
                    try! self.realm.write {
                        
                        self.realm.add(playlist)
                    }
                }
            }
        
            cache.set("cached", forKey: "first")
        }
    }
}

class TYMediaItemCollection: Object {
    
    var _items = List<TYMediaItem>()
    dynamic var items: [TYMediaItem] {
        
        get {
            
            return _items.map { $0 }
        }
    }
    dynamic var playlistName: String = ""
    dynamic var count: Int {
        
        get {
            
            return items.count
        }
    }
    
    override static func ignoredProperties() -> [String] {
        
        return ["count", "items"]
    }
}

class TYMediaItem: Object {
    
    dynamic var title: String = ""
    dynamic var artist: String = ""
    dynamic var lyrics: String = ""
    dynamic var _artworkUrl: String = ""
    var artwork: URL? {
        
        get {
            
            return URL(string: _artworkUrl)
        }
    }
    dynamic var playCount: Int = 1121
    var assetURL: URL? {
        
        didSet {
            
            let task = URLSession.shared.dataTask(with: assetURL!) { data, response, error in

                DispatchQueue.main.async {
                    
                    try! self.realm?.write {
                        
                        self.musicData = data ?? Data()
                    }
                }
            }
            task.resume()
        }
    }
    dynamic var musicData: Data = Data()
    
    override static func ignoredProperties() -> [String] {
        
        return ["lyrics", "artwork", "playCount", "assetURL"]
    }
}

extension MusicManager: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        guard let items = items else {
            
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
