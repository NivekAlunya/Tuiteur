//
//  TweetCellMedia.swift
//  Tuiteur
//
//  Created by Kevin Launay on 6/15/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import UIKit

class TweetCellMedia: TweetCellSimple {

    
    @IBOutlet var imageStacks: [UIStackView]!

    @IBOutlet var images: [UIImageView]!
    
    @IBOutlet var heigthConstraints: [NSLayoutConstraint]!
    
    @IBOutlet var widthConstraints: [NSLayoutConstraint]!
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
