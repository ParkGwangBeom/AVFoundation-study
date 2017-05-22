//
//  DefaultMetadataConverter.swift
//  MetaManager
//
//  Created by NAVER on 2017. 5. 22..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import Cocoa
import AVFoundation

class DefaultMetadataConverter: MetadataConverter {
    
    func displayValue(from metadataItem: AVMetadataItem) -> Any? {
        return metadataItem.value
    }
    
    func metadataItem(from displayValue: Any, with metadataItem: AVMetadataItem) -> AVMetadataItem? {
        var item: AVMetadataItem = metadataItem.copy() as! AVMetadataItem
//        item.value = displayValue ??
        return item
    }
}
