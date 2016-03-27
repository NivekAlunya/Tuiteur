//
//  UIPickerDataSourceAccounts.swift
//  Tuiteur
//
//  Created by Kevin Launay on 3/26/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import UIKit
import Accounts

class UIPickerViewDataSourceAccounts: NSObject, UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //return self.accounts.count
        return TwitterConnection.instance.accounts?.count ?? 0
    }

}
