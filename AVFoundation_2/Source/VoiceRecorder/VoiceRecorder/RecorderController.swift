//
//  RecorderController.swift
//  VoiceRecorder
//
//  Created by NAVER on 2017. 5. 9..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import UIKit
import AVFoundation

typealias RecordingStopCompletionHandler = (Bool) -> Void
typealias RecordingSaveCOmpletionHanlder = (Bool, Memo) -> Void

class RecorderController: NSObject {
    
    var recorder: AVAudioRecorder?
    var player: AVAudioPlayer?
    var meterTable: MeterTable?
    var completionHanlder: RecordingStopCompletionHandler?
    
    override init() {
        super.init()
        
        let tmpDir = NSTemporaryDirectory() as NSString
        let filePath = tmpDir.appendingPathComponent("memo.caf")
        let fileURL = URL(fileURLWithPath: filePath)
        
        let settings: [String: Any] = [AVFormatIDKey: kAudioFormatAppleIMA4,
                                       AVSampleRateKey: 44100.0,
                                       AVNumberOfChannelsKey: 1,
                                       AVEncoderBitDepthHintKey: 16,
                                       AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue]
        
        recorder = try? AVAudioRecorder(url: fileURL, settings: settings)
        recorder?.delegate = self
        recorder?.prepareToRecord()
        
        meterTable = MeterTable()
    }
    
    func record() -> Bool {
        return recorder?.record() ?? false
    }
    
    func pause() {
        recorder?.pause()
    }
    
    func stop(_ hanlder: @escaping RecordingStopCompletionHandler) {
        self.completionHanlder = hanlder
        recorder?.stop()
    }
    
    var documentsDirectory: NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        return (paths.first ?? "") as NSString
    }
    
    var levels: LevelPair {
        recorder?.updateMeters()
        let avgPower = recorder?.averagePower(forChannel: 0)
        let peakPower = recorder?.peakPower(forChannel: 0)
        let linearLevel = meterTable?.value(for: avgPower ?? 0)
        let linearPeak = meterTable?.value(for: peakPower ?? 0)
        return LevelPair.levels(with: linearLevel ?? 0, peakLevel: linearPeak ?? 0)
    }
    
    func saveRecording(with name: String, hanlder: RecordingSaveCOmpletionHanlder) {
        let timestamp = Date.timeIntervalSinceReferenceDate
        let filename = "\(name)-\(timestamp).caf"
        
        let docsDir = documentsDirectory
        let destPath = docsDir.appendingPathComponent(filename)
        
        guard let srcURL = recorder?.url else {
            return
        }
        
        let destURL = URL(fileURLWithPath: destPath)
        do {
            try FileManager.default.copyItem(at: srcURL, to: destURL)
            hanlder(true, Memo.memo(title: name, url: destURL))
        } catch {
//            hanlder(false, "")
        }
    }
    
    func playbackMemo(memo: Memo) -> Bool {
        player?.stop()
        player = try? AVAudioPlayer(contentsOf: memo.url)
        player?.play()
        return player != nil
    }
    
    var formattedCurrentTime: String {
        let time = Int(recorder?.currentTime ?? 0)
        
        let hours = time / 3600
        let minutes = (time / 60) % 60
        let seconds = time % 60
        
        let format = "%02i:%02i:%02i"
        return String(format: format, hours, minutes, seconds)
    }
}

extension RecorderController: AVAudioRecorderDelegate {
    
    // stop 메소드가 호출되고 난 후 녹음이 끝나고 불림.
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.completionHanlder?(flag)
    }
}
