//
//  PendingOperations.swift
//  Tuiteur
//
//  Created by Kevin Launay on 4/5/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

class ImagePendingOperations {

    lazy var downloadings = [String: NSURLSessionDownloadTask]()
    lazy var loadings = [String: NSOperation]()
    
    lazy var loadingQueue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Load queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    
    
}