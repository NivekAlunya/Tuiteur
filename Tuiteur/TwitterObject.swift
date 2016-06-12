//
//  TwitterObject.swift
//  Tuiteur
//
//  Created by Kevin Launay on 4/2/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

class TwitterObject: NSObject, NSCoding {

    /*private */var json: [String: AnyObject]

    init(json: AnyObject) {
        self.json = json as! [String: AnyObject]
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(json, forKey: "json")
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        if let obj = aDecoder.decodeObjectForKey("json") as? [String : AnyObject] {
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

