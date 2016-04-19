//
//  RegisterViewController.swift
//  HiddenGems
//
//  Created by Bryan Posso on 3/9/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var repeatPassword: UITextField!
    
    @IBOutlet weak var registerBox: UIView!
    
    @IBOutlet weak var phone: UITextField!
    
    @IBOutlet weak var countryCode: UITextField!
    
    @IBOutlet weak var checkpp: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerBox.layer.cornerRadius = 10;
        
        //Remove keyboard on touch
        self.hideKeyboardWhenTappedAround()
      
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func registerButton(sender: UIButton) {
        //Swift 2:
        //postCreateUser()
        createUser()
        
        self.username.text = ""
        self.password.text = ""
        self.email.text = ""
        self.phone.text = ""
        self.countryCode.text = ""
        self.checkpp.text = ""
        
    }
    
    func createUser(){
        let attemptUrl = NSURL(string:"http://54.152.30.2/hg/cuser")
        
        if let url = attemptUrl{
            //prepare data for post request
            let postParams = ["username": self.username.text, "password": self.password.text, "email": self.email.text, "country_code" : self.countryCode.text, "phone_number" : self.phone.text] as Dictionary<String, String>
            
            //create a request instance
            let request = NSMutableURLRequest(URL: url)
            //set the request method to be a post method
            request.HTTPMethod = "POST"
            request.setValue("application/json; charset=utf8", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions(), error: nil)
            
            
            //create a session
            let session = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                let status_code = (response as NSHTTPURLResponse).statusCode
                
                if status_code == 200{
                    print("New user created!")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.performSegueWithIdentifier("goToLogin", sender: nil)
                    })
                }
                else{
                    print("ERROR")
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        let alert = UIAlertController(title: "User Exist", message: "Please choose another username.", preferredStyle: .Alert)
                        
                        let agree = UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
                        })
                        
                        alert.addAction(agree)
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    })
                

                }
            })
            session.resume()
        }
    }
    
    
    
    /*Swift 2:
    //POST Create User
    
    func postCreateUser(){
    
    let url = NSURL(string:"http://54.152.30.2/hg/createuser")!
    let session = NSURLSession.sharedSession()
    let postParams = ["username":self.username.text!, "password":self.password.text!, "email":self.email.text!] as Dictionary<String, String>
    
    let request = NSMutableURLRequest(URL: url)
    request.HTTPMethod = "POST"
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    
    do {
    request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
    print(postParams)
    
    }catch{
    print("JSON serialization failed")
    }
    
    session.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
    guard let realResponse = response as? NSHTTPURLResponse where
    realResponse.statusCode == 200 else {
    print("Not a 200 response")
    print(data)
    print(response)
    print(error)
    return
    
    }
    
    if let postString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String {
    
    
    print("POST:" + postString)
    self.performSelectorOnMainThread("updatePostLabel:", withObject: postString, waitUntilDone: false)
    }
    }).resume()
    
    }
    */
    
    
    func updatePostLabel(text: String) {
        print("POST : " + "Successful")
    }
    
    
    
    
    
}
