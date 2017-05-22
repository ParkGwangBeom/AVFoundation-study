//
//  MediaItem.swift
//  MetaManager
//
//  Created by NAVER on 2017. 5. 22..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import Cocoa
import AVFoundation

typealias CompletionHanlder = (Bool) -> Void
let CommonMetaKey = "commonMetadata"
let AvailableMetaKey = "availableMetadataFormats"

class MediaItem: NSObject {
    var filename: String?
    var filetype: String?
    var metadata: Metadata?
    var isEditable = false
    
    var url: URL
    var asset: AVAsset
    var acceptedFormats: [String] = []
    var prepared = false
    
    init(url: URL) {
        self.url = url
        self.asset = AVAsset(url: url)
        self.filename = url.lastPathComponent

        acceptedFormats = [AVMetadataFormatQuickTimeMetadata,
                           AVMetadataFormatiTunesMetadata,
                           AVMetadataFormatID3Metadata]
        
        super.init()
        
        self.filetype = self.fileTpyefor(url)
        
        // ID3은 메타 데이터를 읽을 수는 있지만 기록할 수는 없음.
        self.isEditable = filetype != AVFileTypeMPEGLayer3
    }
    
    func fileTpyefor(_ url: URL) -> String {
        let ex = self.url.lastPathComponent as NSString
        let ext = ex.pathExtension
        switch ext {
        case "m4a": return AVFileTypeAppleM4A
        case "m4v": return AVFileTypeAppleM4V
        case "mov": return AVFileTypeQuickTimeMovie
        case "mp4": return AVFileTypeMPEG4
        default: return AVFileTypeMPEGLayer3
        }
    }
    
    func prepare(with completionHandler: @escaping CompletionHanlder) {
        guard !self.prepared else {
            completionHandler(self.prepared)
            return
        }
        
        self.metadata = Metadata()
        
        let keys = [CommonMetaKey, AvailableMetaKey]
        asset.loadValuesAsynchronously(forKeys: keys) { 
            let commonStatus = self.asset.statusOfValue(forKey: CommonMetaKey, error: nil)
            let formataStatus = self.asset.statusOfValue(forKey: AvailableMetaKey, error: nil)
            
            self.prepared = commonStatus == AVKeyValueStatus.loaded && formataStatus == AVKeyValueStatus.loaded
            
            if self.prepared {
                for item in self.asset.commonMetadata {
                    self.metadata?.addMetadataItem(item: item, with: item.commonKey!)
                }
                
                for format in self.asset.availableMetadataFormats {
                    let items = self.asset.metadata(forFormat: format)
                    for item in items {
                        self.metadata?.addMetadataItem(item: item, with: item.keyString)
                    }
                }
            }
            
            DispatchQueue.main.async {
                completionHandler(self.prepared)
            }
        }
    }
    
    func save(with completionHandler: CompletionHanlder?) {
        let presetName = AVAssetExportPresetPassthrough
        let session = AVAssetExportSession(asset: self.asset, presetName: presetName)
        
        let outputURL = tempURL
        session?.outputURL = outputURL
        session?.outputFileType = self.filetype
        session?.metadata = metadata?.metadataItems()
        
        session?.exportAsynchronously {
            let status = session?.status
            let success = status == AVAssetExportSessionStatus.completed
            if success {
                let sourceURL = self.url
                try! FileManager.default.removeItem(at: sourceURL)
                try! FileManager.default.moveItem(at: outputURL, to: sourceURL)
                self.reset()
            }
            
            if completionHandler != nil {
                DispatchQueue.main.async {
                    completionHandler!(success)
                }
            }
        }
    }
    
    func reset() {
        self.prepared = false
        self.asset = AVAsset(url: self.url)
    }
    
    var tempURL: URL {
        let tempDir = NSTemporaryDirectory()
        let ext = (self.url.lastPathComponent as NSString).pathExtension
        let tempName = "temp.\(ext)"
        let tempPath = (tempDir as NSString).appendingPathComponent(tempName)
        return URL(fileURLWithPath: tempPath)
    }
}
