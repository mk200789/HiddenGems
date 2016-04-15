//
//  MyAccountViewController.swift
//  HiddenGems
//
//  Created by Melissa Rojas on 3/31/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit

class MyAccountViewController: UIViewController {

    @IBOutlet weak var updateBox: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateBox.layer.cornerRadius = 10
        
        //Remove keyboard on touch
        self.hideKeyboardWhenTappedAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Show NavigationBar.
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    
    @IBAction func update(sender: AnyObject) {
        
        print("Completed Updates!")
        self.performSegueWithIdentifier("toExplore", sender: nil)
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
