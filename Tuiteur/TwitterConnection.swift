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
                return ["include_entities" : "false"
                    , "skip_status": "true"
                    , "include_email": "false"]
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

    private let urlcomponents: NSURLComponents =  {
        let uc = NSURLComponents()
        uc.scheme = "https"
        uc.host = "api.twitter.com"
        return uc
    }()

    var accounts : [ACAccount]?

    private init() {
        twitterAccountType = accountsStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
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
    
    private func getSLRequest(account: ACAccount, api: API, params: [String: String]?, completion: (AnyObject) -> ()) {
        
        urlcomponents.path = "/1.1/" + api.rawValue + ".json"
        
        let req = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: api.getMethod(), URL: urlcomponents.URL, parameters: params)
        req.account = account
        
        req.performRequestWithHandler { (data, response, error) in
            if let err = error {
                NSNotificationCenter.defaultCenter().postNotificationName(Events.Error.rawValue, object: self, userInfo: ["Error": err])
                return
            }

            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                completion(json);
            } catch {
                NSNotificationCenter.defaultCenter().postNotificationName(Events.Error.rawValue, object: self, userInfo: ["Error": "\(error)", "api": api.rawValue])
                
            }
            
        }
    }
    
    
    
    
}
