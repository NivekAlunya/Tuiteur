//
//  TweetCellSimpleCollectionViewCell.swift
//  Tuiteur
//
//  Created by Kevin Launay on 6/1/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import UIKit

class TweetCellSimple: UICollectionViewCell {
    @IBOutlet var txtTweet: UITextView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblScreenName: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var iv: UIImageView!
    @IBOutlet var cellcontainer: UIView!
    
    private let formatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        f.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        return f
    }()
    
    var imagePropertiesSet = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        //initialize here
        txtTweet.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 6.0
        iv.layer.borderWidth = 0.0
        iv.layer.borderColor = UIColor.blackColor().CGColor
        
    }
    
    func setImageProfil(image: UIImage?) {
        iv.image = image
        adjustHeight()
    }
    
    func setText(name: String, screenName: String, date: String, text: NSAttributedString, user: TwitterUser? = nil) {
        lblName.text = name
        lblScreenName.text = "@\(screenName)"
        //Tue Apr 12 17:27:19 +0000 2016
        print(date)
        if let localDate = formatter.dateFromString(date) {
            let offset = user?["utc_offset"] as? Double ?? 0.0
            let dt = NSDate(timeInterval: offset, sinceDate: localDate)
            lblDate.text = "\(dt)"
        } else {
            lblDate.text = date
        }
        
        
        
        txtTweet.attributedText = text
        adjustHeight()
        contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, txtTweet.frame.size.height + iv.frame.size.height)
    }
    
    func setCellTintColor(color: UIColor) {
        cellcontainer.layer.borderColor = color.CGColor
        txtTweet.tintColor = color
        lblName.tintColor = color
        lblScreenName.tintColor = color
        iv.backgroundColor = color
        
    }
    
    func adjustHeight() {
        txtTweet.sizeToFit()
    }


}
