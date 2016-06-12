//
//  UIColor+RGB.swift
//  Tuiteur
//
//  Created by Kevin Launay on 5/21/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

extension UIColor {
    convenience init?(rgbString: String) {
        var rgbValue: UInt32 = 0
        NSScanner(string: rgbString).scanHexInt(&rgbValue)
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func approach(color: UIColor, withTolerance tolerance: CGFloat) -> (barely: Bool, suggestColor: UIColor) {
        
        var red = CGFloat(0)
        var green = CGFloat(0)
        var blue = CGFloat(0)
        var alpha = CGFloat(0)
        var red2 = CGFloat(0)
        var green2 = CGFloat(0)
        var blue2 = CGFloat(0)
        var alpha2 = CGFloat(0)
        
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        var deltaRed = red - red2
        var deltaGreen = green - green2
        var deltaBlue = blue - blue2
        var deltaAlpha = alpha - alpha

        var isBarelyRed = fabs(deltaRed) < tolerance
        var isBarelyGreen = fabs(deltaGreen) < tolerance
        var isBarelyBlue = fabs(deltaBlue) < tolerance
        var isBarelyAlpha = fabs(deltaAlpha) < tolerance
        
        let isBarelyEqual = isBarelyRed
            && isBarelyGreen
            && isBarelyBlue
            && isBarelyAlpha
        
        func computeNewValue(val: CGFloat, val2: CGFloat, tolerance: CGFloat) -> CGFloat {
            let delta = val - val2
            var result: CGFloat
            if delta > 0 {
                result = val2 - tolerance
                if result < 0 {
                    result = val2 + tolerance
                }
            } else {
                result = val2 + tolerance
                if result > 1 {
                    result = val2 - tolerance
                }
            }
            
            return result
        }
        
        let newRed = !isBarelyRed ? red : computeNewValue(red, val2: red2, tolerance: tolerance)
        let newGreen = !isBarelyGreen ? green : computeNewValue(green, val2: green2, tolerance: tolerance)
        let newBlue = !isBarelyRed ? blue : computeNewValue(blue, val2: blue2, tolerance: tolerance)
        let newAlpha = CGFloat(1.0) // !isBarelyRed ? alpha : computeNewValue(alpha, val2: alpha2, tolerance: tolerance)

        return (isBarelyEqual, UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: newAlpha))
    }
}
