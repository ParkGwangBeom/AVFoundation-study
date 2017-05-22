//
//  AppDelegate.swift
//  MetaManager
//
//  Created by NAVER on 2017. 5. 22..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        copyMediaItems()
    }

    func copyMediaItems() {
        let appSupport = FileManager.default.applicationSupportDirectory()
        let rootURL = URL(fileURLWithPath: appSupport!)
        let contents = try! FileManager.default.contentsOfDirectory(at: rootURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        
        if contents.isEmpty {
            let items = Bundle.main.paths(forResourcesOfType: nil, inDirectory: "Media")
            items.enumerated().forEach { index, path in
                let ns = appSupport! as NSString
                let filePath = ns.appendingPathComponent((path as NSString).lastPathComponent)
//                try! FileManager.default.removeItem(atPath: filePath)
                _ = try! FileManager.default.copyItem(atPath: path, toPath: filePath)
            }
        }
    }
}

