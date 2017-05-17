//
//  ALAssetsLibrary.swift
//  AVAsset
//
//  Created by NAVER on 2017. 5. 18..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import UIKit
import AssetsLibrary
import AVFoundation

class AssetsLibrary: NSObject {

    func library() {
        let assetLibrary = ALAssetsLibrary()
        assetLibrary.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos, usingBlock: { group, stop in
            group?.setAssetsFilter(ALAssetsFilter.allVideos())
            group?.enumerateAssets(at: IndexSet(integer: 0), options: NSEnumerationOptions.init(rawValue: 0), using: { alAsset, index, innerStop in
                if let representation = alAsset?.defaultRepresentation(), let url = representation.url() {
                    let asset = AVAsset(url: url)
                }
            })
        }) { error in
            
        }
    }
}
