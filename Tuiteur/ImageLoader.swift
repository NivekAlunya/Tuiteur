//
//  ImageDownloaderOperation.swift
//  Tuiteur
//
//  Created by Kevin Launay on 4/5/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

class ImageLoader: NSOperation {

    enum Events : String {
        case Loaded = "ImageLoader.Events.Downloaded"
        case Error = "ImageLoader.Events.Error"
        case Cancelled = "ImageLoader.Events.Cancelled"
    }

    let image: Image
    
    init(image: Image) {
        self.image = image
    }
    
    override func main() {
        switch image.state {
        case .Downloaded:
            self.image.processing = true
            image.loadImage()
            image.state = Image.State.Loaded
            if self.cancelled {
                return
            }
            fallthrough
        case .Loaded:
            let userinfo = ["image": image]
            if self.cancelled {
                NSNotificationCenter.defaultCenter().postNotificationName(Events.Cancelled.rawValue, object: self, userInfo: userinfo)
                return
            }
            self.image.processing = false
            NSNotificationCenter.defaultCenter().postNotificationName(Events.Loaded.rawValue, object: self, userInfo: userinfo)
        default:
            return
        }
    }
}