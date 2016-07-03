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
    
    enum Cursor {
        case Start
        case Next
        case Previous
    }
    
    var twitterAccounts = [String: TwitterAccount]()
    var twitterUsers = [Int: TwitterUser]()
    var twitterTweets = [Int: TwitterTweet]()

    var twitterUsersByImageProfil = [String: Int]()

    var IdsForNextTweets = [Int]()
    var selectedAccount: TwitterAccount? {
        get {
            guard let selected = TwitterConnection.instance.selectedAccount
                , ta = TwitterStore.instance.twitterAccounts[selected] else {
                    return nil
            }
            return ta
        }
    }
    
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
    
    private let storageList = [Storage.TwitterAccounts, Storage.TwitterUsers, Storage.TwitterTweets]
    
    let readFromCache: Bool = false

    private init() {
        load()
    }
    
    enum Storage : String {
        case TwitterAccounts    = "TwitterAccounts"
        case TwitterUsers       = "TwitterUsers"
        case TwitterTweets      = "TwitterTweets"
    }
    
    private func load() {
        print("LOADING STORE...")
        let storages = [Storage.TwitterAccounts, Storage.TwitterUsers, Storage.TwitterTweets]
        for st in storages {
            guard let url = urlStorage?.URLByAppendingPathComponent(st.rawValue),  data = NSData(contentsOfURL: url) else {
                continue
            }
            let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
            switch st {
            case .TwitterAccounts:
                guard let data = unarchiver.decodeObject() as? [String: TwitterAccount] else {
                    return
                }
                self.twitterAccounts = data
            case .TwitterUsers:
                guard let data = unarchiver.decodeObject() as? [Int: TwitterUser] else {
                    return
                }
                self.twitterUsers = data
                for (k, user) in self.twitterUsers {
//                    let bk = user["profile_background_color"]!
//                    let txt = user["profile_text_color"]!
//                    let sn = user["screen_name"]!
//                    print("\(sn) : \(bk) : \(txt)")
                    if let key = user.urlImageProfil?.md5() {
                        self.twitterUsersByImageProfil[key] = k
                    }
                }
                
            case .TwitterTweets:
                guard let data = unarchiver.decodeObject() as? [Int: TwitterTweet] else {
                    return
                }
                self.twitterTweets = data
                var maxMedias = 0
                for (_, tweet) in self.twitterTweets {
                    if let entities = tweet["entities"] as? [String: AnyObject] {

                        if let medias = entities["media"] as? [[String: AnyObject]] {
                            for media in medias {
                                if let sizes = media["sizes"] as? [String: AnyObject]
                                    , size = sizes["small"] as? [String: AnyObject]
                                    , h = size["h"] as? Int, w = size["w"] as? Int {
                                    print(h >= w ? "Portrait" : "Landscape")
                                }
                            }
                            maxMedias = medias.count > maxMedias ? medias.count : maxMedias
                        }
                    }
                }
                print("Max images found in a tweet = \(maxMedias)")
            }
        }
    }
    
    func getTweetsWithURL(account: TwitterAccount) -> [Int] {
        return account.timeline.filter { (key) -> Bool in
            guard let tweet = self.twitterTweets[key]
                , entities = tweet["entities"]
                , urls = entities["urls"] as? [AnyObject] else {
                return false
            }
            
            return urls.count > 0
        }
    }
    
    private func save(storage: Storage? = nil) {
        func _save(st: Storage) {
            guard let url = urlStorage?.URLByAppendingPathComponent(st.rawValue) else {
                return
            }
            let data = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
            switch st {
            case .TwitterAccounts:
                archiver.encodeObject(self.twitterAccounts)
            case .TwitterUsers:
                archiver.encodeObject(self.twitterUsers)
            case .TwitterTweets:
                archiver.encodeObject(self.twitterTweets)
                
            }
            archiver.finishEncoding()
            data.writeToURL(url, atomically: true)
        }
        
        if let st = storage {
            _save(st)
        } else {

            for st in storageList {
                _save(st)
            }
        }
    }
    
    func clearStorage(storage: Storage? = nil) {
        print("CLEAR STORE.....")
        func _clear(st: Storage) {
            guard let url = urlStorage?.URLByAppendingPathComponent(st.rawValue) else {
                return
            }
            do {
                try NSFileManager.defaultManager().removeItemAtURL(url)
            } catch {
                print(error)
            }
        }
        if let st = storage {
            _clear(st)
        } else {
            for st in storageList {
                _clear(st)
            }
        }
    }
    
    
    func getTwitterTimeline(account: TwitterAccount, cursor: Cursor = .Start, atFragment: Int = 0) {
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
        
        guard let sn = account["screen_name"] as? String
            , acc = TwitterConnection.instance.accounts[sn]
            , var params = api.getParams() else {
            return
        }
        
        params["count"] = "200"
        params["max_id"] = nil
        params["since_id"] = nil
        
        if account.timelineFragments.count > 0 {
            if cursor == .Start {

            } else {
                let fragment = account.timelineFragments[atFragment]
                params["since_id"] = cursor == .Next ? String(fragment.since_id) : nil
                params["max_id"] = cursor == .Previous ? String(fragment.max_id - 1) : nil
            }
        } else {
            
        }
        
        TwitterConnection.instance.request(acc, api: api, params: params, cache: readFromCache, completion: { (json, retrievedFromCache) in
            
            guard let tweets = json as? [AnyObject] else {
                return
            }

            print("\(cursor) :\(account.timelineFragments)")
            

            var index = cursor == .Previous && account.timelineFragments.count > 0 ? account.timelineFragments[atFragment].count : 0
            
            var newTweets = [Int]()

            for tweet in tweets {
                if let tweetObject = tweet as? [String: AnyObject], idtweet = tweet["id"] as? Int {
                    
                    if let tw = self.twitterTweets[idtweet] {
                        tw.update(tweetObject)
                    } else {
                        let tw = TwitterTweet(json: tweetObject)
                        if let user = tw["user"], userid = user["id"] as? Int {
                            if self.twitterUsers[userid] == nil {
                                self.twitterUsers[userid] = TwitterUser(json: user)
                            }
                        }
                        self.twitterTweets[idtweet] = tw

                    }

                    self.twitterTweets[idtweet]?.attributedString = TwitterTweetDisplayer.getAttributedString(self.twitterTweets[idtweet]!)
                    if account.timeline.indexOf(idtweet) == nil {
                        account.timeline.insert(idtweet, atIndex: index)
                        newTweets.append(idtweet)
                        index += 1
                   }
                    print("account.timeline.count = \(account.timeline.count)")
                }
            }
            
            if tweets.count == 0 {
                NSNotificationCenter.defaultCenter().postNotificationName(Events.TwitterAccountTimelineRetrieved.rawValue, object: self, userInfo: ["key": sn, "newTweets": [], "insertAt": 0, "continueOnTweetId": account.timelineFragments[atFragment].max_id])
                return
            }
            
            var insertAt = 0
            
            if let since_id = tweets[0]["id"] as? Int , max_id = tweets[tweets.count - 1]["id"] as? Int {
                if account.timelineFragments.count > 0 {
                    
                    switch cursor {
                    case .Previous :
                        let fragment = account.timelineFragments[atFragment]
                        insertAt = fragment.count
                        if account.timelineFragments.count > 1 && account.timelineFragments[1].since_id > max_id {
                            account.timelineFragments[atFragment] = TwitterAccount.TimelineFragment(since_id: fragment.since_id, max_id: account.timelineFragments[1].max_id, count: fragment.count + newTweets.count + account.timelineFragments[1].count)
                            account.timelineFragments.removeAtIndex(1)
                        } else {
                            account.timelineFragments[atFragment] = TwitterAccount.TimelineFragment(since_id: fragment.since_id, max_id: max_id, count: fragment.count + newTweets.count)
                        }
                
                    case .Next :
                        account.timelineFragments[0] = TwitterAccount.TimelineFragment(since_id: since_id, max_id: account.timelineFragments[0].max_id, count: account.timelineFragments[0].count + newTweets.count)
                    case .Start :
                        print("MERGING FRAGMENT.........")
                        if account.timelineFragments[0].since_id > max_id {
                            account.timelineFragments[0] = TwitterAccount.TimelineFragment(since_id: since_id, max_id: account.timelineFragments[0].max_id, count: account.timelineFragments[0].count + newTweets.count)
                        } else {
                            let fragment = TwitterAccount.TimelineFragment(since_id: since_id, max_id: max_id, count: newTweets.count)
                            account.timelineFragments.insert(fragment , atIndex: 0)
                        }
                    }
                    
                } else {
                    let fragment = TwitterAccount.TimelineFragment(since_id: since_id, max_id: max_id, count: newTweets.count)
                    account.timelineFragments.insert(fragment , atIndex: 0)
                }
            }
            
            
            print(account.timelineFragments)
            
            NSNotificationCenter.defaultCenter().postNotificationName(Events.TwitterAccountTimelineRetrieved.rawValue, object: self, userInfo: ["key": sn, "newTweets": newTweets, "insertAt": insertAt, "continueOnTweetId": account.timelineFragments[atFragment].max_id])
            
            self.save(Storage.TwitterAccounts)
            self.save(Storage.TwitterTweets)
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
                        if let key = self.twitterUsers[iduser]?.urlImageProfil?.md5() {
                            self.twitterUsersByImageProfil[key] = iduser
                        }
                    }
                }
                
                //test if informations are not retrieved from the cache
                if !retrievedFromCache && friends.count > 0 {
                    retrieveFriends()
                    return
                }
                //no more friends to retrieved we sort
                account.friends = account.friends.sort({ (a, b) -> Bool in
                    guard let usera = self.twitterUsers[a]?["screen_name"] as? String, userb = self.twitterUsers[b]?["screen_name"]  as? String else {
                        return true
                    }

                    return usera.lowercaseString < userb.lowercaseString
                })
                self.save(Storage.TwitterAccounts)
                self.save(Storage.TwitterUsers)

                NSNotificationCenter.defaultCenter().postNotificationName(Events.TwitterAccountFriendRetrieved.rawValue, object: self, userInfo: ["key": sn])
            }
        }

        func retrieveIds(cursor: Int = -1) {
            
            params["cursor"] = String(cursor)
            
            //all request are part of the same retrieving data so don't call the Twitter connection with the reading from cache enable
            //other the completed callback will be executed on the read from cache event and the read from network event in the twitter connection
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
                    //we only continue if datas are not retrived from the cache
                    if next_cursor > 0 && !retrievedFromCache {
                        retrieveIds(next_cursor)
                        return
                    }
                }

                friends = account.friends.sort()
                if friends.count > 0 {
                    retrieveFriends()
                }
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
                self.save(Storage.TwitterAccounts)
                NSNotificationCenter.defaultCenter().postNotificationName(Events.TwitterAccountRetrieved.rawValue, object: self, userInfo: ["key": sn])
            })
        }
        
    }

}