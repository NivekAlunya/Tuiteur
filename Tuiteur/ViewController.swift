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
    
    @IBAction func btnRequestAccount(sender: UIButton) {
        TwitterStore.instance.getTwitterAccounts()
    }
    
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
    
    @IBAction func btnBuildImage(sender: UIButton) {
        guard let identifier = TwitterConnection.instance.selectedAccount
            , urlImageProfil = TwitterStore.instance.twitterAccounts[identifier]?.urlImageProfil
             else {
            return
        }
        
        guard let weburl = NSURL(string: urlImageProfil)
            , fileinfo = ImageDownloader.instance.getFileURLForWebURL(weburl) else {
            return
        }
        
//        myImageArea = CGRectMake(xOrigin, yOrigin, myWidth, myHeight);//newImage
//        mySubimage  = CGImageCreateWithImageInRect(oldImage, myImageArea);
//        myRect      = CGRectMake(0, 0, myWidth*2, myHeight*2);
//        CGContextDrawImage(context, myRect, mySubimage);
        
        let image = Image(identifier: fileinfo.identifier, weburl: weburl, fileurl: fileinfo.fileurl)
        image.loadImage()
        
        let rect = CGRectMake(0.0, 0.0, imgUser.frame.size.width, imgUser.frame.size.height)
        
        let sizeImage = image.img!.size ?? CGSizeZero
        
        let ratioW = sizeImage.width / rect.width
        let ratioH = sizeImage.height / rect.height
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        
        let radius = CGFloat(rect.width / 2.0)
        
        let circle = UIBezierPath(arcCenter: CGPointMake(rect.width / 2, rect.height / 2), radius: radius, startAngle: CGFloat(0.degreesToRadians), endAngle: CGFloat(360.degreesToRadians), clockwise: true)

        circle.lineWidth = CGFloat(1.0)

        circle.addClip()
        
        var area = CGRect()
        
        let ratio = ratioW > ratioH ? ratioW : ratioH
        
        area.size.height = sizeImage.height / ratio
        area.size.width = sizeImage.width / ratio
        area.origin.x = (rect.height - area.size.height) / 2
        area.origin.y = (rect.width - area.size.width) / 2
        print(area)
        
        image.img?.drawInRect(area)
        
        let thumb = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        imgUser.image = thumb

        print(imgUser.image?.size)
        
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
                print(user.timeline ?? "No timeline")
            }
        )
        
        self.observers.append(
            NSNotificationCenter.defaultCenter().addObserverForName(TwitterConnection.Events.NotGranted.rawValue, object: TwitterConnection.instance, queue: nil) { (notification) in
            }
        )
    }
    
    func selectAccount(identifier: String) {
        TwitterConnection.instance.selectedAccount = identifier
        txtAccount.text = TwitterConnection.instance.account?.userFullName
        
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

