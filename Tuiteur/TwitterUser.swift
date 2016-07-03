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
        
        return UIColor.Crayon.black.getUIColor()
        
        guard let color =  self["profile_background_color"] as? String else {
            return UIColor(rgbString:"FFFFFF")
        }
        let crayon = UIColor.Crayon.getCrayon(color)
        return crayon.getUIColor()
        //return UIColor(rgbString: color)
    }()

    lazy var profile_text_color: UIColor? = {
        
        var derivedColor = UIColor.Crayon.black
        
        if let profilColor = self.profile_background_color {
            let hsba = profilColor.getHSBA()
            if hsba.brightness < 0.5 {
                derivedColor = UIColor.Crayon.white
            }
        }

        return derivedColor.getUIColor()
    }()

    lazy var profile_sidebar_border_color: UIColor? = {
        
        guard let color = self["profile_sidebar_border_color"] as? String where color != "FFFFFF" else {
            return UIColor(rgbString:"000000")
        }
        
        let crayon = UIColor.Crayon.getCrayon(color)

        return crayon.getUIColor()

    }()

    lazy var profile_sidebar_fill_color: UIColor? = {
        
        guard let color =  self["profile_sidebar_fill_color"] as? String where color != "FFFFFF" else {
            return UIColor(rgbString:"000000")
        }

        let crayon = UIColor.Crayon.getCrayon(color)
        
        return crayon.getUIColor()
    }()
    
    lazy var profile_link_color: UIColor? = {
        
        guard let color =  self["profile_link_color"] as? String where color != "FFFFFF" else {
            return UIColor(rgbString:"000000")
        }

        let crayon = UIColor.Crayon.getCrayon(color)
        
        return crayon.getUIColor()
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