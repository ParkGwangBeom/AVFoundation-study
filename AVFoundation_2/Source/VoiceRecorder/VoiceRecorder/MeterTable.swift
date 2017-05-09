//
//  MeterTable.swift
//  VoiceRecorder
//
//  Created by NAVER on 2017. 5. 9..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import UIKit

class MeterTable {
    
    var meterTable: [Float] = []
    var scaleFactor: Float = 0
    
    init() {
        let dbResolution: Float = -60.0 / (300 - 1)
        
        scaleFactor = 1.0 / dbResolution;
        let minAmp = dbToAmp(db: -60)
        let ampRange = 1.0 - minAmp
        let invAmpRange = 1.0 / ampRange
        
        for i in 0..<300 {
            let decibels = Float(i) * dbResolution
            let amp = dbToAmp(db: decibels)
            let adjAmp = (amp - minAmp) * invAmpRange
            meterTable.append(adjAmp)
        }
    }
    
    func dbToAmp(db: Float) -> Float {
        return powf(10, 0.05 * db)
    }
    
    func value(for power: Float) -> Float {
        if power < -60 {
            return 0
        } else if power >= 0 {
            return 1
        } else {
            let index = Int(power * scaleFactor)
            return meterTable[index]
        }
    }
}
