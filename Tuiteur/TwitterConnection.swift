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
        case Users_Lookup = "users/lookup"
        case Friends_Ids = "friends/ids"
        case Statuses_HomeTimeline = "statuses/home_timeline"
        
        
        func getParams() -> [String:String]? {
            switch self {
            case .Account_VerifyCredentials:
                return [
                    "include_entities" : "false"
                    , "skip_status": "true"
                    , "include_email": "false"
                ]
            case .Friends_Ids:
                return [
                    "user_id": "",
                    "screen_name" : "",
                    "cursor": "-1",
                    "stringify_ids": "true",
                    "count": "5000"
                ]
            case .Users_Lookup :
                return [
                    "screen_name": "",
                    "user_id": "",
                    "include_entities" : "true"
                ]
            case .Statuses_HomeTimeline:
                return [
                    "count" : "200"
                    , "since_id" : "0"
                    , "max_id" : "0"
                    , "trim_user" : "false"
                    , "exclude_replies": "true"
                    , "contributor_details": "false"
                    , "include_entities" : "false"
                ]
            default:
                return nil
            }
        }
        
        func getMethod() -> SLRequestMethod {
            switch self {
            case .Account_VerifyCredentials:
                return SLRequestMethod.GET
            case .Friends_Ids:
                return SLRequestMethod.GET
            case .Users_Lookup:
                return SLRequestMethod.POST
            case .Statuses_HomeTimeline:
                return SLRequestMethod.GET
            default:
                return SLRequestMethod.GET
            }
        }
    }
    
    struct RequestInfo {
        var limit: Int
        var left: Int
        var resetAt: NSTimeInterval
        var lastModified: String
    }

    private var history = [String: RequestInfo]()
    
    static let instance = TwitterConnection()
    
    let accountsStore = ACAccountStore()
    
    let twitterAccountType: ACAccountType
    
    private(set) var account: ACAccount?
    
    private let urlCache: NSURL? = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory , inDomains: .UserDomainMask)
        if let url = urls.first?.URLByAppendingPathComponent("twitterAPI") {
            do {
                try NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
                return url
            } catch {
//                let err = NSError(domain: "", code: 0, userInfo: ["Description": "Can't store data at \(url.path)"])
//                NSNotificationCenter.defaultCenter().postNotificationName(Events.Error.rawValue, object: self, userInfo: ["Error": err])
            }
        }
        return nil
    }()
    
    var selectedAccount: String? {
        get {
            guard let acc = account else  {
                return nil
            }
            
            return acc.username
        }
        set(username) {
            guard let un = username else  {
                account = nil
                return
            }
            
            account = accounts[un]
        }
    }
    
    
    private let urlcomponents: NSURLComponents =  {
        let uc = NSURLComponents()
        uc.scheme = "https"
        uc.host = "api.twitter.com"
        return uc
    }()

    var accounts = [String: ACAccount]()

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
                if let accs = self.accountsStore.accountsWithAccountType(self.twitterAccountType) as? [ACAccount] {
                    for acc in accs {
                        self.accounts[acc.username] = acc
                    }
                }
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


        urlcomponents.path = "/1.1/" + api.rawValue + ".json"
        
        let req = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: api.getMethod(), URL: urlcomponents.URL, parameters: params)

        req.account = account

        req.performRequestWithHandler { (data, response, error) in
            
            if let err = error {
                NSNotificationCenter.defaultCenter().postNotificationName(Events.Error.rawValue, object: self, userInfo: ["Error": err])
                return
            }
            
            if response.statusCode != 429 && response.statusCode != 200 {
                let err = NSError(domain: "", code: 2, userInfo: ["code" : response.statusCode, "error": "Error requesting twitter api"])
                NSNotificationCenter.defaultCenter().postNotificationName(Events.Error.rawValue, object: self, userInfo: ["Error": err])
                
                return
            }
            
            if cache || response.statusCode == 429 {
                print(response.allHeaderFields)
                if let url = self.urlCache, data = NSData(contentsOfURL: url.URLByAppendingPathComponent(path)) {
                    print("Reading from cache")
                    processData(data, retrievedFromCache: true)
                } else {
                    let err = NSError(domain: "", code: 2, userInfo: ["code" : response.statusCode, "error": "No cache found for this request"])
                    NSNotificationCenter.defaultCenter().postNotificationName(Events.Error.rawValue, object: self, userInfo: ["Error": err])
                }
                return
            }
            
            if var requestHistory = self.history[hashRequest] {
                requestHistory.lastModified = response.allHeaderFields["Last-Modified"] as! String
                requestHistory.resetAt = NSTimeInterval(response.allHeaderFields["x-rate-limit-reset"] as! String) ?? 0.0
                requestHistory.limit = Int(response.allHeaderFields["x-rate-limit-limit"] as! String) ?? 0
                requestHistory.left = Int(response.allHeaderFields["x-rate-limit-remaining"] as! String) ?? 0
            } else {
                self.history[hashRequest] = RequestInfo(limit: Int(response.allHeaderFields["x-rate-limit-limit"] as! String) ?? 0
                    , left: Int(response.allHeaderFields["x-rate-limit-remaining"] as! String) ?? 0, resetAt: NSTimeInterval(response.allHeaderFields["x-rate-limit-reset"] as! String) ?? 0.0, lastModified: response.allHeaderFields["Last-Modified"] as! String)
            }
            
            if let interval = NSTimeInterval(response.allHeaderFields["x-rate-limit-reset"] as! String) {
                print("x-rate-limit-reset : \(NSDate(timeIntervalSince1970: interval))")
            }

            if let url = self.urlCache {
                var headers = String()
                headers += "\(response.URL!.absoluteString)\n"
                headers += "\(response.statusCode)\n"
                for (k,v) in params! {
                    headers += "\(k) = \(v)\n"
                }
                for (k,v) in response.allHeaderFields {
                    headers += (k as! String) + " : " + (v as! String) + "\n"
                }
                
                do {
                    try headers.writeToURL(url.URLByAppendingPathComponent(hashRequest + ".headers"), atomically: true, encoding: NSUTF8StringEncoding)
                } catch {
                    print(error)
                    print("Error writing headers")
                }
            }
            
            if let url = self.urlCache {
                data.writeToURL(url.URLByAppendingPathComponent(path), atomically: true)
                print(response.allHeaderFields["Last-Modified"] ?? "")
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
