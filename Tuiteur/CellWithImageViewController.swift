//
//  CellWithImageViewController.swift
//  Tuiteur
//
//  Created by Kevin Launay on 7/19/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import UIKit

class CellWithImageViewController: UIViewController {

    @IBOutlet var images: [UIImageView]!
    @IBOutlet var txtWidth: NSLayoutConstraint!
    @IBOutlet var stackPortrait: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        stackPortrait.hidden = true
        print(images.count)
        for i in 1..<images.count {
            images[i].hidden = true
        }
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

}
