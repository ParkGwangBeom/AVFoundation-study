//
//  LevelMeterView.swift
//  VoiceRecorder
//
//  Created by NAVER on 2017. 5. 9..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import UIKit

class LevelMeterView: UIView {

    var level: CGFloat = 0
    var peakLevel: CGFloat = 0
    var ledCount: Int = 20
    var ledBackgroundColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.35)
    var ledBorderColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    var colorThresholds: [LevelMeterColorThreshold] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    func setupView() {
        let greenColor = UIColor(colorLiteralRed: 0.458, green: 1.000, blue: 0.396, alpha: 1)
        let yellowColor = UIColor(colorLiteralRed: 1, green: 0.930, blue: 0.315, alpha: 1)
        let redColor = UIColor(colorLiteralRed: 1, green: 0.325, blue: 0.329, alpha: 1)
        
        colorThresholds = [LevelMeterColorThreshold.colorThreshold(with: 0.5, color: greenColor, name: "green"),
                           LevelMeterColorThreshold.colorThreshold(with: 0.8, color: yellowColor, name: "yellow"),
                           LevelMeterColorThreshold.colorThreshold(with: 1, color: redColor, name: "red")]
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        context?.translateBy(x: 0, y: bounds.height)
        context?.rotate(by: .pi / 2)
        
        var lightMinValue: CGFloat = 0.0
        var peakLED = -1
        
        if peakLevel > 0 {
            peakLED = Int(peakLevel) * ledCount
            if peakLED >= ledCount {
                peakLED = ledCount - 1
            }
        }
        
        for ledIndex in 0..<ledCount {
            var ledColor = colorThresholds[0].color
            let ledMaxValue: CGFloat =  CGFloat((ledIndex + 1) / ledCount)

            for colorIndex in 0..<(colorThresholds.count - 1) {
                let currThreshold = colorThresholds[colorIndex]
                let nextThreshold = colorThresholds[colorIndex + 1]
                if currThreshold.maxValue <= ledMaxValue {
                    ledColor = nextThreshold.color;
                }
            }
            
            let height = bounds.height
            let width = bounds.width
            
            let ledRect = CGRect(x: 0, y: height * (CGFloat(ledIndex / ledCount)), width: width, height: height * (CGFloat(1 / ledCount)))
            
            context?.setFillColor(ledBackgroundColor.cgColor)
            context?.fill(ledRect)
            
            var lightIntensity: CGFloat = 0
            if ledIndex == peakLED {
                lightIntensity = 1.0
            } else {
                lightIntensity = clamp(intensity: (level - lightMinValue) / (ledMaxValue - lightMinValue))
            }
            
            var fillColor = UIColor.white
            if lightIntensity == 1 {
                fillColor = ledColor
            } else {
                let color = ledColor.cgColor.copy(alpha: lightIntensity)
                fillColor = UIColor(cgColor: color!)
            }
            
            context?.setFillColor(fillColor.cgColor)
            let fillPath = UIBezierPath(roundedRect: ledRect, cornerRadius: 2)
            context?.addPath(fillPath.cgPath)
            
            context?.setStrokeColor(ledBorderColor.cgColor)
            let strokePath = UIBezierPath(roundedRect: ledRect.insetBy(dx: 0.5, dy: 0.5), cornerRadius: 2)
            context?.addPath(strokePath.cgPath)
            
            context?.drawPath(using: .fillStroke)
            
            lightMinValue = ledMaxValue
        }
    }
    
    func clamp(intensity: CGFloat) -> CGFloat {
        if intensity < 0.0 {
            return 0.0
        } else if intensity >= 1.0 {
            return 1.0
        } else {
            return intensity
        }
    }
    
    func resetLevelMeter() {
        level = 0.0
        peakLevel = 0.0
        setNeedsDisplay()
    }
}
