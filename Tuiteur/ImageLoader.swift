//
//  ImageDownloaderOperation.swift
//  Tuiteur
//
//  Created by Kevin Launay on 4/5/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

class ImageLoader: NSOperation {
    
    let image: Image
    
    init(image: Image) {
        self.image = image
    }
    
    override func main() {
        switch image.state {
        case .Downloaded:
            image.loadImage()
            if self.cancelled {
                return
            }
            fallthrough
        case .Loaded:
            print(image.state)
            if self.cancelled {
                return
            }
        default:
            return
        }
        
        
    }
}