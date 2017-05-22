//
//  ArtworkMetadataConverter.swift
//  MetaManager
//
//  Created by NAVER on 2017. 5. 22..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import Cocoa
import AVFoundation

class ArtworkMetadataConverter: NSObject, MetadataConverter {

    func displayValue(from metadataItem: AVMetadataItem) -> Any? {
        let image: NSImage?
        if metadataItem.value is Data {
            image = NSImage(data: metadataItem.dataValue!)
        } else if metadataItem.value is [String: Data] {
            if let dict = metadataItem.value as? [String: Data], let data = dict["data"] as? Data {
                image = NSImage(data: data)
            }
        }
        return image
    }
    
    func metadataItem(from displayValue: Any, with metadataItem: AVMetadataItem) -> AVMetadataItem? {
        let item = metadataItem.mutableCopy() as! AVMetadataItem
//        let image = displayValue as NSImage
        return item
    }
}
