//
//  ViewController.swift
//  Tuiteur
//
//  Created by Kevin Launay on 3/24/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate {
    
    @IBOutlet var txtAccount: UITextField!
    let pkrAccounts = UIPickerView()
    private var observers = [AnyObject]()
    private let pkrDataSource = UIPickerViewDataSourceAccounts()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        txtAccount.inputView = pkrAccounts
        pkrAccounts.delegate = self
        self.pkrAccounts.dataSource = self.pkrDataSource
        registerEvents();
    }
    
    deinit {
        unregisterEvents()
    }
    
    private func unregisterEvents() {
        for observer in observers {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
    
    private func registerEvents() {
        self.observers.append(
            NSNotificationCenter.defaultCenter().addObserverForName(TwitterConnection.Events.Error.rawValue, object: TwitterConnection.instance, queue: nil) { (notification) in
                print(notification.userInfo)
            }
        )
        self.observers.append(
            NSNotificationCenter.defaultCenter().addObserverForName(TwitterConnection.Events.Granted.rawValue, object: TwitterConnection.instance, queue: nil) { (notification) in
                print(TwitterConnection.Events.Granted.rawValue)
                
                guard let accs = TwitterConnection.instance.accounts where accs.count > 0 else {
                    return
                }
                
            }
        )
        self.observers.append(
            NSNotificationCenter.defaultCenter().addObserverForName(TwitterConnection.Events.NotGranted.rawValue, object: TwitterConnection.instance, queue: nil) { (notification) in
                print(TwitterConnection.Events.NotGranted.rawValue)
            }
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnRequestAccount(sender: UIButton) {
        TwitterConnection.instance.requestAccess()
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print(TwitterConnection.instance.accounts![row].userFullName)
        return TwitterConnection.instance.accounts![row].userFullName
    }

}

