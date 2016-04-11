//
//  TwitterTweet.swift
//  Tuiteur
//
//  Created by Kevin Launay on 3/31/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

class TwitterTweet: TwitterObject {
    
    override init(json: AnyObject) {
        super.init(json: json)
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}