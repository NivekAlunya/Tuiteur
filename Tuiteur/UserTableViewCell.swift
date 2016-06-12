//
//  UserTableViewCell.swift
//  Tuiteur
//
//  Created by Kevin Launay on 5/19/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet var photo: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var effect: UIVisualEffectView!
    @IBOutlet var activity: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        print("init from nib")
        //effect.bounds = CGRect(x: 0.0 , y: 0.0, width: contentView.frame.width, height: contentView.frame.height)
        ///effect.transform = CGAffineTransformMakeRotation(90.0.degreesToRadians)
        photo.layer.masksToBounds = true
        photo.layer.cornerRadius = 10.0
        photo.layer.borderWidth = 2.0
        photo.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
