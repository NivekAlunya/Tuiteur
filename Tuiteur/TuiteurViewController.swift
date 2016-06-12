//
//  TuiteurViewController.swift
//  Tuiteur
//
//  Created by Kevin Launay on 5/19/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import UIKit

class TuiteurViewController: UIViewController {

    @IBOutlet var tvFriends: UITableView!

    @IBOutlet var cvTweet: UICollectionView!
    
    enum Cells: String {
        case TweetCellSimple = "TWEET_CELL_SIMPLE"
        func getNib() -> UINib {
            switch self {
            case .TweetCellSimple:
                return UINib(nibName: "TweetCellSimple", bundle:nil)
            default:
                break
            }

        }
    }
    var lastY = CGFloat(0.0)
    var down = false
    var accelerating = false
    var velocity = 0.0
    let uirefresh = UIRefreshControl()
    var noInteractionYet = true
    var downloadingsAvatar = [String: NSIndexPath]()
    var downloadingsAvatarForTweet = [String: [NSIndexPath]]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        registerEvents()
        
        cvTweet.registerNib(Cells.TweetCellSimple.getNib(), forCellWithReuseIdentifier: Cells.TweetCellSimple.rawValue)
        cvTweet.reloadData()
        uirefresh.attributedTitle = NSAttributedString(string: "REFRESH")
        uirefresh.addTarget(self, action: #selector(TuiteurViewController.refresh), forControlEvents: .ValueChanged)
        tvFriends.insertSubview(uirefresh, atIndex: 0)
        //ImageStore.instance.fic.reset()
        print(TwitterStore.instance.selectedAccount?.friends.count)
        var counter = 0
        for i in TwitterStore.instance.selectedAccount?.timeline ?? [] {
            let tweet = TwitterStore.instance.twitterTweets[i]
            if tweet?.height == 0 {
                if counter > 20 {
                    break
                }
                TwitterStore.instance.twitterTweets[i]?.attributedString = TwitterTweetDisplayer.getAttributedString(tweet!)
                let height = TwitterTweetDisplayer.getHeightForCell(tweet!)
                TwitterStore.instance.twitterTweets[i]?.height = height
                print("HEIGHT => \(TwitterStore.instance.twitterTweets[i]?.height ?? 0)")
                
                counter += 1
            }
        }
        let layout = PaperLayout()
        cvTweet.collectionViewLayout = layout
        
//        cvTweet.collectionViewLayout.invalidateLayout()
        cvTweet.reloadData()
    }
    
    func refresh() {
        requestAccountFriends()
        
//        let dt = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 10))
//        
//        dispatch_after(dt, dispatch_get_main_queue()) { 
//            self.uirefresh.endRefreshing()
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    private var observers = [AnyObject]()
    
    //LIFE CYCLE
    
    deinit {
        unregisterEvents()
    }

    private func registerEvents() {
        self.observers.append(
            NSNotificationCenter.defaultCenter().addObserverForName(TwitterConnection.Events.Error.rawValue, object: TwitterConnection.instance, queue: nil) { (notification) in
                dispatch_async(dispatch_get_main_queue(), {
                    print(TwitterConnection.Events.Error.rawValue)
                })
            }
        )
 
        self.observers.append( NSNotificationCenter.defaultCenter().addObserverForName(ImageLoader.Events.Loaded.rawValue, object: nil, queue: nil, usingBlock: { (notification) in
            dispatch_async(dispatch_get_main_queue(), {
                guard let image = notification.userInfo?["image"] as? Image else {
                    return
                }
                
                if let index = self.downloadingsAvatar[image.identifier] {
                    self.downloadingsAvatar.removeValueForKey(image.identifier)
                    ImageStore.instance.getUIImage(image, format: ImageStore.FastImageFormat.UserAvatar, onRetrieve: { (uiimage) in
                        dispatch_async(dispatch_get_main_queue()) {
                            if let cell = self.tvFriends.cellForRowAtIndexPath(index) as? UserTableViewCell {
                                cell.photo.image = uiimage
                                cell.activity.stopAnimating()
                            }
                        }
                        
                    })
                }
                
                ImageStore.instance.getUIImage(image, format: ImageStore.FastImageFormat.TweetAvatar, onRetrieve: { (uiimage) in
                    if let indexes = self.downloadingsAvatarForTweet[image.identifier] {
                        for index in indexes {
                            dispatch_async(dispatch_get_main_queue()) {
                                if let tc = self.cvTweet.cellForItemAtIndexPath(index) as? TweetCellSimple {
                                    tc.setImageProfil(uiimage)
                                    //tc.adjustHeight()
                                }
                            }
                        }
                    }
                })
            })
        }))
        
        self.observers.append(
            NSNotificationCenter.defaultCenter().addObserverForName(TwitterStore.Events.TwitterAccountFriendRetrieved.rawValue, object: TwitterStore.instance, queue: nil) { (notification) in
                guard let sn = notification.userInfo!["key"] as? String, user = TwitterStore.instance.twitterAccounts[sn] else {
                    return
                }
                
                if TwitterStore.instance.selectedAccount == user {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.refreshFriends()
                    })
                }
            }
        )
    }
    
    private func refreshFriends() {
        self.uirefresh.endRefreshing()
        self.tvFriends.reloadData()
        self.loadImagesForVisibleCells()
    }

    private func unregisterEvents() {
        for observer in observers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    func requestAccountFriends() {
        guard let selectAccount = TwitterConnection.instance.selectedAccount
            , account = TwitterStore.instance.twitterAccounts[selectAccount] else {
                return
        }
        TwitterStore.instance.getTwitterFriends(account)
    }
    
    private func loadImagesForVisibleCells() {
        if let visibleCells = self.tvFriends.indexPathsForVisibleRows {
            var visibleKeys = [String: (NSIndexPath, String)]()

            if let friends = TwitterStore.instance.selectedAccount?.friends {
                
                visibleCells.forEach({ (indexPath) in
                    if let profil = TwitterStore.instance.twitterUsers[friends[indexPath.item]]?.urlImageProfil {
                        visibleKeys[profil.md5()] = (indexPath, profil)
                    }
                })
                
                let downloadings = Array(ImageStore.instance.pendings.downloadings.keys)
                let setVisibleKeys = Set(Array(visibleKeys.keys))
                
                downloadings.forEach({ (key) in
                    if !setVisibleKeys.contains(key) {
                        if let k = TwitterStore.instance.twitterUsersByProfil[key], user = TwitterStore.instance.twitterUsers[k] {
                            print("canceling " + (user["screen_name"] as? String ?? "..."))
                        }
                        ImageStore.instance.abort(key)
                        ImageStore.instance.pendings.downloadings.removeValueForKey(key)?.cancel()
                    }
                })
                
                let setToDownload = setVisibleKeys.exclusiveOr(Set(downloadings))
                
                print(setToDownload)
                
                setToDownload.forEach({ (key) in
                    if let (index, profil) = visibleKeys[key] {
                        if let k = TwitterStore.instance.twitterUsersByProfil[profil.md5()], user = TwitterStore.instance.twitterUsers[k] {
                            print("downloading " + (user["screen_name"] as? String ?? "..."))
                        }
                        getImageProfilForCell(profil, indexPath: index)
                    }
                })

            }
            
            
        }
    }
}

extension TuiteurViewController: UITableViewDataSource {
    
    enum CELLS: String {
        case USER_CELL = "USER_CELL"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TwitterStore.instance.selectedAccount?.friends.count ?? 0
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CELLS.USER_CELL.rawValue, forIndexPath: indexPath) as?UserTableViewCell ?? UserTableViewCell()
        
        cell.photo.image = nil
        cell.username.text = ""
        
        if let friends = TwitterStore.instance.selectedAccount?.friends {
            if let user = TwitterStore.instance.twitterUsers[friends[indexPath.item]], profil = user.urlImageProfil, username = user["screen_name"] as? String {

                cell.photo.backgroundColor = user.profile_background_color
                cell.username.backgroundColor = user.profile_background_color
                cell.photo.layer.borderColor = user.profile_sidebar_border_color?.CGColor
//                cell.effect.backgroundColor = user.profile_background_color
//                cell.effect.alpha = 0.75
                cell.username.textColor = user.profile_text_color
                
                cell.username.text = username
                if tableView.decelerating || tableView.dragging || noInteractionYet {
                    cell.activity.startAnimating()
                    getImageProfilForCell(profil, indexPath: indexPath)
                } else {
                    cell.activity.stopAnimating()
                    print("skip \(username).....................    ")
                }

            }
        }
        return cell
    }

    func getImageProfilForCell(profil: String, indexPath: NSIndexPath) {
        if let image = ImageStore.instance.getImage(profil) {
            if image.state == Image.State.Loaded {
                
                ImageStore.instance.getUIImage(image, format: ImageStore.FastImageFormat.UserAvatar, onRetrieve: { (uiimage) in
                    dispatch_async(dispatch_get_main_queue(), {
                        if let c = self.tvFriends.cellForRowAtIndexPath(indexPath) as? UserTableViewCell {
                            c.photo.image = uiimage
                            c.activity.stopAnimating()
                        }
                    })
                })
                
            }
        }
        downloadingsAvatar[profil.md5()] = indexPath
    }
    
//    @available(iOS 2.0, *)
//    optional public func numberOfSectionsInTableView(tableView: UITableView) -> Int // Default is 1 if not implemented
//    
//    @available(iOS 2.0, *)
//    optional public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? // fixed font style. use custom view (UILabel) if you want something different
//    @available(iOS 2.0, *)
//    optional public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String?
//    
//    // Editing
//    
//    // Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
//    @available(iOS 2.0, *)
//    optional public func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
//    
//    // Moving/reordering
//    
//    // Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
//    @available(iOS 2.0, *)
//    optional public func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool
//    
//    // Index
//    
//    @available(iOS 2.0, *)
//    optional public func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? // return list of section titles to display in section index view (e.g. "ABCD...Z#")
//    @available(iOS 2.0, *)
//    optional public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int // tell table which section corresponds to section title/index (e.g. "B",1))
//    
//    // Data manipulation - insert and delete support
//    
//    // After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
//    // Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
//    @available(iOS 2.0, *)
//    optional public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
//    
//    // Data manipulation - reorder / moving support
//    @available(iOS 2.0, *)
//    optional public func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
    
}

extension TuiteurViewController: UITableViewDelegate {
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        ImageStore.instance.resume()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        down = scrollView.contentOffset.y > lastY ? true : false
        lastY = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        //loadImagesForVisibleCells()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        noInteractionYet = false
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForVisibleCells()
        } else {
            ImageStore.instance.pause()
        }
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print(velocity)
        self.velocity = Double(velocity.y)
        accelerating = self.velocity != 0 ? true : false
        print(accelerating)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let t = CGAffineTransformMakeRotation((45 * (down ? 1 : -1)).degreesToRadians)
        let t1 = CGAffineTransformMakeScale(0.1, 0.1)
        let t2 = CGAffineTransformMakeTranslation(-48.0, 48.0)
        cell.transform = CGAffineTransformConcat(CGAffineTransformConcat(t1, t), t2)
        cell.alpha = 0.25
        UIView.animateWithDuration(fabs(self.velocity) < 1.0 ? 0.25 : 0.5 / self.velocity  , animations: {
            cell.alpha = 1.0
            cell.layer.transform = CATransform3DIdentity
        }) { (complete) in
            
            }
    }

}

extension TuiteurViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = TwitterStore.instance.selectedAccount?.timeline.count ?? 0
        return count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Cells.TweetCellSimple.rawValue, forIndexPath: indexPath) as! TweetCellSimple
        
        let emptyAS = NSAttributedString(string: "")

        cell.setText("", screenName: "", date: "", text: emptyAS)
        cell.setImageProfil(nil)
        
        guard let account = TwitterStore.instance.selectedAccount else {
            return cell
        }
        
        let id = account.timeline[indexPath.item]
        //let id = 740328080456056832
        if let tweet = TwitterStore.instance.twitterTweets[id], user = TwitterStore.instance.twitterUsers[tweet.userid!] {
            if collectionView.decelerating || collectionView.dragging || noInteractionYet {
                var tintColor: UIColor
                getImageProfilForTweetCell(user.urlImageProfil!, indexPath: indexPath)

                cell.setText(user["name"] as? String ?? "?", screenName: user["screen_name"] as? String ?? "?", date: tweet["created_at"] as? String ?? "" ,  text: tweet.attributedString ?? emptyAS, user: user)
                if let color = user.profile_background_color?.approach(UIColor.whiteColor(), withTolerance: 0.2) {
                    tintColor = color.barely ? color.suggestColor : (user.profile_background_color ?? UIColor.blackColor())
                } else {
                    tintColor = UIColor.blackColor()
                }
                cell.setCellTintColor(tintColor)
            }
        }
        
        return cell
    }

    func getImageProfilForTweetCell(profil: String, indexPath: NSIndexPath) {
        if let image = ImageStore.instance.getImage(profil) {
            if image.state == Image.State.Loaded {
                ImageStore.instance.getUIImage(image, format: ImageStore.FastImageFormat.TweetAvatar, onRetrieve: { (uiimage) in
                    dispatch_async(dispatch_get_main_queue(), {
                        if let tc = self.cvTweet.cellForItemAtIndexPath(indexPath) as? TweetCellSimple {
                            tc.setImageProfil(uiimage)
                        }
                    })
                })
            }
        }
        let identifier = profil.md5()
        if downloadingsAvatarForTweet[identifier] == nil {
            downloadingsAvatarForTweet[identifier] = [NSIndexPath]()
        }
        if  let indexes = downloadingsAvatarForTweet[identifier] {
            if !indexes.contains(indexPath) {
                downloadingsAvatarForTweet[identifier]?.append(indexPath)
            }
        }
    }
    
//    @available(iOS 6.0, *)
//    optional public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
//    
//    // The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
//    @available(iOS 6.0, *)
//    optional public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
//    
//    @available(iOS 9.0, *)
//    optional public func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool
//    @available(iOS 9.0, *)
//    optional public func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)

}

extension TuiteurViewController: PaperLayoutDelegate {
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, itemInsetsForSectionAtIndex: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(20, 10, 30, 10)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let defaultSize = CGSizeMake(300, 200)
        guard let account = TwitterStore.instance.selectedAccount else {
            return defaultSize
        }
        
        let id = account.timeline[indexPath.item]
        //let id = 740328080456056832
        if let tweet = TwitterStore.instance.twitterTweets[id] {
            return CGSizeMake(defaultSize.width, tweet.height)
        }
        
        return defaultSize
        
    }

}