//
//  ImageDownloader.swift
//  Tuiteur
//
//  Created by Kevin Launay on 4/3/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloader: NSObject {
    
    enum Events : String {
        case Downloaded = "ImageDownloader.Events.Downloaded"
        case Cancelled = "ImageDownloader.Events.Cancelled"
        case Error = "ImageDownloader.Events.Error"
    }
    
    static let instance = ImageDownloader()
    
    lazy private var session: NSURLSession = {
        
        //let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
//        let queue = ImageStore.instance.pendings.downloadingQueue
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("image_downloader_session_identifier")
        configuration.HTTPMaximumConnectionsPerHost = 4
        let queue: NSOperationQueue? = nil
        return NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    var queue: NSOperationQueue {
        get {
            return session.delegateQueue
        }
        set (queue) {
            self.session.invalidateAndCancel()
            let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("image_downloader_session_identifier_2")
            configuration.HTTPMaximumConnectionsPerHost = 4
            self.session =  NSURLSession(configuration: configuration, delegate: self, delegateQueue: queue)
        }
    }
    
    private let urlStorage: NSURL? = {
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory , inDomains: .UserDomainMask)
        
        if let url = urls.first?.URLByAppendingPathComponent("Images") {
            do {
                //try NSFileManager.defaultManager().removeItemAtURL(url)
                try NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
                return url
            } catch {
                //let err = NSError(domain: "", code: 0, userInfo: ["Description": "Can't store data at \(url.path)"])
                //NSNotificationCenter.defaultCenter().postNotificationName(Events.Error.rawValue, object: self, userInfo: ["Error": err])
            }
        }
        
        return nil
    }()
    
    
 
    private override init() {
        super.init()
        _ = self.session
    }
    
    func clearCache() {
        guard let directory = urlStorage else {
            return
        }
        do {
            try NSFileManager.defaultManager().removeItemAtURL(directory)
            try NSFileManager.defaultManager().createDirectoryAtURL(directory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error on purging cache")
        }
    }

    func download(weburl: NSURL) -> NSURLSessionDownloadTask? {
        
        guard let fileinfo = getFileURLForWebURL(weburl) else {
            return nil
        }
        var error:NSError?
        
        if fileinfo.fileurl.checkResourceIsReachableAndReturnError(&error) {
            print("READ FROM CACHE ... \(weburl.absoluteString)")
            let userinfo = getUserInfoForNotification(weburl, fileurl: fileinfo.fileurl, identifier: fileinfo.identifier)
            NSNotificationCenter.defaultCenter().postNotificationName(Events.Downloaded.rawValue, object: self, userInfo: userinfo)
            return nil
        } else {
            let task = session.downloadTaskWithURL(weburl)
            task.resume()
            return task
        }
    }
    
    func getFileURLForWebURL(weburl: NSURL) -> (fileurl: NSURL, identifier: String, ext: String)? {

        let identifier = weburl.absoluteString.md5()
        let ext = weburl.pathExtension ?? "file"
        
        if let fileurl = self.urlStorage?.URLByAppendingPathComponent("\(identifier).\(ext)") {
            return ( fileurl,  identifier, ext)
        }
        
        return nil
    }
    
    func getUserInfoForNotification(weburl: NSURL, fileurl: NSURL, identifier: String) -> [String: AnyObject] {
        
        return ["identifier": identifier , "fileurl": fileurl, "weburl": weburl]
    }
}

extension ImageDownloader: NSURLSessionDownloadDelegate {
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        
        guard let weburl = downloadTask.originalRequest?.URL  else {
            return
        }
        
        if let fileinfo = getFileURLForWebURL(weburl)  {
            let userinfo = getUserInfoForNotification(weburl, fileurl: fileinfo.fileurl, identifier: fileinfo.identifier)
            do {
                try NSFileManager.defaultManager().moveItemAtURL(location, toURL: fileinfo.fileurl)
//                print("Post notification File Downloaded")
                if downloadTask.state == .Canceling {
                    return
                } else {
                    NSNotificationCenter.defaultCenter().postNotificationName(Events.Downloaded.rawValue, object: self, userInfo: userinfo)
                }
            } catch {
                print(error)
                let err = NSError(domain: "", code: 0, userInfo: userinfo)
                NSNotificationCenter.defaultCenter().postNotificationName(Events.Error.rawValue, object: self, userInfo: ["error": err])
            }
        }
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        guard let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
            , let completionHandler = appDelegate.backgroundSessionCompletionHandler else {
                return
        }
//        print("URLSessionDidFinishEventsForBackgroundURLSession")
        appDelegate.backgroundSessionCompletionHandler = nil
        dispatch_async(dispatch_get_main_queue(), {
            completionHandler()
        })
        
    }
}