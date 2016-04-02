//
//  TwitterTweet.swift
//  Tuiteur
//
//  Created by Kevin Launay on 3/31/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

class TwitterTweet {
    
    private var json: [String: AnyObject]
    
    init(json: AnyObject) {
        self.json = json as! [String: AnyObject]
    }
    
    func update(json: AnyObject) {
        self.json = json as! [String: AnyObject]
    }
    
    subscript(s: String) -> AnyObject? {
        get {
            return json[s]
        }
        set(newValue) {
            json[s] = newValue
        }
    }
}