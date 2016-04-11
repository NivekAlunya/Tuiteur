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