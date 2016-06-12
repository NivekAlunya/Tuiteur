//
//  ImageStore.swift
//  Tuiteur
//
//  Created by Kevin Launay on 4/3/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

class ImageStore {
    
    let scale: CGFloat = CGFloat(Device.scale)
    enum FastImageFormat: String {
        case UserAvatar = "USER_AVATAR"
        case TweetAvatar = "TWEET_AVATAR"
    }
    var formats = [String:FICImageFormat]()
    static let instance = ImageStore()
    
    var images = [String: Image]()
    
    var pendings = ImagePendingOperations()
    var fic: FICImageCache!
    
    private init() {
        
        ImageDownloader.instance.queue = pendings.downloadingQueue
        //let scale = 1.0
        formats[FastImageFormat.TweetAvatar.rawValue] = FICImageFormat(name: FastImageFormat.TweetAvatar.rawValue, family: "FAMILY", imageSize:CGSize(width: 48, height: 48) , style: FICImageFormatStyle.Style32BitBGRA, maximumCount: 1000, devices: Device.isPhone() ? FICImageFormatDevices.Phone  : FICImageFormatDevices.Pad, protectionMode: FICImageFormatProtectionMode.None)
        
        formats[FastImageFormat.UserAvatar.rawValue] = FICImageFormat(name: FastImageFormat.UserAvatar.rawValue, family: "FAMILY", imageSize:CGSize(width: 96, height: 96) , style: FICImageFormatStyle.Style32BitBGRA, maximumCount: 1000, devices: Device.isPhone() ? FICImageFormatDevices.Phone  : FICImageFormatDevices.Pad, protectionMode: FICImageFormatProtectionMode.None)
        
        fic =  FICImageCache.sharedImageCache()
        //fic.delegate = ImageStore.instance;
        fic.setFormats([formats[FastImageFormat.TweetAvatar.rawValue]!, formats[FastImageFormat.UserAvatar.rawValue]!]);
        
        NSNotificationCenter.defaultCenter().addObserverForName(ImageDownloader.Events.Downloaded.rawValue, object: ImageDownloader.instance, queue: nil) { (notification) in
            guard let identifier = notification.userInfo?["identifier"] as? String
                , image = self.images[identifier]
                , let fileurl = notification.userInfo?["fileurl"] as? NSURL else {
                    return
            }
            image.fileurl = fileurl
            image.state = Image.State.Downloaded
            let op = ImageLoader(image: image)
            self.pendings.loadings[image.identifier] = op
            self.pendings.loadingQueue.addOperation(op)
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(ImageLoader.Events.Loaded.rawValue, object: ImageDownloader.instance, queue: nil) { (notification) in
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(ImageLoader.Events.Cancelled.rawValue, object: nil, queue: nil) { (notification) in
            guard let image = notification.userInfo?["image"] as? Image else {
                return
            }
            image.processing = false
        }
    }
    
    func pause() {
        self.pendings.loadingQueue.suspended = true
        self.pendings.downloadingQueue.suspended = true
    }

    func resume() {
        self.pendings.loadingQueue.suspended = false
        self.pendings.downloadingQueue.suspended = false
    }

    func getImage(weburl: String) -> Image? {
        let h = weburl.md5()
        
        if let image = images[h] {
            if image.processing {
                return nil
            }
            switch image.state {
            case .New:
                image.processing = true
                pendings.downloadings[h] = ImageDownloader.instance.download(image.weburl)
            case .Downloaded:
                image.processing = true
                let op = ImageLoader(image: image)
                pendings.loadings[image.identifier] = op
                pendings.loadingQueue.addOperation(op)
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
            let image = Image(identifier: h, weburl: url, fileurl: nil)
            image.processing = true
            images[h] = image
            pendings.downloadings[h] = ImageDownloader.instance.download(url)
            
            return image
        }
        return nil
    }

    func abort(identifier: String? = nil) {
        if let ident = identifier {
            if images[ident]?.state == .New {
                pendings.downloadings.removeValueForKey(ident)?.cancel()
            }
            pendings.loadings.removeValueForKey(ident)?.cancel()
            images[ident]?.processing = false
        } else {
            for (k, _) in pendings.loadings {
                if images[k]?.state == .New {
                    pendings.downloadings.removeValueForKey(k)?.cancel()
                }
                images[k]?.processing = false
            }
            for (k, _) in pendings.downloadings {
                pendings.downloadings.removeValueForKey(k)?.cancel()
                images[k]?.processing = false
            }
        }
    }
    
    func getUIImage(image: Image, format: FastImageFormat, onRetrieve:(UIImage)->()) {
        let exists =  fic.retrieveImageForEntity(image, withFormatName: format.rawValue) { (entity, formatName, img) in
            onRetrieve(img)
        }
        print(format.rawValue)
        if image.state == Image.State.Loaded {
            if !exists {
                if let size = formats[format.rawValue]?.imageSize, img = drawInRect(image, area: CGRect(origin: CGPointZero, size: size)) {
                    fic.setImage(img, forEntity: image, withFormatName: format.rawValue, completionBlock: { (entity, formatName, ficimage) in
                        if let img = ficimage {
                            onRetrieve(img)
                        }
                    })
                }
            }
        }
    }
    
    func drawInRect(image: Image, area: CGRect) -> UIImage? {
        guard let image = image.img else {
            return nil
        }
        
        var rect = CGRectZero
        
        let ratioW = image.size.width / area.width
        
        let ratioH = image.size.height / area.height
        
        if ratioW > ratioH  {
            let height = image.size.height / (ratioW)
            let offset = (area.height - height) / 2
            rect = CGRectMake(0, offset, area.width , height)
        } else {
            let width = image.size.width  / ratioH
            let offset = (area.width - width) / 2
            rect = CGRectMake(offset, 0, width , area.height)
        }

        UIGraphicsBeginImageContextWithOptions(area.size, false, 0.0)
        
        image.drawInRect(rect)
        
        let thumb = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        print(thumb.size)
        return thumb
    }
}