//
//  THPlayerController.swift
//  AVFoundation2
//
//  Created by NAVER on 2017. 5. 9..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import UIKit
import AVFoundation

protocol PlayerControllerDelegate {
    func playbackStopped()
    func playbackBegan()
}

class PlayerController: NSObject {
    
    var isPlaying = false
    var delegate: PlayerControllerDelegate?
    var players: [AVAudioPlayer?] = []
    
    override init() {
        super.init()
        
        let guitarPlayer = player(for: "guitar")
        let bassPlayer = player(for: "bass")
        let drumsPlayer = player(for: "drums")
        
        guitarPlayer?.delegate = self
        
        players = [guitarPlayer, bassPlayer, drumsPlayer]
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(notification:)), name: Notification.Name.AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouterChange(notification:)), name: Notification.Name.AVAudioSessionRouteChange, object: AVAudioSession.sharedInstance())
    }
    
    // 전화 등 예외 상황에 대한 처리
    func handleInterruption(notification: Notification) {
        let info = notification.userInfo
        
        if let type = info?[AVAudioSessionInterruptionTypeKey] as? AVAudioSessionInterruptionType {
            switch type {
            case .began:
                stop()
                delegate?.playbackStopped()
            case .ended:
                if let options = info?[AVAudioSessionInterruptionOptionKey] as? AVAudioSessionInterruptionOptions, options == .shouldResume {
                    play()
                    delegate?.playbackBegan()
                }
            }
        }
    }
    
    // 해드폰 등 오디오 입출력 경로 변경에 따른 처리
    func handleRouterChange(notification: Notification) {
        let info = notification.userInfo
        
        //새로운 장치로 변경거나 오디오 세션 범주가 변경된 이유
        if let reason = info?[AVAudioSessionRouteChangeReasonKey] as? AVAudioSessionRouteChangeReason, reason == .oldDeviceUnavailable {
            
            // 이전 경로를 가져와서 상황에 맞는 처리를 함.
            if let prevRoute = info?[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                let prevOutput = prevRoute.outputs.first
                let portType = prevOutput?.portType
                
                // 이전 경로가 해드폰이었다가 변경이 되었을 경우 오디오를 멈춤.
                if portType == AVAudioSessionPortHeadphones {
                    stop()
                    delegate?.playbackStopped()
                }
            }
        }
    }
    
    func player(for fileName: String) -> AVAudioPlayer? {
        if let fileURL = Bundle.main.url(forResource: fileName, withExtension: "caf"), let player = try? AVAudioPlayer(contentsOf: fileURL) {
            player.numberOfLoops = -1
            player.enableRate = true
            player.prepareToPlay()
            
            return player
        }
        
        return nil
    }
    
    func play() {
        if !isPlaying {
            let delayTime = players.first??.deviceCurrentTime ?? 0 + 0.01
            players.forEach {
                $0?.play(atTime: delayTime)
            }
            isPlaying = true
        }
    }
    
    func stop() {
        if isPlaying {
            players.forEach {
                $0?.stop()
                $0?.currentTime = 0
            }
            isPlaying = false
        }
    }
    
    func adjustRate(_ rate: Float) {
        players.forEach {
            $0?.rate = rate
        }
    }
    
    func adjustPan(_ pan: Float, index: Int) {
        if isValidIndex(index) {
            let player = players[index]
            player?.pan = pan
        }
    }
    
    func adjustVolume(_ volume: Float, index: Int) {
        if isValidIndex(index) {
            let player = players[index]
            player?.volume = volume
        }
    }
    
    func isValidIndex(_ index: Int) -> Bool {
        return index == 0 || index < players.count
    }
}

extension PlayerController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
}
