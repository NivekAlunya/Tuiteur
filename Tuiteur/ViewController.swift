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
    
    @IBOutlet var txtAccount: UITextField!
    
    @IBAction func btnRequestAccount(sender: UIButton) {
        TwitterConnection.instance.requestAccess()
        
    }
    
    @IBAction func btnRequestAccountInformation(sender: UIButton) {
        
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
    
    private func registerEvents() {
        self.observers.append(
            NSNotificationCenter.defaultCenter().addObserverForName(TwitterConnection.Events.Error.rawValue, object: TwitterConnection.instance, queue: nil) { (notification) in
                
            }
        )
        
        self.observers.append(
            NSNotificationCenter.defaultCenter().addObserverForName(TwitterConnection.Events.Granted.rawValue, object: TwitterConnection.instance, queue: nil) { (notification) in
                
                print(TwitterConnection.Events.Granted.rawValue)
                TwitterStore.instance.getTwitterAccounts()
            }
        )

        self.observers.append(
            NSNotificationCenter.defaultCenter().addObserverForName(TwitterStore.Events.TwitterAccountRetrieved.rawValue, object: TwitterStore.instance, queue: nil) { (notification) in
                print(TwitterStore.Events.TwitterAccountRetrieved.rawValue)
                print(notification.userInfo!["key"])
            }
        )

        self.observers.append(
            NSNotificationCenter.defaultCenter().addObserverForName(TwitterStore.Events.TwitterAccountRefreshed.rawValue, object: TwitterStore.instance, queue: nil) { (notification) in
                
                print(TwitterStore.Events.TwitterAccountRefreshed.rawValue)
                print(notification.userInfo!["key"])
            }

        )

        self.observers.append(
            NSNotificationCenter.defaultCenter().addObserverForName(TwitterConnection.Events.NotGranted.rawValue, object: TwitterConnection.instance, queue: nil) { (notification) in
            }
        )
    }

    //ACTIONS
    
    func donePickerAccounts(sender: UIBarButtonItem) {
        TwitterConnection.instance.selectedAccountIndex = pkrAccounts.selectedRowInComponent(0)
        txtAccount.text = TwitterConnection.instance.account?.userFullName
        txtAccount.resignFirstResponder()
    }

    func cancelPickerAccounts(sender: UIBarButtonItem) {
        txtAccount.resignFirstResponder()
    }
    
    //DELEGATES
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        return TwitterConnection.instance.accounts![row].userFullName
    }

}

