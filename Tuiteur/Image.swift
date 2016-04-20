//
//  Image.swift
//  Tuiteur
//
//  Created by Kevin Launay on 4/3/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

class Image:NSObject,  FICEntity {
    
    enum State {
        case New, Downloaded, Loaded, Failed
    }
    
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
        
        self.UUID = weburl.absoluteString.md5()
        self.sourceImageUUID = ""
        self.fileurl = fileurl
    }
    
    func loadImage() -> Bool {
        guard let file = self.fileurl else {
            return false
        }
        
        let imageData = NSData(contentsOfURL: file)
        
        if imageData?.length > 0 {
            self.img = UIImage(data: imageData!)
            self.state = .Loaded
            return true
        } else {
            self.state = .Failed
        }
        return false
    }
    
    func sourceImageURLWithFormatName(formatName: String!) -> NSURL! {
        return NSURL()
    }
    
    func drawingBlockForImage(image: UIImage!, withFormatName formatName: String!) -> FICEntityImageDrawingBlock! {
        return {
            context, contextSize in
            
            image.drawInRect(CGRect(origin: CGPointZero, size: contextSize))
        }
    }
    
    func drawInRect(area: CGRect) -> UIImage? {
        guard let image = self.img else {
            return nil
        }
        
        var rect = CGRectZero
        
        let ratioW = image.size.width / area.width
        
        let ratioH = image.size.height / area.height
        
        print("\(ratioW) : \(ratioH)")
        
        if ratioW > ratioH  {
            let height = image.size.height / (ratioW)
            let offset = (area.height - height) / 2
            rect = CGRectMake(0, offset, area.width , height)
        } else {
            let width = image.size.width  / ratioH
            let offset = (area.width - width) / 2
            rect = CGRectMake(offset, 0, width , area.height)
        }

        image.drawInRect(rect)
        
        let thumb = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return thumb

    }
}