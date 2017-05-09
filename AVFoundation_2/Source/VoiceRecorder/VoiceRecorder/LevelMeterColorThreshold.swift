//
//  LevelMeterColorThreshold.swift
//  VoiceRecorder
//
//  Created by NAVER on 2017. 5. 9..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import UIKit

class LevelMeterColorThreshold {
    
    var maxValue: CGFloat = 0
    var color: UIColor
    var name: String = ""

    class func colorThreshold(with maxValue: CGFloat, color: UIColor, name: String) -> LevelMeterColorThreshold {
        return LevelMeterColorThreshold(maxValue: maxValue, color: color, name: name)
    }
    
    init(maxValue: CGFloat, color: UIColor, name: String) {
        self.maxValue = maxValue
        self.color = color
        self.name = name
    }
}
