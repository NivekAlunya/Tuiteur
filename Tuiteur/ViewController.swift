//
//  ViewController.swift
//  Tuiteur
//
//  Created by Kevin Launay on 3/24/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate {

    //IB THINGS
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var txtAccount: UITextField!
    @IBOutlet var imgUserTweet: UIImageView!
    @IBOutlet var txtTweet: UITextView!
    @IBOutlet var scrollv: UIScrollView!
    
    @IBAction func btnRequestAccount(sender: UIButton) {
        TwitterStore.instance.getTwitterAccounts()
    }
    
    @IBOutlet var cellHeight: NSLayoutConstraint!
    
    @IBAction func btnRequestAccountFriends(sender: UIButton) {
        guard let selectAccount = TwitterConnection.instance.selectedAccount
            , account = TwitterStore.instance.twitterAccounts[selectAccount] else {
            return
        }
        TwitterStore.instance.getTwitterFriends(account)
    }

    @IBAction func btnRequestAccountTimeline(sender: UIButton) {
        guard let selectAccount = TwitterConnection.instance.selectedAccount
            , account = TwitterStore.instance.twitterAccounts[selectAccount] else {
                return
        }
        TwitterStore.instance.getTwitterTimeline(account)
    }

    @IBAction func btnRequestAccountTimelineNext(sender: UIButton) {
        guard let selectAccount = TwitterConnection.instance.selectedAccount
            , account = TwitterStore.instance.twitterAccounts[selectAccount] else {
                return
        }
        TwitterStore.instance.getTwitterTimeline(account, cursor: TwitterStore.Cursor.Next)
    }

    @IBAction func btnRequestAccountTimelinePrevious(sender: UIButton) {
        guard let selectAccount = TwitterConnection.instance.selectedAccount
            , account = TwitterStore.instance.twitterAccounts[selectAccount] else {
                return
        }
        TwitterStore.instance.getTwitterTimeline(account, cursor: TwitterStore.Cursor.Previous)
    }

    
    @IBAction func btnRequestImages(sender: UIButton) {
        guard let selectAccount = TwitterConnection.instance.selectedAccount
            , account = TwitterStore.instance.twitterAccounts[selectAccount]
            else {
                return
        }
        for i in 0 ... 100 {
            if let user = TwitterStore.instance.twitterUsers[account.friends[i]], profil = user.urlImageProfil {
                ImageStore.instance.getImage(profil)
            }
        }
    }

    @IBAction func btnStopRequestingImages(sender: UIButton) {
        ImageStore.instance.abort()
    }

    @IBAction func btnClearCache(sender: UIButton) {
        ImageDownloader.instance.clearCache()
    }

    @IBAction func btnClearStore(sender: UIButton) {
        TwitterStore.instance.clearStorage()
    }

    @IBAction func btnBuildImage(sender: UIButton) {
        guard let identifier = TwitterConnection.instance.selectedAccount
            , tu = TwitterStore.instance.twitterAccounts[identifier]
            , urlImageProfil = tu.urlImageProfil
             else {
            return
        }
        
        guard let weburl = NSURL(string: urlImageProfil)
            , fileinfo = ImageDownloader.instance.getFileURLForWebURL(weburl) else {
            return
        }

        let image = Image(identifier: fileinfo.identifier, weburl: weburl, fileurl: fileinfo.fileurl)

        image.loadImage()
        
        imgUser.image = getRoundImage(imgUser.frame, image: image)
        
        imgUserTweet.image = getRoundImage(imgUserTweet.frame, image: image)
        print(imgUser.bounds)
        print(imgUserTweet.bounds)
        let rect = CGRectMake(imgUserTweet.frame.origin.x, imgUserTweet.frame.origin.y, imgUserTweet.frame.width, imgUserTweet.frame.height - 16.0)
        txtTweet.contentInset = UIEdgeInsetsMake(-8, -4,-8,-4);
        
        txtTweet.textContainer.exclusionPaths = [UIBezierPath(rect: rect)]
        
        adjustHeight()
    }

    @IBAction func btnBuildTweet(sender: UIButton) {
        buildTweet()
    }

    func getRoundImage(rect: CGRect, image: Image) -> UIImage {
        
        let sizeImage = image.img!.size ?? CGSizeZero
        
        let ratioW = sizeImage.width / rect.width
        let ratioH = sizeImage.height / rect.height
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        
        let radius = CGFloat((rect.width) / 2)
        
        let circle = UIBezierPath(arcCenter: CGPointMake(rect.width / 2, rect.height / 2), radius: radius, startAngle: CGFloat(0.degreesToRadians), endAngle: CGFloat(360.degreesToRadians), clockwise: true)
        
        print(circle.bounds)

        circle.addClip()
        
        var area = CGRect()
        
        let ratio = ratioW > ratioH ? ratioW : ratioH
        
        area.size.height = sizeImage.height / ratio
        area.size.width = sizeImage.width / ratio
        area.origin.y = (rect.height - area.size.height) / 2
        area.origin.x = (rect.width - area.size.width) / 2
        
        print(area)
        
        image.img?.drawInRect(area)
        
        let thumb = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return thumb
    }
    
    func buildTweet() {
        
        guard let selectAccount = TwitterConnection.instance.selectedAccount
            , account = TwitterStore.instance.twitterAccounts[selectAccount]
            , screenName = account["screen_name"] as? String else {
                return
        }
        
        let tweets = TwitterStore.instance.getTweetsWithURL(account)
        
        if let tweet = TwitterStore.instance.twitterTweets[tweets[0]], s = tweet["text"] as? String {
            let ps = NSMutableParagraphStyle()
            ps.alignment = .Left
            ps.paragraphSpacing = 2
            
            
            let asUser = NSMutableAttributedString(string: "@\(screenName)\n", attributes: [NSParagraphStyleAttributeName: ps, NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleTitle3)])
            print(s.characters.count)
            let asTweet = NSMutableAttributedString(string: s, attributes: [NSParagraphStyleAttributeName: ps, NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)])
            getLinksForAttributeString(tweet, attstr: asTweet)
            asUser.appendAttributedString(asTweet)
            txtTweet.attributedText = asUser
        }
        
        adjustHeight()
    }
    
    func adjustHeight() {
        
        txtTweet.sizeToFit()
        
        print(txtTweet.contentSize)
        
        cellHeight.constant = CGFloat(16 + txtTweet.contentSize.height + 90)
    }
    
    func getLinksForAttributeString(tweet: TwitterTweet, attstr: NSMutableAttributedString) {
        guard let urls = tweet["entities"]?["urls"] as? [[String:AnyObject]] else {
            return
        }
        print(urls)
        for url in urls  {
            guard let href = url["url"] as? String, indices = url["indices"] as? [Int], nsurl = NSURL(string: href) else {
                continue
            }
            // substring start to indices[0] and read utf16.count
            // substring indices[Ø] to indices[1] and read utf16.count
            let startRange =  Range(attstr.string.startIndex ..< attstr.string.startIndex.advancedBy(indices[0]))
            let linkRange =  Range(attstr.string.startIndex.advancedBy(indices[0]) ..< attstr.string.startIndex.advancedBy(indices[1]))
            let start  = attstr.string.substringWithRange(startRange)
            let link  = attstr.string.substringWithRange(linkRange)
            
            print(start)
            print(link)
            print(start.utf16.count)
            print(start.utf16.count+link.utf16.count)
            attstr.addAttribute(NSLinkAttributeName, value: nsurl, range: NSRange(start.utf16.count...(start.utf16.count+link.utf16.count-1)))
        }

    }
    
    //PROPERTIES
    
    let pkrAccounts = UIPickerView()
    private var observers = [AnyObject]()
    private let pkrDataSource = UIPickerViewDataSourceAccounts()
    
    //LIFE CYCLE
    
    deinit {
        unregisterEvents()
    }
    
    //OVERRIDE METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print(self.scrollv.bounds)
        print(self.scrollv.frame)
        print(self.scrollv.contentSize)
//        self.scrollv.contentSize = CGSize(width: self.scrollv.bounds.width, height: 800)
//        print(self.scrollv.contentSize)
        let tlb = UIToolbar()
        tlb.translucent = true
        tlb.barTintColor = UIColor.blackColor()
        
        tlb.sizeToFit()
        
        
        let btnDone = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ViewController.donePickerAccounts(_:)))
        
        let btnCancel = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ViewController.cancelPickerAccounts(_:)))

        tlb.items = [btnDone, btnCancel]
        
        txtAccount.inputView = pkrAccounts
        txtAccount.inputAccessoryView = tlb
        
        pkrAccounts.backgroundColor = UIColor.whiteColor()
        
        pkrAccounts.delegate = self
        self.pkrAccounts.dataSource = self.pkrDataSource
        
        registerEvents();
        
        TwitterConnection.instance.requestAccess()
        
        print(NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory , inDomains: .UserDomainMask).first?.absoluteString)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //METHODS

    private func unregisterEvents() {
        for observer in observers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    private func setPkrAccountsDataSource() {
        self.pkrDataSource.values.removeAll()
        for (k , _) in TwitterConnection.instance.accounts {
            self.pkrDataSource.values.append(k)
        }
    }
    
    private func registerEvents() {
        self.observers.append(
            NSNotificationCenter.defaultCenter().addObserverForName(TwitterConnection.Events.Error.rawValue, object: TwitterConnection.instance, queue: nil) { (notification) in
                
            }
        )
        
        self.observers.append(
            NSNotificationCenter.defaultCenter().addObserverForName(TwitterConnection.Events.Granted.rawValue, object: TwitterConnection.instance, queue: nil) { (notification) in
                print(TwitterConnection.Events.Granted.rawValue)
                self.setPkrAccountsDataSource()
                dispatch_async(dispatch_get_main_queue(), {
                    self.selectAccount("RaymondHessel")
                })
            }
        )

        self.observers.append(
            NSNotificationCenter.defaultCenter().addObserverForName(TwitterStore.Events.TwitterAccountRetrieved.rawValue, object: TwitterStore.instance, queue: nil) { (notification) in
                
                print(TwitterStore.Events.TwitterAccountRetrieved.rawValue)
                print(notification.userInfo!["key"])
            }
        )
        
        self.observers.append(
            NSNotificationCenter.defaultCenter().addObserverForName(TwitterStore.Events.TwitterAccountFriendRetrieved.rawValue, object: TwitterStore.instance, queue: nil) { (notification) in
                
                print(TwitterStore.Events.TwitterAccountFriendRetrieved.rawValue)
                print(notification.userInfo!["key"])
                guard let sn = notification.userInfo!["key"] as? String, user = TwitterStore.instance.twitterAccounts[sn] else {
                    return
                }
                print(user.friends ?? "No friends")
            }
        )
        
        self.observers.append(
            NSNotificationCenter.defaultCenter().addObserverForName(TwitterStore.Events.TwitterAccountTimelineRetrieved.rawValue, object: TwitterStore.instance, queue: nil) { (notification) in
                
                print(TwitterStore.Events.TwitterAccountTimelineRetrieved.rawValue)
                print(notification.userInfo!["key"])
                print(notification.userInfo!["idTweets"])
                guard let sn = notification.userInfo!["key"] as? String, user = TwitterStore.instance.twitterAccounts[sn] else {
                    return
                }
//                print(user.timeline ?? "No timeline")
                
            }
        )
        
        self.observers.append(
            NSNotificationCenter.defaultCenter().addObserverForName(TwitterConnection.Events.NotGranted.rawValue, object: TwitterConnection.instance, queue: nil) { (notification) in
            }
        )
    }
    
    func selectAccount(identifier: String) {
        TwitterConnection.instance.selectedAccount = identifier

        txtAccount.text = TwitterConnection.instance.account?.userFullName ?? TwitterConnection.instance.account?.username
        
        if let urlImageProfil = TwitterStore.instance.twitterAccounts[identifier]?.urlImageProfil {
            ImageStore.instance.getImage(urlImageProfil)
        }
    }

    //ACTIONS
    
    func donePickerAccounts(sender: UIBarButtonItem) {
        if pkrAccounts.numberOfRowsInComponent(0) > 0 {
            selectAccount(pkrDataSource.values[pkrAccounts.selectedRowInComponent(0)])
        }
        txtAccount.resignFirstResponder()
    }

    func cancelPickerAccounts(sender: UIBarButtonItem) {
        txtAccount.resignFirstResponder()
    }
    
    //DELEGATES
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return pkrDataSource.values[row]
    }

}

extension ViewController: UITextViewDelegate {
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        
        return false
    }

    func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        
        return false
    }

}
