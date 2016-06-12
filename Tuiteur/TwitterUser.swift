//
//  TwitterUser.swift
//  Tuiteur
//
//  Created by Kevin Launay on 3/29/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

class TwitterUser: TwitterObject {
    
    var friends = [Int]()
    
    var tweets = [Int]()
    
    lazy var urlImageProfil: String? = {
        
        guard let profil =  self["profile_image_url"] as? String else {
            return nil
        }
        
        return profil.stringByReplacingOccurrencesOfString("_normal", withString:"")
    }()
    
    lazy var profile_background_color: UIColor? = {
        
        guard let color =  self["profile_background_color"] as? String else {
            return UIColor(rgbString:"FFFFFF")
        }
        
        return UIColor(rgbString: color)
    }()

    lazy var profile_text_color: UIColor? = {
        
        guard let color =  self["profile_text_color"] as? String
        , let colorText = UIColor(rgbString: color) else {
            return UIColor(rgbString:"000000")
        }
        if let profilColor = self.profile_background_color {
            
            let (barely, suggestedColor) = colorText.approach(self.profile_background_color!, withTolerance: 0.25)
            
            return barely ? suggestedColor : colorText
            
        } else {
            return colorText
        }
    }()

    lazy var profile_sidebar_border_color: UIColor? = {
        
        guard let color =  self["profile_sidebar_border_color"] as? String where color != "FFFFFF" else {
            return UIColor(rgbString:"000000")
        }        
        return UIColor(rgbString: color)
    }()

    override init(json: AnyObject) {
        super.init(json: json)
    }

    @objc override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}