//
//  TwitterAccount.swift
//  Tuiteur
//
//  Created by Kevin Launay on 3/27/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

class TwitterAccount: NSObject, NSCoding {
    
    private var json: [String: AnyObject]
    
    var friends = [Int]()

    var timeline = [Int]()

    var tweets = [Int]()

    init(json: AnyObject) {
        self.json = json as! [String: AnyObject]
    }

    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(json)
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        if let obj = aDecoder.decodeObject() as? [String : AnyObject] {
            self.json = obj
        } else {
            self.json = [String: AnyObject]()
        }
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
