//
//  SpeachController.swift
//  AVFoundation1
//
//  Created by NAVER on 2017. 4. 23..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import UIKit
import AVFoundation

class SpeachController: NSObject {
    
    static let speechController = SpeachController()
    
    // 텍스트 음성 변환을 수행
    // 하나 이상의 AVSpeechUtterance 인스턴스 대기열 역할을하며 진행중인 음성의 진행 상태를 제어하고 모니터링 할 수 있는 인터페이스를 제공
    var synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    private var voices: [AVSpeechSynthesisVoice] = []
    private var speechStrings: [String] = []
    
    override init() {
        super.init()
        
        let voice1 = AVSpeechSynthesisVoice(language: "en-US")
        let voice2 = AVSpeechSynthesisVoice(language: "en-GB") // AVSpeechSynthesisVoice에서 speechVoices 클래스 메서드를 호출하면 지원되는 전체 음성 목록을 얻을 수 있다.
        voices.append(voice1!)
        voices.append(voice2!)
        
        speechStrings.append(contentsOf: buildSpeechStrings())
    }
    
    private func buildSpeechStrings() -> [String] {
        return ["Hello AV Foundation. How are you?",
                "I’m well! Thanks for asking.",
                "Are you excited about the book?",
                "Very! I have always felt so misunderstood",
                "What's your favorite feature?"]
    }
    
    func beginConversation() {
        speechStrings.enumerated().forEach {
            let utterance = AVSpeechUtterance(string: $0.element)
            utterance.voice = voices[$0.offset % 2]
            utterance.rate = 0.4 // 말할 속도 지졍 AVSpeechUtteranceMinimumSpeechRate와 AVSpeechUtteranceMaximumSpeechRate 사이 값
            utterance.pitchMultiplier = 0.8 // 발음을위한 pitchMultiplier를 지정. pitchMultiplier의 허용 값은 0.5 ~ 2.0
            utterance.postUtteranceDelay = 1 // AVSpeechSynthesisVoice 간 사이 간격 딜레이
            synthesizer.speak(utterance)
        }
    }
}
