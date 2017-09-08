//
//  VideoManager.swift
//  AWALandscape
//
//  Created by 藤井陽介 on 2017/09/08.
//  Copyright © 2017年 藤井陽介. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class VideoManager {
    
    static let shared = VideoManager()
    
    private let apiKey = "AIzaSyAsowKTiCBepnMuCKOnvTQ56unaQFQzH94"
    let baseUrl = "https://www.googleapis.com/youtube/v3/search?key="
    
    func getVideo(title: String, artist: String, completion: @escaping (String)->()) {
        
        let searchWord = String("\(title) \(artist)").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlText = baseUrl + apiKey + "&q=\(searchWord)&part=snippet&maxResults=10&order=viewCount"
        
        Alamofire.request(urlText).responseJSON { response in
            
            print(response)
            guard let jsonValue = response.result.value else {
                
                return
            }
            
            let json = JSON(jsonValue)
            print(json)
            guard let id = json["items"].array?.first?["id"].dictionaryObject?["videoId"] as? String else {
                
                return
            }
            
            completion(id)
        }
    }
}
