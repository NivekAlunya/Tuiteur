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

        photo.layer.masksToBounds = true
        photo.layer.cornerRadius = 10.0
        photo.layer.borderWidth = 2.0
        photo.layer.borderColor = UIColor.Crayon.eerieblack.getUIColor().CGColor
        photo.backgroundColor = UIColor.Crayon.white.getUIColor()
        username.backgroundColor = UIColor.Crayon.eerieblack.getUIColor()
        username.textColor = UIColor.Crayon.white.getUIColor()

    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
