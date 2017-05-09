//
//  LevelPair.swift
//  VoiceRecorder
//
//  Created by NAVER on 2017. 5. 9..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import UIKit

class LevelPair {
    
    var level: Float = 0
    var peakLevel: Float = 0
    
    class func levels(with level: Float, peakLevel: Float) -> LevelPair {
        return LevelPair(level: level, peakLevel: peakLevel)
    }
    
    init(level: Float, peakLevel: Float) {
        self.level = level
        self.peakLevel = peakLevel
    }
}

/*
 + (instancetype)levelsWithLevel:(float)level peakLevel:(float)peakLevel {
 return [[self alloc] initWithLevel:level peakLevel:peakLevel];
 }
 
 - (instancetype)initWithLevel:(float)level peakLevel:(float)peakLevel {
 self = [super init];
 if (self) {
 _level = level;
 _peakLevel = peakLevel;
 }
 return self;
 }
 */
