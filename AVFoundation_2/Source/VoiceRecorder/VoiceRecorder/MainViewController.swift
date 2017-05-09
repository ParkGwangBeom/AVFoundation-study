//
//  MainViewController.swift
//  VoiceRecorder
//
//  Created by NAVER on 2017. 5. 9..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var levelMeterView: LevelMeterView!
    
    var levelTimer: CADisplayLink?
    var timer: Timer?
    var controller: RecorderController = RecorderController()
    var memos: [Memo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let recordImage = #imageLiteral(resourceName: "record").withRenderingMode(.alwaysOriginal)
        let pauseImage = #imageLiteral(resourceName: "pause").withRenderingMode(.alwaysOriginal)
        let stopImage = #imageLiteral(resourceName: "stop").withRenderingMode(.alwaysOriginal)
        
        recordButton.setImage(recordImage, for: .normal)
        recordButton.setImage(pauseImage, for: .selected)
        stopButton.setImage(stopImage, for: .normal)
        
        do {
            let data = try Data(contentsOf: archiveURL)
            if let unarchiveMemos = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Memo] {
                memos.append(contentsOf: unarchiveMemos)
            }
        } catch {
        }
    }
    
    @IBAction func record(_ sender: UIButton) {
        stopButton.isEnabled = true
        if !sender.isSelected {
            startMeterTimer()
            startTimer()
            _ = controller.record()
        } else {
            stopMeterTimer()
            stopTimer()
            controller.pause()
        }
        
        sender.isSelected = !sender.isSelected
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateTimeDisplay), userInfo: nil, repeats: true)
    }
    
    func updateTimeDisplay() {
        timeLabel.text = controller.formattedCurrentTime
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        stopMeterTimer()
        recordButton.isSelected = false
        stopButton.isEnabled = false
        controller.stop { flag in
            let delayInSeconds = 0.01
            DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) {
                self.showSaveDialog()
            }
        }
    }
    
    func showSaveDialog() {
        let alertController = UIAlertController(title: "Save Recording", message: "Please provide a name", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "My Recording"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            let filename = alertController.textFields?.first?.text ?? ""
            self.controller.saveRecording(with: filename, hanlder: { flag, memo in
                guard flag else {
                    return
                }

                self.memos.append(memo)
                self.saveMemos()
                self.tableView.reloadData()
            })
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func saveMemos() {
        let fileData = NSKeyedArchiver.archivedData(withRootObject: memos)
        try? fileData.write(to: archiveURL)
    }
    
    var archiveURL: URL {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = (paths.first ?? "") as NSString
        let archivePath = docsDir.appendingPathComponent("memos.archive")
        return URL(fileURLWithPath: archivePath)
    }
}

extension MainViewController {
    
    func startMeterTimer() {
        levelTimer?.invalidate()
        levelTimer = CADisplayLink(target: self, selector: #selector(updateMeter))
        levelTimer?.frameInterval = 5
        levelTimer?.add(to: RunLoop.current, forMode: .defaultRunLoopMode)
    }
    
    func stopMeterTimer() {
        levelTimer?.invalidate()
        levelTimer = nil
        levelMeterView.resetLevelMeter()
    }
    
    func updateMeter() {
        let levels = controller.levels
        levelMeterView.level = CGFloat(levels.level)
        levelMeterView.peakLevel = CGFloat(levels.peakLevel)
        levelMeterView.setNeedsDisplay()
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let memo = memos[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MemoCell
        cell.memo = memo
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let memo = memos[indexPath.row]
        _ = controller.playbackMemo(memo: memo)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let memo = memos[indexPath.row]
            _ = memo.deleteMemo()
            memos.remove(at: indexPath.row)
            saveMemos()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
