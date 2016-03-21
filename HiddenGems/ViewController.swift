//
//  ViewController.swift
//  HiddenGems
//
//  Created by Melissa Rojas on 2/23/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    
    @IBOutlet weak var CreateAccount: UIButton!
    
    @IBOutlet weak var logInBox: UIView!
    
    @IBOutlet var username: UITextField!

    @IBOutlet weak var password: UITextField!
    
    @IBAction func login(sender: AnyObject) {

        if username.text.isEmpty{
            print("blank username!")
        }
        else if password.text.isEmpty{
            print("blank password!")
        }
        else{
            let attemptUrl = NSURL(string:"http://54.152.30.2/hg/login_user")
            
            if let url = attemptUrl{
                
                //prepare data for post request
                let postParams = ["username": username.text, "password": password.text] as Dictionary<String, String>
                
                //create a request instance
                let request = NSMutableURLRequest(URL: url)
                //set to post method
                request.HTTPMethod = "POST"
                request.setValue("application/json; charset=utf8", forHTTPHeaderField: "Content-Type")
                request.HTTPBody = NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions(), error: nil)
                
                //create session
                let session = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                    let status_code = (response as NSHTTPURLResponse).statusCode
                    
                    if status_code == 200{
                        print("User is logged in!")
                        
                        //force queue to come to a close when data is obtained and display webcontent
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.performSegueWithIdentifier("LoginToExplore", sender: nil)
                            
                        })
                    }
                    else{
                        print(status_code)
                        print("ERROR")
                    }
                })
                session.resume()
                
                username.text = ""
                password.text = ""
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "background1.png")
        self.view.insertSubview(backgroundImage, atIndex: 0)
        self.logInBox.layer.cornerRadius = 10
        self.logInBox.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

