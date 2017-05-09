//
//  Memo.swift
//  VoiceRecorder
//
//  Created by NAVER on 2017. 5. 9..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import UIKit

class Memo: NSObject, NSCoding {
    
    var title: String = ""
    var url: URL
    var dateString: String = ""
    var timeString: String = ""
    
    class func memo(title: String, url: URL) -> Memo {
        return Memo(title: title, url: url)
    }
 
    private init(title: String, url: URL) {
        self.title = title
        self.url = url
        
        super.init()
        
        let date = Date()
        self.dateString = dateString(with: date)
        self.timeString = timeString(with: date)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(dateString, forKey: "date")
        aCoder.encode(timeString, forKey: "time")
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        url = aDecoder.decodeObject(forKey: "url") as? URL ?? URL(fileURLWithPath: "")
        dateString = aDecoder.decodeObject(forKey: "date") as? String ?? ""
        timeString = aDecoder.decodeObject(forKey: "time") as? String ?? ""
        super.init()
    }
    
    func dateString(with date: Date) -> String {
        let formatter = formmater(with: "MMddyyyy")
        return formatter.string(from: date)
    }
    
    func timeString(with date: Date) -> String {
        let formatter = formmater(with: "HHmmss")
        return formatter.string(from: date)
    }
    
    func formmater(with template: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let format = DateFormatter.dateFormat(fromTemplate: template, options: 0, locale: Locale.current)
        formatter.dateFormat = format
        return formatter
    }
    
    func deleteMemo() -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            return false
        }
    }
}
