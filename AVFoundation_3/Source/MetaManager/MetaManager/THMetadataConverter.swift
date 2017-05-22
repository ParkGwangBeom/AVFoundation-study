//
//  THMetadataConverter.swift
//  MetaManager
//
//  Created by NAVER on 2017. 5. 22..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import Foundation
import AVFoundation

protocol MetadataConverter {
    func displayValue(from metadataItem: AVMetadataItem) -> Any?
    func metadataItem(from displayValue: Any, with metadataItem: AVMetadataItem) -> AVMetadataItem?
}
