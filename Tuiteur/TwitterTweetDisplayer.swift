//
//  TwitterTweetDecorator.swift
//  Tuiteur
//
//  Created by Kevin Launay on 6/7/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

class TwitterTweetDisplayer {
    
    static let tv = UITextView()
    static let width = CGFloat(300)
    static let imageHeight = CGFloat(64.0)
    
    static func getHeightForCell(tweet: TwitterTweet) -> CGFloat {
        guard let attributedString = tweet.attributedString else {
            return CGFloat(0)
        }
        
        tv.frame = CGRectMake(0, 0, width, CGFloat.max)
        
        tv.attributedText = attributedString
        tv.sizeToFit()

        return 6.0 + 48.0 + tv.frame.size.height ?? CGFloat(0)
    }
    
    static func getAttributedString(tweet: TwitterTweet) -> NSMutableAttributedString {
        var attributedString: NSMutableAttributedString?
        let id = tweet["id"]
        print("-----------------------------------------\nTWEET \(id)\n--------------------------------------")
        if let txt = tweet["text"] as? String
        {
//            print(tweet.json)
//            print(txt)
            let ps = NSMutableParagraphStyle()
            ps.alignment = .Left
            ps.paragraphSpacing = 2
            
            attributedString = NSMutableAttributedString(string: txt, attributes: [NSParagraphStyleAttributeName: ps, NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)])
            
            buildLinksForAttributeString(tweet, attributedString: attributedString!)
            buildImagesForAttributeString(tweet, attributedString: attributedString!)
            buildUserMentionsForAttributeString(tweet, attributedString: attributedString!)
            buildHashtagsForAttributeString(tweet, attributedString: attributedString!)
            
            attributedString!.appendAttributedString(NSAttributedString(string: "\n\(id)"))
        }
        
        return attributedString ?? NSMutableAttributedString(string: "")
    }
    
    private static func buildLinksForAttributeString(tweet: TwitterTweet, attributedString: NSMutableAttributedString) {
        guard let urls = tweet["entities"]?["urls"] as? [[String:AnyObject]] else {
            return
        }
        for url in urls  {
            guard let href = url["url"] as? String
                , text = tweet["text"] as? NSString
                //, indices = url["indices"] as? [Int]
                , nsurl = NSURL(string: href) else {
                    continue
            }
            let range = text.rangeOfString(nsurl.absoluteString)
            //let range = NSRange(location: indices[0], length: indices[1] - indices[0])
            attributedString.addAttribute(NSLinkAttributeName, value: nsurl, range: range)
        }
        //Put a regex to parse urls in text if no node is provided
    }
    
    private static func buildImagesForAttributeString(tweet: TwitterTweet, attributedString: NSMutableAttributedString) {
        guard let medias = tweet["entities"]?["media"] as? [[String:AnyObject]] else {
            return
        }
        for media in medias  {
            guard let href = media["url"] as? String
                , text = tweet["text"] as? NSString
                //, indices = url["indices"] as? [Int]
                , nsurl = NSURL(string: href) else {
                    continue
            }
            
            let range = text.rangeOfString(nsurl.absoluteString)
            attributedString.addAttribute(NSLinkAttributeName, value: nsurl, range: range)
        }
        //Put a regex to parse urls in text if no node is provided
    }
    
    private static func buildUserMentionsForAttributeString(tweet: TwitterTweet, attributedString: NSMutableAttributedString) {
        guard let mentions = tweet["entities"]?["user_mentions"] as? [[String:AnyObject]] else {
            return
        }
        for mention in mentions  {
            guard let screen_name = mention["screen_name"] as? String
                , text = tweet["text"] as? NSString
                //, indices = url["indices"] as? [Int]
                , nsurl = NSURL(string: "@\(screen_name)") else {
                    continue
            }
            let range = text.rangeOfString(nsurl.absoluteString)
            attributedString.addAttribute(NSLinkAttributeName, value: nsurl, range: range)
        }
    }

    private static func buildHashtagsForAttributeString(tweet: TwitterTweet, attributedString: NSMutableAttributedString) {
        guard let hashtags = tweet["entities"]?["hashtags"] as? [[String:AnyObject]] else {
            return
        }
        
        for hashtag in hashtags  {
            guard let tag = hashtag["text"] as? String
                , text = tweet["text"] as? NSString
                //, indices = url["indices"] as? [Int]
                , nsurl = NSURL(string: "#\(tag)") else {
                    continue
            }
            let range = text.rangeOfString(nsurl.absoluteString)
            attributedString.addAttribute(NSLinkAttributeName, value: nsurl, range: range)
        }
    }

    
}