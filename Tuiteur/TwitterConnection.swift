//
//  TwitterConnextion.swift
//  Tuiteur
//
//  Created by Kevin Launay on 3/25/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation
import Accounts
import Social

class TwitterConnection {
 
    typealias RequestCompletion = (json: AnyObject, retrievedFromCache:Bool) -> ()
    
    enum Events: String {
        
        case Granted = "ACCESS TO TWITTER ACCOUNTS GRANTED"

        case NotGranted = "NO ACCESS TO TWITTER ACCOUNT"

        case Request = "REQUEST OK"
        
        case Error = "ERROR"
        
        init?(_ s: String) {
            self.init(rawValue: s)
        }
    }
    
    enum API: String {
        
        case Account_VerifyCredentials = "account/verify_credentials"
        
        func getParams() -> [String:String]? {
            switch self {
            case .Account_VerifyCredentials:
                return [
                    "include_entities" : "false"
                    , "skip_status": "true"
                    , "include_email": "false"
                ]
            default:
                return nil
            }
        }
        
        func getMethod() -> SLRequestMethod {
            switch self {
            case .Account_VerifyCredentials:
                return SLRequestMethod.GET
            default:
                return SLRequestMethod.GET
            }
        }
    }
    
    static let instance = TwitterConnection()
    
    let accountsStore = ACAccountStore()
    
    let twitterAccountType: ACAccountType
    
    private(set) var account: ACAccount?
    
    private let urlCache: NSURL? = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory , inDomains: .UserDomainMask)
        return urls.first
    }()
    
    var selectedAccountIndex: Int {
        get {
            guard let accs = accounts, acc = account, index = accs.indexOf(acc) else  {
                account = nil
                return -1
            }
            
            return index
            
        }
        set(index) {
            guard let accs = accounts else  {
                account = nil
                return
            }
            
            account = accs[index]
        }
    }
    
    
    private let urlcomponents: NSURLComponents =  {
        let uc = NSURLComponents()
        uc.scheme = "https"
        uc.host = "api.twitter.com"
        return uc
    }()

    var accounts : [ACAccount]?

    private init() {
        twitterAccountType = accountsStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        print(self.urlCache?.absoluteString)
    }
    
    func requestAccess() {
        accountsStore.requestAccessToAccountsWithType(twitterAccountType, options: nil) { (granted, error) in
            if let err = error {
                NSNotificationCenter.defaultCenter().postNotificationName(Events.Error.rawValue, object: self, userInfo: ["Error": err])
                return
            }
            if granted {
                self.accounts = self.accountsStore.accountsWithAccountType(self.twitterAccountType) as? [ACAccount]
                NSNotificationCenter.defaultCenter().postNotificationName(Events.Granted.rawValue, object: self)
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(Events.NotGranted.rawValue, object: self)
            }
        }
    }
    
    private func computeHashForRequest(account: ACAccount, api: API, params: [String: String]?) -> String {
        var sparams = ""
        if let p = params {
            for (key, value) in p {
                sparams += key + "-" + value
            }
        }
        return (account.identifier + "-" + api.rawValue + "-" + sparams).md5()
    }
    
    private func execRequest(account: ACAccount, api: API, params: [String: String]?, cache: Bool, completion: RequestCompletion) {

        func processData(data: NSData, retrievedFromCache: Bool) {
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                completion(json: json, retrievedFromCache: retrievedFromCache);
            } catch {
                NSNotificationCenter.defaultCenter().postNotificationName(Events.Error.rawValue, object: self, userInfo: ["Error": "\(error)", "api": api.rawValue])
            }
            
        }
        
        let hashRequest = computeHashForRequest(account, api: api, params: params)
        
        let path = hashRequest + ".json"

        if cache {
            if let url = self.urlCache, data = NSData(contentsOfURL: url.URLByAppendingPathComponent(path)) {
                print("Reading from cache")
                processData(data, retrievedFromCache: true)
            }
        }

        urlcomponents.path = "/1.1/" + api.rawValue + ".json"
        
        let req = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: api.getMethod(), URL: urlcomponents.URL, parameters: params)
        
        
        req.account = account
        
        req.performRequestWithHandler { (data, response, error) in
            
            if let err = error {
                NSNotificationCenter.defaultCenter().postNotificationName(Events.Error.rawValue, object: self, userInfo: ["Error": err])
                return
            }
            
            if let url = self.urlCache {
                data.writeToURL(url.URLByAppendingPathComponent(path), atomically: true)
                print(response.allHeaderFields["Last-Modified"])
            }
            
            processData(data, retrievedFromCache: false)
        }
    }

    func request(api: API, params: [String: String]?, cache: Bool, completion: RequestCompletion) {
        guard let acc = account else {
            return
        }
        
        execRequest(acc, api: api, params: params, cache: cache, completion: completion)
    }

    func request(account: ACAccount, api: API, params: [String: String]?, cache: Bool, completion: RequestCompletion) {
        
        execRequest(account, api: api, params: params, cache: cache, completion: completion)
    }
    
}
