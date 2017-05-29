//
//  Metadata.swift
//  MetaManager
//
//  Created by NAVER on 2017. 5. 22..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import Cocoa
import AVFoundation

class Metadata: NSObject {
    var name: NSString = ""
    var artist: String?
    var albumArtist: String?
    var album: String?
    var grouping: String?
    var composer: String?
    var comments: String?
    var artwork: NSImage?
    var genre: THGenre?
    
    var year: String?
    var bpm: NSNumber?
    var trackNumber: NSNumber?
    var trackCount: NSNumber?
    var discNumber: NSNumber?
    var discCount: NSNumber?

    var converterFactory: THMetadataConverterFactory = THMetadataConverterFactory()
    var metadata: [String: AVMetadataItem] = [:]
    var keyMapping: [String: String] {
        return [AVMetadataCommonKeyTitle: THMetadataKeyName,
                AVMetadataCommonKeyArtist: THMetadataKeyArtist,
                AVMetadataQuickTimeMetadataKeyProducer: THMetadataKeyArtist,
                
                // Album Artist Mapping
            AVMetadataID3MetadataKeyBand : THMetadataKeyAlbumArtist,
            AVMetadataiTunesMetadataKeyAlbumArtist : THMetadataKeyAlbumArtist,
            "TP2" : THMetadataKeyAlbumArtist,
            
            // Album Mapping
            AVMetadataCommonKeyAlbumName : THMetadataKeyAlbum,
            
            // Artwork Mapping
            AVMetadataCommonKeyArtwork : THMetadataKeyArtwork,
            
            // Year Mapping
            AVMetadataCommonKeyCreationDate : THMetadataKeyYear,
            AVMetadataID3MetadataKeyYear : THMetadataKeyYear,
            "TYE" : THMetadataKeyYear,
            AVMetadataQuickTimeMetadataKeyYear : THMetadataKeyYear,
            AVMetadataID3MetadataKeyRecordingTime : THMetadataKeyYear,
            
            // BPM Mapping
            AVMetadataiTunesMetadataKeyBeatsPerMin : THMetadataKeyBPM,
            AVMetadataID3MetadataKeyBeatsPerMinute : THMetadataKeyBPM,
            "TBP" : THMetadataKeyBPM,
            
            // Grouping Mapping
            AVMetadataiTunesMetadataKeyGrouping : THMetadataKeyGrouping,
            "@grp" : THMetadataKeyGrouping,
            AVMetadataCommonKeySubject : THMetadataKeyGrouping,
            
            // Track Number Mapping
            AVMetadataiTunesMetadataKeyTrackNumber : THMetadataKeyTrackNumber,
            AVMetadataID3MetadataKeyTrackNumber : THMetadataKeyTrackNumber,
            "TRK" : THMetadataKeyTrackNumber,
            
            // Composer Mapping
            AVMetadataQuickTimeMetadataKeyDirector : THMetadataKeyComposer,
            AVMetadataiTunesMetadataKeyComposer : THMetadataKeyComposer,
            AVMetadataCommonKeyCreator : THMetadataKeyComposer,
            
            // Disc Number Mapping
            AVMetadataiTunesMetadataKeyDiscNumber : THMetadataKeyDiscNumber,
            AVMetadataID3MetadataKeyPartOfASet : THMetadataKeyDiscNumber,
            "TPA" : THMetadataKeyDiscNumber,
            
            // Comments Mapping
            "ldes" : THMetadataKeyComments,
            AVMetadataCommonKeyDescription : THMetadataKeyComments,
            AVMetadataiTunesMetadataKeyUserComment : THMetadataKeyComments,
            AVMetadataID3MetadataKeyComments : THMetadataKeyComments,
            "COM" : THMetadataKeyComments,
            
            // Genre Mapping
            AVMetadataQuickTimeMetadataKeyGenre : THMetadataKeyGenre,
            AVMetadataiTunesMetadataKeyUserGenre : THMetadataKeyGenre,
            AVMetadataCommonKeyType : THMetadataKeyGenre
        ]
    }
    
    override init() {
        super.init()
    }
    
    func addMetadataItem(item: AVMetadataItem, with key: String) {
        // key값을 맵핑해 두어 해당 프로퍼티에 접근하여 값을 셋팅해준다.
        let normalizedKey = keyMapping[key] ?? ""
        if !normalizedKey.isEmpty {
            let converter = converterFactory.converter(forKey: normalizedKey)
            
            let value = converter?.displayValue(from: item)
            
            if let data = value as? [String:Any] {
                data.keys.forEach {
                    self.setValue(data[$0], forKeyPath:$0)
                }
            } else {
                self.setValue(value, forKeyPath: normalizedKey)
            }

            print(self.name)
        }
    }
    
    func metadataItems() -> [AVMetadataItem] {
        var items: [AVMetadataItem] = []
        
        addMetadataItem(for: self.trackNumber, count: self.trackCount, numberKey: THMetadataKeyTrackNumber, countKey: THMetadataKeyTrackCount, to: &items)
        
        addMetadataItem(for: self.discNumber, count: self.discCount, numberKey: THMetadataKeyDiscNumber, countKey: THMetadataKeyDiscCount, to: &items)
        
        var metaDict = metadata
        metaDict.removeValue(forKey: THMetadataKeyTrackNumber)
        metaDict.removeValue(forKey: THMetadataKeyDiscNumber)
        
        metaDict.keys.forEach {
            let converter = converterFactory.converter(forKey: $0)
            let value = self.value(forKey: $0)
            let item = converter?.metadataItem(fromDisplayValue: value, with: metaDict[$0])
            if let tmp = item {
                items.append(tmp)
            }
        }
        
        return items
    }
    
    func addMetadataItem(for number: NSNumber?, count: NSNumber?, numberKey: String, countKey: String, to items: inout [AVMetadataItem]) {
        let converter = converterFactory.converter(forKey: numberKey)
        var data: [String: Any?] = [:]
        if number != nil {
            data[numberKey] = number!
        }
        
        if count != nil {
            data[countKey] = count!
        }
        
        let sourceItem = metadata[numberKey]
        let item = converter?.metadataItem(fromDisplayValue: data, with: sourceItem)
        if let tmp = item {
            items.append(tmp)
        }
    }
}
