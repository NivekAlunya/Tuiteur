//
//  TwitterAccount.swift
//  Tuiteur
//
//  Created by Kevin Launay on 3/27/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

class TwitterAccount: TwitterUser {
    
    var timeline = [Int]()

    override init(json: AnyObject) {
        super.init(json: json)
    }

    @objc override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(friends, forKey: "friends")
        aCoder.encodeObject(tweets, forKey: "tweets")
        aCoder.encodeObject(timeline, forKey: "timeline")
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        if let obj = aDecoder.decodeObjectForKey("friends") as? [Int] {
            self.friends = obj
        } else {
            self.friends = [Int]()
        }
        
        if let obj = aDecoder.decodeObjectForKey("tweets") as? [Int] {
            self.tweets = obj
        } else {
            self.tweets = [Int]()
        }
        
        if let obj = aDecoder.decodeObjectForKey("timeline") as? [Int] {
            self.timeline = obj
        } else {
            self.timeline = [Int]()
        }
    }
}
