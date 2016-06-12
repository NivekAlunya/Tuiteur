//
//  Device.swift
//  Tuiteur
//
//  Created by Kevin Launay on 5/23/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import UIKit

class Device {
    
    static var scale: Double {
        get {
            return Double(UIScreen.mainScreen().scale)
            //            return UIScreen.mainScreen().respondsToSelector(Selector("scale")) ? Double(UIScreen.mainScreen().scale) : 1.0
        }
    }
    
    static var device: UIDevice = {
        return UIDevice.currentDevice()
    }()
    
    static func isPhone() -> Bool {
        return device.userInterfaceIdiom == .Phone
    }
}