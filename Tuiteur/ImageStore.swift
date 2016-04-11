//
//  ImageStore.swift
//  Tuiteur
//
//  Created by Kevin Launay on 4/3/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

class ImageStore {
    
    static let instance = ImageStore()
    
    var images = [String: Image]()
    
    var pendings = ImagePendingOperations()
    
    private init() {
        
        NSNotificationCenter.defaultCenter().addObserverForName(ImageDownloader.Events.Downloaded.rawValue, object: ImageDownloader.instance, queue: nil) { (notification) in
            guard let identifier = notification.userInfo?["identifier"] as? String
                , image = self.images[identifier]
                , let fileurl = notification.userInfo?["fileurl"] as? NSURL else {
                    return
            }
            
            image.state = Image.State.Downloaded
            image.fileurl = fileurl
            let op = ImageLoader(image: image)
            self.pendings.loadings[image.identifier] = op
            self.pendings.loadingQueue.addOperation(op)
        }
    }
    
    func getImage(weburl: String) -> Image? {
        let h = weburl.md5()
        
        if let image = images[h] {
            switch image.state {
            case .New:
                pendings.downloadings[h] = ImageDownloader.instance.download(image.weburl)
            case .Downloaded:
                break;
            case .Loaded:
                return image
            default:
                return nil
            }
            
        } else {

            guard let url = NSURL(string: weburl) else {
                return nil
            }
            images[h] = Image(identifier: h, weburl: url, fileurl: nil)
            pendings.downloadings[h] = ImageDownloader.instance.download(url)
        }
        return nil
    }

    func abort(identifier: String? = nil) {
        if let ident = identifier {
            pendings.loadings[ident]?.cancel()
            pendings.loadings.removeValueForKey(ident)
        } else {
            for (k, op) in pendings.loadings {
                op.cancel()
                pendings.loadings.removeValueForKey(k)
            }
            for (k, task) in pendings.downloadings {
                task.cancel()
                pendings.downloadings.removeValueForKey(k)
            }
        }
    }
}