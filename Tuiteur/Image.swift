//
//  Image.swift
//  Tuiteur
//
//  Created by Kevin Launay on 4/3/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

class Image:NSObject {
    
    enum State {
        case New, Downloaded, Loaded, Failed
    }
    
    var processing = false
    let identifier:String
    let weburl:NSURL
    var fileurl:NSURL?
    var state = State.New
    var UUID: String!
    var sourceImageUUID: String!
    var img: UIImage?

    init(identifier: String, weburl: NSURL, fileurl: NSURL?) {
        self.identifier = identifier
        self.weburl = weburl
        
        super.init()
        
        self.UUID = FICStringWithUUIDBytes(FICUUIDBytesFromMD5HashOfString(identifier))
        
        self.sourceImageUUID = FICStringWithUUIDBytes(FICUUIDBytesFromMD5HashOfString(weburl.absoluteString))
        
        self.fileurl = fileurl
    }
    
    func loadImage() -> Bool {
        guard let file = self.fileurl else {
            return false
        }
        
        let imageData = NSData(contentsOfURL: file)
        
        if imageData?.length > 0 {
            //self.img = UIImage(data: imageData!)
            self.img = UIImage(data: imageData!, scale: CGFloat(Device.scale))
            self.state = .Loaded
            return true
        } else {
            self.state = .Failed
        }
        return false
    }
}

extension Image: FICEntity {
    
    func sourceImageURLWithFormatName(formatName: String!) -> NSURL! {
        return self.weburl
    }
    
    func drawingBlockForImage(image: UIImage!, withFormatName formatName: String!) -> FICEntityImageDrawingBlock! {
        return {
            context, contextSize in

            var ctxBounds = CGRectZero
            ctxBounds.size = contextSize
            CGContextClearRect(context, ctxBounds)
            
            UIGraphicsPushContext(context);
            image.drawInRect(ctxBounds)
            UIGraphicsPopContext();
            
        }
    }

}