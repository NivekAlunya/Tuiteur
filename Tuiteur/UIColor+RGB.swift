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
        let rgb = UIColor.getRGB(rgbString)
        self.init(
            red: CGFloat(rgb.red) / 255.0,
            green: CGFloat(rgb.green) / 255.0,
            blue: CGFloat(rgb.blue) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func getRGB(rgbString: String) -> (red: Int, green: Int, blue: Int) {
        var rgbValue: UInt32 = 0
        NSScanner(string: rgbString).scanHexInt(&rgbValue)
        return (Int((rgbValue & 0xFF0000) >> 16), Int((rgbValue & 0x00FF00) >> 8), Int(rgbValue & 0x0000FF))
    }

    static func getHexValue(color: UIColor) -> String {
        var red = CGFloat(0)
        var green = CGFloat(0)
        var blue = CGFloat(0)
        var alpha = CGFloat(0)
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return String(format:"%2X", Int(round(red * 255)) << 16 + Int(round(green * 255)) << 8 + Int(round(blue * 255)))
        
    }

    
    func getHSBA() -> (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat)  {
        var hue = CGFloat(0)
        var brightness = CGFloat(0)
        var saturation = CGFloat(0)
        var alpha = CGFloat(0)
        
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return (hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    func darker(brightnessValue: CGFloat) -> UIColor{
        let hsba = getHSBA()
        
        let newBrightness = max(hsba.brightness - brightnessValue, 0.0)
        
        return UIColor(hue: max(hsba.hue - 0.1, 0), saturation: max(hsba.saturation - 0.1, 0), brightness: newBrightness, alpha: hsba.alpha)
    }
    
    func brighter(brightnessValue: CGFloat) -> UIColor {
        let hsba = getHSBA()
        
        let newBrightness = min(hsba.brightness + brightnessValue, 1.0)
        
        return UIColor(hue: min(hsba.hue + 0.1, 1.0), saturation: min(hsba.saturation + 0.1, 1.0), brightness: newBrightness, alpha: hsba.alpha)
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

        let deltaRed = red - red2
        let deltaGreen = green - green2
        let deltaBlue = blue - blue2
        
        let isBarelyRed = fabs(deltaRed) < tolerance
        let isBarelyGreen = fabs(deltaGreen) < tolerance
        let isBarelyBlue = fabs(deltaBlue) < tolerance
        
        if !isBarelyRed && !isBarelyGreen && !isBarelyBlue {
            return (false, self)
        }
        
        let maxval = max(deltaRed, deltaGreen, deltaGreen)
        let minval = min(deltaRed, deltaGreen, deltaGreen)
        
        var newRed = CGFloat(0)
        var newGreen = CGFloat(0)
        var newBlue = CGFloat(0)
        
        if abs(minval) < abs(maxval) {
            let val2minus =  minval > 0 ? (tolerance - minval) : (tolerance + minval) * -1
            newRed = max(0, red - val2minus)
            newGreen = max(0, green - val2minus)
            newBlue = max(0, blue - val2minus)
            //all colors are below 0.0 when negative tolerance is added
            //            if newRed + newBlue + newGreen == 0.0 {
            //                newRed = min(0, red + val2minus)
            //                newGreen = min(0, green + val2minus)
            //                newBlue = min(0, blue + val2minus)
            //            }
            
        } else {
            let val2add = maxval > 0 ? tolerance - maxval : (tolerance + maxval) * -1
            newRed = min(1.0, red + val2add)
            newGreen = min(1.0, green + val2add)
            newBlue = min(1.0, blue + val2add)
            //all colors are beyond 1.0 when tolerance is added
            //            if newRed + newBlue + newGreen == 3.0 {
            //                newRed = max(0.0, red - val2add)
            //                newGreen = max(0.0, green - val2add)
            //                newBlue = max(0.0, blue - val2add)
            //            }
            
        }
        
        return (true, UIColor(red: newRed, green: newGreen, blue: newBlue, alpha: alpha))
    }
}
