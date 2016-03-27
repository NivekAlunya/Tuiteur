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
        case TwitterAccountRefreshed = "ACCOUNT TO TWITTER REFRESHED"
    }
    
    var twitterAccount = [String: TwitterAccount]()
    
    static let instance = TwitterStore()
    
    private init() {

    }
    
    func getTwitterAccounts() {
        
        guard let accs = TwitterConnection.instance.accounts else {
            return
        }
        
        let api = TwitterConnection.API.Account_VerifyCredentials
        
        let params = api.getParams()
        
        var fromCache: Bool = true
        
        for acc in accs {
            
            fromCache = self.twitterAccount[acc.userFullName] == nil ? true : false
            
            TwitterConnection.instance.request(acc, api: api, params: params, cache: fromCache, completion: { (json, retrievedFromCache) in
                if let ta = self.twitterAccount[acc.userFullName] {
                    NSNotificationCenter.defaultCenter().postNotificationName(Events.TwitterAccountRefreshed.rawValue, object: self, userInfo: ["key": acc.userFullName])
                    
                } else {
                    let ta = TwitterAccount(json: json)
                    self.twitterAccount[acc.userFullName] = ta
                    NSNotificationCenter.defaultCenter().postNotificationName(Events.TwitterAccountRetrieved.rawValue, object: self, userInfo: ["key": acc.userFullName])
                }
            })
        }
        
    }

}