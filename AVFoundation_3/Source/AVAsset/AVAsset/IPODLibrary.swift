//
//  IPODLibrary.swift
//  AVAsset
//
//  Created by NAVER on 2017. 5. 18..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import UIKit
import MediaPlayer

class IPODLibrary: NSObject {
    
    func ipod() {
        let artistPredicate = MPMediaPropertyPredicate(value: "foo", forProperty: MPMediaItemPropertyArtist)
        let albumPredicate = MPMediaPropertyPredicate(value: "good", forProperty: MPMediaItemPropertyAlbumTitle)
        let songPredicate = MPMediaPropertyPredicate(value: "vv", forProperty: MPMediaItemPropertyTitle)
        
        let query = MPMediaQuery(filterPredicates: [artistPredicate, albumPredicate, songPredicate])
        query.items?.forEach {
            let url = $0.value(forKey: MPMediaItemPropertyAssetURL)
            let asset = AVAsset(url: url as! URL)
        }
    }
}
