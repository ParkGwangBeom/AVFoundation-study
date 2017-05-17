//
//  AsyncLoad.swift
//  AVAsset
//
//  Created by NAVER on 2017. 5. 18..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import UIKit
import AVFoundation

class AsyncLoad: NSObject {
    func async() {
        if let url = Bundle.main.url(forResource: "good", withExtension: "mov") {
            let asset = AVAsset(url: url)
            
            let keys = ["availableMetadataFormats"]
            asset.loadValuesAsynchronously(forKeys: keys) {
                let metadata = asset.availableMetadataFormats.forEach { asset.metadata(forFormat: $0) }
            }
        }
    }
    
    func find() {
        let items: [AVMetadataItem] = []
        let keySpace = AVMetadataKeySpaceiTunes
        let artistKey = AVMetadataiTunesMetadataKeyArtist
        let albumKey = AVMetadataiTunesMetadataKeyAlbum
        let artistMetadata = AVMetadataItem.metadataItems(from: items, withKey: artistKey, keySpace: keySpace)
        let albumMetadata = AVMetadataItem.metadataItems(from: items, withKey: albumKey, keySpace: keySpace)
        
        if !artistMetadata.isEmpty {
            let artistItem = artistMetadata[0]
        }
        
        if !albumMetadata.isEmpty {
            let albumItem = albumMetadata[0]
        }
    }
}
