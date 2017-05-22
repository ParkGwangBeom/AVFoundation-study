//
//  ViewController.swift
//  MetaManager
//
//  Created by NAVER on 2017. 5. 22..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var spinnerView: NSProgressIndicator!
    
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var artistField: NSTextField!
    @IBOutlet weak var albumArtistField: NSTextField!
    @IBOutlet weak var albumField: NSTextField!
    @IBOutlet weak var groupingField: NSTextField!
    @IBOutlet weak var composerField: NSTextField!
    @IBOutlet weak var commentsField: NSTextField!
    @IBOutlet weak var genreCombo: NSComboBox!
    @IBOutlet weak var yearField: NSTextField!
    @IBOutlet weak var trackNumberField: NSTextField!
    @IBOutlet weak var trackCountField: NSTextField!
    @IBOutlet weak var discNumberField: NSTextField!
    @IBOutlet weak var discCountField: NSTextField!
    @IBOutlet weak var bpmField: NSTextField!
    @IBOutlet weak var imageWell: NSImageView!
    @IBOutlet weak var saveButton: NSButton!
    
    @IBOutlet weak var mediaItemsController: NSArrayController!
    
    var mediaItem: MediaItem?
    var mediaItems: [MediaItem] = []
    var exportSession: AVAssetExportSession?
    var musicGenres = THGenre.musicGenres()
    var videoGenres = THGenre.videoGenres()
    var exportController: NSWindowController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTable()
        configureTextFields()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func reloadData() {
        genreCombo.objectValue = nil
        mediaItems.forEach {
            self.mediaItemsController.removeObject($0)
        }
        loadTable()
    }
    
    func loadTable() {
        let rootURL = URL(fileURLWithPath: FileManager.default.applicationSupportDirectory())
        let items = try! FileManager.default.contentsOfDirectory(at: rootURL, includingPropertiesForKeys: [.nameKey, .effectiveIconKey], options: .skipsHiddenFiles)
        items.forEach {
//            self.mediaItems.append(MediaItem(url: $0))
            self.mediaItemsController.addObject(MediaItem(url: $0))
        }
        tableView.reloadData()
    }
    
    func configureTextFields() {
        let formatter = THNumberFormatter()
        yearField.formatter = formatter
        bpmField.formatter = formatter
        trackNumberField.formatter = formatter
        trackCountField.formatter = formatter
        discNumberField.formatter = formatter
        discCountField.formatter = formatter
    }
    
    func updateFieldState() {
        var enabled = true
        if mediaItem?.filetype == AVFileTypeAppleM4V || mediaItem?.filetype == AVFileTypeQuickTimeMovie {
            enabled = false
        }
        
        trackCountField.isEnabled = enabled
        trackNumberField.isEnabled = enabled
        discNumberField.isEnabled = enabled
        discCountField.isEnabled = enabled
        bpmField.isEnabled = enabled
    }
    
    var activeGenres: [THGenre] {
        var active: [THGenre] = []
        if mediaItem != nil {
            if mediaItem?.filetype == AVFileTypeAppleM4V || mediaItem?.filetype == AVFileTypeQuickTimeMovie {
                active = videoGenres!
            } else {
                active = musicGenres!
            }
        }
        return active
    }
    
    @IBAction func save(_ sender: Any) {
        mediaItem?.save(with: { success in
            let selected = self.tableView.selectedRow
            self.tableView.deselectRow(selected)
            //            self.tableView.selectRowIndexes([IndexSet(integer: Integer(selected))], byExtendingSelection: false)
        })
    }
}

extension ViewController: NSTableViewDelegate {
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let view = notification.object as! NSTableView
        if view.selectedRow != -1 {
            mediaItem = mediaItems[view.selectedRow]
            saveButton.isEnabled = mediaItem?.isEditable ?? false
            mediaItem?.prepare(with: { complete in
                self.mediaItemsController.setSelectionIndex(view.selectedRow)
                self.genreCombo.objectValue = self.mediaItem?.metadata?.genre
            })
        } else {
            mediaItem = nil
            genreCombo.objectValue = nil
            mediaItemsController.setSelectedObjects([])
        }
        genreCombo.reloadData()
        updateFieldState()
    }
}

extension ViewController: NSComboBoxDataSource {
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return activeGenres.count
    }
    
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        let genre = activeGenres[index]
        return genre.name
    }
    
    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        let genre = activeGenres.filter {
            $0.name == string
            }.first
        
        if genre != nil {
            return Int(genre!.index)
        }
        
        return activeGenres.count
    }
    
    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        for genre in activeGenres {
            if genre.name.lowercased().hasPrefix(string.lowercased()) {
                mediaItem?.metadata?.genre = genre
                return genre.name
            }
        }
        
        mediaItem?.metadata?.genre = nil
        return nil
    }
}

extension ViewController: NSComboBoxDelegate {
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        let genre = activeGenres[genreCombo.indexOfSelectedItem]
        mediaItem?.metadata?.genre = genre
    }
}
