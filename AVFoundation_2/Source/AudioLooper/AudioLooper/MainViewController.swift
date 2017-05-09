//
//  MainViewController.swift
//  AudioLooper
//
//  Created by NAVER on 2017. 5. 9..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var playButton: THPlayButton!
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var rateKnob: THControlKnob!
    @IBOutlet var panKnobs: [THControlKnob]!
    @IBOutlet var volumeKnobs: [THControlKnob]!
    
    var controller = PlayerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        controller.delegate = self
        
        rateKnob.minimumValue = 0.5
        rateKnob.maximumValue = 1.5
        rateKnob.value = 1.0
        rateKnob.defaultValue = 1.0
        
        panKnobs.forEach {
            $0.minimumValue = -1
            $0.maximumValue = 1.0
            $0.value = 0.0
            $0.defaultValue = 0.0
        }
        
        volumeKnobs.forEach {
            $0.minimumValue = 0.0
            $0.maximumValue = 1.0
            $0.value = 1.0
            $0.defaultValue = 1.0
        }
    }
    
    @IBAction func play(_ sender: Any) {
        if !controller.isPlaying {
            controller.play()
            playLabel.text = "Stop"
        } else {
            controller.stop()
            playLabel.text = "Play"
        }
        playButton.isSelected = !playButton.isSelected
    }
    
    @IBAction func adjustRate(_ sender: THControlKnob) {
        controller.adjustRate(sender.value)
    }
    
    @IBAction func adjustPan(_ sender: THControlKnob) {
        controller.adjustPan(sender.value, index: sender.tag)
    }
    
    @IBAction func adjustVolume(_ sender: THControlKnob) {
        controller.adjustVolume(sender.value, index: sender.tag)
    }
}

extension MainViewController: PlayerControllerDelegate {
    
    func playbackBegan() {
        playButton.isSelected = true
        playLabel.text = "Stop"
    }
    
    func playbackStopped() {
        playButton.isSelected = false
        playLabel.text = "Play"
    }
}
