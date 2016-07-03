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
    @IBOutlet var backgroundHeader: UIView!
    let secondFor1Day = 3600 * 24

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
        let font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        txtTweet.font = font
        iv.layer.masksToBounds = true
        iv.layer.cornerRadius = 6.0
        iv.layer.borderWidth = 1.0
        iv.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    func setImageProfil(image: UIImage?) {
        iv.image = image
        adjustHeight()
    }
    
    func setText(name: String, screenName: String, date: String, text: NSAttributedString, user: TwitterUser? = nil, account: TwitterAccount? = nil) {
        lblName.text = name
        lblScreenName.text = "@\(screenName)"

        if let localDate = formatter.dateFromString(date) {
            //let offset = user?["utc_offset"] as? Double ?? 0.0
            let dtDiff = abs(Int(localDate.timeIntervalSinceNow))
            if dtDiff < secondFor1Day {
                if dtDiff < 60 {
                    let secondes = Int(ceil(Double(dtDiff)))
                    lblDate.text = "\(secondes == 0 ? 1 : secondes)s ago"
                } else if dtDiff < 3600 {
                    let minutes = Int(ceil(Double(dtDiff / 60)))
                    let plural = minutes > 1 ? "s" : ""
                    lblDate.text = "\(minutes) minute\(plural) ago"
                } else {
                    let hours = Int(ceil(Double(dtDiff / 3600)))
                    let plural = hours > 1 ? "s" : ""
                    lblDate.text = "\(hours) hour\(plural) ago"
                }
            } else {
                print(account?.json)

                let dt = localDate //NSDate(timeInterval: offset, sinceDate: localDate)
                let format = NSDateFormatter()
                format.locale = NSLocale.currentLocale()
                format.dateStyle = NSDateFormatterStyle.ShortStyle
                format.timeStyle = NSDateFormatterStyle.ShortStyle

                let sDate = "\(format.stringFromDate(dt))"
                lblDate.text = sDate
            }
        } else {
            lblDate.text = date
        }
        
        txtTweet.attributedText = text
        adjustHeight()
        contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, txtTweet.frame.size.height + iv.frame.size.height)
    }
    
    func setCellTintColor(color: UIColor, user: TwitterUser? = nil) {
        cellcontainer.layer.borderColor = color.CGColor
        txtTweet.tintColor = color
        lblName.tintColor = color
        lblScreenName.tintColor = color
        backgroundHeader.backgroundColor = color
        let userTextColor = user?.profile_text_color ?? UIColor.whiteColor()
        iv.layer.borderColor = userTextColor.CGColor
        iv.backgroundColor = userTextColor
//        let colorSuggested = color.approach(userTextColor, withTolerance: 0.20)
//        let textColor = colorSuggested.barely ? colorSuggested.suggestColor : userTextColor
        lblName.textColor = userTextColor
        lblScreenName.textColor = userTextColor
        lblDate.textColor = userTextColor
    }
    
    func adjustHeight() {
        txtTweet.sizeToFit()
    }
    
}
