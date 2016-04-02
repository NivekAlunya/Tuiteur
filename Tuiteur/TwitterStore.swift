//
//  TwitterStore.swift
//  Tuiteur
//
//  Created by Kevin Launay on 3/27/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation
import Accounts

class TwitterStore {
    
    enum Events: String{
        case TwitterAccountRetrieved = "ACCOUNT TO TWITTER RETRIEVED"
        case TwitterAccountFriendRetrieved = "FRIENDS FOR TWITTER ACCOUNT RETRIEVED"
        case TwitterAccountTimelineRetrieved = "TIMELINE FOR TWITTER ACCOUNT RETRIEVED"
    }
    
    var twitterAccounts = [String: TwitterAccount]()
    var twitterUsers = [Int: TwitterUser]()
    var twitterTweets = [Int: TwitterTweet]()
    
    static let instance = TwitterStore()

    private let urlStorage: NSURL? = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory , inDomains: .UserDomainMask)

        if let url = urls.first?.URLByAppendingPathComponent("Storage") {
            do {
                try NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
                return url
            } catch {
                //let err = NSError(domain: "", code: 0, userInfo: ["Description": "Can't store data at \(url.path)"])
                //NSNotificationCenter.defaultCenter().postNotificationName(Events.Error.rawValue, object: self, userInfo: ["Error": err])
            }
        }
        return nil
    }()
    
    let readFromCache: Bool = false

    private init() {
        load()
    }
    
    private func load() {
        guard let url = urlStorage?.URLByAppendingPathComponent("twitterAccounts"),  data = NSData(contentsOfURL: url) else {
            return
        }
        let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
        guard let accounts = unarchiver.decodeObject() as? [String: TwitterAccount] else {
            return
        }
        self.twitterAccounts = accounts
    }
    
    private func save() {
        guard let url = urlStorage?.URLByAppendingPathComponent("twitterAccounts") else {
            return
        }
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(self.twitterAccounts)
        archiver.finishEncoding()
        data.writeToURL(url, atomically: true)
    }
    
    
    func getTwitterTimeline(account: TwitterAccount) {
//        return [
//            "count" : "200"
//            , "since_id" : "0"
//            , "max_id" : "0"
//            , "trim_user" : "false"
//            , "exclude_replies": "true"
//            , "contributor_details": "false"
//            , "include_entities" : "false"
//        ]
        let api = TwitterConnection.API.Statuses_HomeTimeline
        guard let sn = account["screen_name"] as? String, acc = TwitterConnection.instance.accounts[sn], var params = api.getParams() else {
            return
        }
        
        params["max_id"] = nil
        params["since_id"] = nil

        TwitterConnection.instance.request(acc, api: api, params: params, cache: readFromCache, completion: { (json, retrievedFromCache) in
            //print(json)
            guard let tweets = json as? [AnyObject] else {
                return
            }
            
            var index = 0
            var idTweets = [Int]()
            
            for tweet in tweets {
                if let tweetObject = tweet as? [String: AnyObject], idtweet = tweet["id"] as? Int {
                    if let tw = self.twitterTweets[idtweet] {
                        tw.update(tweetObject)
                    } else {
                        self.twitterTweets[idtweet] = TwitterTweet(json: tweetObject)
                    }
                    if account.timeline.indexOf(idtweet) == nil {
                        account.timeline.insert(idtweet, atIndex: index)
                        idTweets.append(idtweet)
                    }
                    index += 1
                }
            }
            
            guard account.timeline.count > 0 else {
                return
            }
            NSNotificationCenter.defaultCenter().postNotificationName(Events.TwitterAccountTimelineRetrieved.rawValue, object: self, userInfo: ["key": sn, "idTweets": idTweets])
        })
    }
    
    
    
    func getTwitterFriends(account: TwitterAccount) {
        let api = TwitterConnection.API.Friends_Ids
        guard let sn = account["screen_name"] as? String, acc = TwitterConnection.instance.accounts[sn], var params = api.getParams() else {
            return
        }
        var friends = [Int]()
        params["user_id"] = account["id_str"] as? String ?? ""
        params["screen_name"] = nil

        let apiRetrieveFriends = TwitterConnection.API.Users_Lookup
        var paramsRetrieveFriends = apiRetrieveFriends.getParams()
        paramsRetrieveFriends!["screen_name"] = nil

        //Retrieve friends full object hundred by hundred
        func retrieveFriends() {
            var ids = ""
            let endAt: Int = friends.count > 100 ? 100 : friends.count
            
            for i in 0 ..< endAt {
                ids += "\(friends.removeFirst())" + (i+1 < endAt ? "," : "")
            }
            
            paramsRetrieveFriends!["user_id"] = ids
            
            TwitterConnection.instance.request(acc, api: apiRetrieveFriends, params: paramsRetrieveFriends, cache: readFromCache) { (json, retrievedFromCache) in
//                print(json)
                
                guard let users = json as? [AnyObject] else {
                    return
                }
                
                for user in users {
                    if let userObject = user as? [String: AnyObject], iduser = user["id"] as? Int {
                        if let tu = self.twitterUsers[iduser] {
                            tu.update(userObject)
                        } else {
                            self.twitterUsers[iduser] = TwitterUser(json: userObject)
                        }
                    }
                }
                if friends.count > 0 && !retrievedFromCache {
                    retrieveFriends()
                    return
                }
                NSNotificationCenter.defaultCenter().postNotificationName(Events.TwitterAccountFriendRetrieved.rawValue, object: self, userInfo: ["key": sn])
            }
        }

        func retrieveIds(cursor: Int = -1) {
            
            params["cursor"] = String(cursor)

            TwitterConnection.instance.request(acc, api: api, params: params, cache: readFromCache) { (json, retrievedFromCache) in
                print("+ \(api.rawValue) From cursor \(cursor)----------------------------------")
                if let ids = json["ids"] as? [AnyObject] {
                    for i in ids {
                        if let idfriend = Int((i as? String)!)  {
                            if account.friends.indexOf(idfriend) == nil {
                                account.friends.append(idfriend)
                            }
                        }
                    }
                }
                if let next_cursor = json["next_cursor"] as? Int  {
                    if next_cursor > 0 && !retrievedFromCache {
                        retrieveIds(next_cursor)
                        return
                    }
                }

                friends = account.friends.sort()
                retrieveFriends()
            }
        }
        retrieveIds();
    }
    
    func getTwitterAccounts() {
        
        let api = TwitterConnection.API.Account_VerifyCredentials
        
        let params = api.getParams()
        
        for (k, acc) in TwitterConnection.instance.accounts {
            print(k)
            
            TwitterConnection.instance.request(acc, api: api, params: params, cache: readFromCache, completion: { (json, retrievedFromCache) in
                
                guard let sn = json["screen_name"] as? String else {
                    return
                }
                
                if let ta = self.twitterAccounts[sn] {
                    ta.update(json)
                } else {
                    
                    let ta = TwitterAccount(json: json)
                    self.twitterAccounts[sn] = ta
                }
                self.save()
                NSNotificationCenter.defaultCenter().postNotificationName(Events.TwitterAccountRetrieved.rawValue, object: self, userInfo: ["key": sn])
            })
        }
        
    }

}