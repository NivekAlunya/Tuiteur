//
//  Float+Angle.swift
//  Tuiteur
//
//  Created by Kevin Launay on 4/6/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation


extension Double {
        var degreesToRadians : CGFloat {
            return CGFloat(self) * CGFloat(M_PI) / 180.0
        }
}

extension Float {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 180.0
    }
}

extension Int {
    var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 180.0
    }
}