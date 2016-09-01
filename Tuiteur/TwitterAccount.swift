//
//  TwitterAccount.swift
//  Tuiteur
//
//  Created by Kevin Launay on 3/27/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

class TwitterAccount: TwitterUser {
    
//    class TimelineFragment: NSObject, NSCoding {
//        let since_id: Int
//        let max_id: Int
//        let count: Int
//        override var description: String {
//            get {
//                return "(since_id: \(since_id), max_id: \(max_id), count: \(count))"
//            }
//        }
//        init(since_id: Int, max_id: Int, count: Int) {
//            self.since_id = since_id
//            self.max_id = max_id
//            self.count = count
//        }
//        func encodeWithCoder(aCoder: NSCoder) {
//            aCoder.encodeObject(since_id, forKey: "since_id")
//            aCoder.encodeObject(max_id, forKey: "max_id")
//            aCoder.encodeObject(count, forKey: "count")
//        }
//        required init?(coder aDecoder: NSCoder) {
//            self.since_id = aDecoder.decodeObjectForKey("since_id") as? Int ?? 0
//            self.max_id = aDecoder.decodeObjectForKey("max_id") as? Int ?? 0
//            self.count = aDecoder.decodeObjectForKey("count") as? Int ?? 0
//        }
//    }
    
    var timeline = [Int]()

    var timelineFragments = [Int]()
    var since_id = 0
    override init(json: AnyObject) {
        super.init(json: json)
    }

    @objc override func encodeWithCoder(aCoder: NSCoder) {
        super.encodeWithCoder(aCoder)
        aCoder.encodeObject(friends, forKey: "friends")
        aCoder.encodeObject(tweets, forKey: "tweets")
        aCoder.encodeObject(timeline, forKey: "timeline")

        aCoder.encodeObject([timelineFragments, since_id], forKey: "refreshingValues")
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

        if let obj = aDecoder.decodeObjectForKey("refreshingValues") as? [AnyObject] {
            self.timelineFragments = obj[0] as! [Int]
            self.since_id = obj[1] as! Int
        } else {
            self.timelineFragments = [Int]()
            self.since_id = 0
        }
    }
}
