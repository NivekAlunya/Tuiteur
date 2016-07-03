//
//  TwitterTweet.swift
//  Tuiteur
//
//  Created by Kevin Launay on 3/31/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import Foundation

class TwitterTweet: TwitterObject {
    
    override init(json: AnyObject) {
        super.init(json: json)
    }
    
    var userid: Int? {
        get {
            return self["user"]?["id"] as? Int
        }
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var attributedString: NSMutableAttributedString?
    
    var urlImages = [String]()
    
}
//{
//    "created_at": "Tue Apr 12 17:27:19 +0000 2016",
//    "id": 719939969645551617,
//    "id_str": "719939969645551617",
//    "text": "LIVE on #Periscope: Smoke some #RemyOG with me. https://t.co/1H1FjyUSci",
//    "entities": {
//        "hashtags": [
//        {
//        "text": "Periscope",
//        "indices": [
//        8,
//        18
//        ]
//        },
//        {
//        "text": "RemyOG",
//        "indices": [
//        31,
//        38
//        ]
//        }
//        ],
//        "symbols": [],
//        "user_mentions": [],
//        "urls": [
//        {
//        "url": "https://t.co/1H1FjyUSci",
//        "expanded_url": "https://www.periscope.tv/w/advV9zI0NjY5ODR8MUJSSmpNd2RMUExHdxs8CbTlLcqzio0bqDNFt-fy9oKl5KdnO_sAN6fEcCU3",
//        "display_url": "periscope.tv/w/advV9zI0NjY5…",
//        "indices": [
//        48,
//        71
//        ]
//        }
//        ]
//    },
//    "truncated": false,
//    "source": "<a href=\"https://periscope.tv\" rel=\"nofollow\">Periscope</a>",
//    "in_reply_to_status_id": null,
//    "in_reply_to_status_id_str": null,
//    "in_reply_to_user_id": null,
//    "in_reply_to_user_id_str": null,
//    "in_reply_to_screen_name": null,
//    "user": {
//        "id": 399614856,
//        "id_str": "399614856",
//        "name": "Remy LaCroix",
//        "screen_name": "Remymeow",
//        "location": "",
//        "description": "greenest eyes. biggest heart. fiercest attitude. snapchat: meowremy",
//        "url": "https://t.co/nhiFYYUv1G",
//        "entities": {
//            "url": {
//                "urls": [
//                {
//                "url": "https://t.co/nhiFYYUv1G",
//                "expanded_url": "http://www.remylacroix.com",
//                "display_url": "remylacroix.com",
//                "indices": [
//                0,
//                23
//                ]
//                }
//                ]
//            },
//            "description": {
//                "urls": []
//            }
//        },
//        "protected": false,
//        "followers_count": 414697,
//        "friends_count": 257,
//        "listed_count": 1563,
//        "created_at": "Thu Oct 27 19:31:55 +0000 2011",
//        "favourites_count": 25985,
//        "utc_offset": -25200,
//        "time_zone": "Pacific Time (US & Canada)",
//        "geo_enabled": true,
//        "verified": false,
//        "statuses_count": 13677,
//        "lang": "en",
//        "contributors_enabled": false,
//        "is_translator": false,
//        "is_translation_enabled": false,
//        "profile_background_color": "C0DEED",
//        "profile_background_image_url": "http://pbs.twimg.com/profile_background_images/378800000014821826/402b1242d5b48fbc858d847eb7ef7f5c.jpeg",
//        "profile_background_image_url_https": "https://pbs.twimg.com/profile_background_images/378800000014821826/402b1242d5b48fbc858d847eb7ef7f5c.jpeg",
//        "profile_background_tile": false,
//        "profile_image_url": "http://pbs.twimg.com/profile_images/714982867395284992/x-5BohW0_normal.jpg",
//        "profile_image_url_https": "https://pbs.twimg.com/profile_images/714982867395284992/x-5BohW0_normal.jpg",
//        "profile_banner_url": "https://pbs.twimg.com/profile_banners/399614856/1460417467",
//        "profile_link_color": "ABB8C2",
//        "profile_sidebar_border_color": "FFFFFF",
//        "profile_sidebar_fill_color": "DDEEF6",
//        "profile_text_color": "333333",
//        "profile_use_background_image": false,
//        "has_extended_profile": true,
//        "default_profile": false,
//        "default_profile_image": false,
//        "following": true,
//        "follow_request_sent": false,
//        "notifications": false
//    },
//    "geo": null,
//    "coordinates": null,
//    "place": null,
//    "contributors": null,
//    "is_quote_status": false,
//    "retweet_count": 7,
//    "favorite_count": 40,
//    "favorited": false,
//    "retweeted": false,
//    "possibly_sensitive": true,
//    "possibly_sensitive_appealable": false,
//    "lang": "en"
//}