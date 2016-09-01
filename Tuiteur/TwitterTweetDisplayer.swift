//
//  TwitterTweetDecorator.swift
//  Tuiteur
//
//  Created by Kevin Launay on 6/7/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

class TwitterTweetDisplayer {
    
    static let width = CGFloat(285)
    static let imageHeight = CGFloat(48.0)
    
    static let textLayout = NSLayoutManager()
    static let textStorage = NSTextStorage()
    static var textContainer = NSTextContainer()
    static var initialized = false
    static func initTextObject() {
        textContainer = NSTextContainer(size: CGSizeMake(width, CGFloat.max))
        textLayout.addTextContainer(textContainer)
        textStorage.addLayoutManager(textLayout)
        initialized = true
    }
    
    static func getHeightForCell(tweet: TwitterTweet) -> CGFloat {
        if !initialized {
            initTextObject()
        }
        
        guard let attributedString = tweet.attributedString else {
            return CGFloat(0)
        }
        
        textStorage.setAttributedString(attributedString)
        
        print(textLayout.usedRectForTextContainer(textContainer).height)
        
        return 12.0 + imageHeight + textLayout.usedRectForTextContainer(textContainer).height + 16 ?? CGFloat(200)
    }
    
    static func getAttributedString(tweet: TwitterTweet) -> NSMutableAttributedString {
        var attributedString: NSMutableAttributedString?

        if let txt = tweet["text"] as? String
        {

            let ps = NSMutableParagraphStyle()
            ps.alignment = .Left
            ps.paragraphSpacing = 2
            let body = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            let font = txt.characters.count > 50 ? (txt.characters.count > 100 ? body.fontWithSize(body.pointSize - 2.0) : body) : body.fontWithSize(body.pointSize + 2.0)
            
            attributedString = NSMutableAttributedString(string: txt, attributes: [NSParagraphStyleAttributeName: ps, NSFontAttributeName: font])
            
            buildLinksForAttributeString(tweet, attributedString: attributedString!)
            buildImagesForAttributeString(tweet, attributedString: attributedString!)
            buildUserMentionsForAttributeString(tweet, attributedString: attributedString!)
            buildHashtagsForAttributeString(tweet, attributedString: attributedString!)
            
            //attributedString!.appendAttributedString(NSAttributedString(string: "\n\(id)"))
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