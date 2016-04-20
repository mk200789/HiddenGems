//
//  RegisterViewController.swift
//  HiddenGems
//
//  Created by Bryan Posso on 3/9/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit
import CoreData

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var repeatPassword: UITextField!
    
    @IBOutlet weak var registerBox: UIView!
    
    @IBOutlet weak var phone: UITextField!
    
    @IBOutlet weak var countryCode: UITextField!
    
    
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
        
        if (self.username.text.isEmpty || self.password.text.isEmpty || self.repeatPassword.text.isEmpty || self.countryCode.text.isEmpty || self.phone.text.isEmpty){
            
            let alert = UIAlertController(title: "Empty Fields", message: "Please make sure all fields are filled.", preferredStyle: .Alert)
            
            let agree = UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
            })
            
            alert.addAction(agree)
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        else{
            if (self.password.text != self.repeatPassword.text){
                let alert = UIAlertController(title: nil ,message: "Password mismatched. Please enter again.", preferredStyle: .Alert)
                
                let agree = UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
                })
                
                alert.addAction(agree)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else{
                createUser()
                self.username.text = ""
                self.password.text = ""
                self.email.text = ""
                self.phone.text = ""
                self.countryCode.text = ""
                self.repeatPassword.text = ""
            }

        }
        
    }
    
    func createUser(){
        let attemptUrl = NSURL(string:"http://54.152.30.2/hg/cuser")
        
        if let url = attemptUrl{
            //prepare data for post request
            let postParams = ["username": self.username.text, "password": self.password.text, "email": self.email.text, "country_code" : self.countryCode.text, "phone_number" : self.phone.text] as Dictionary<String, String>
            
            let userPassword = self.password.text
            
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
                        
                        let jsondata = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                        
                        //refers to AppDelegate
                        let appDel: AppDelegate =  UIApplication.sharedApplication().delegate as AppDelegate
                        
                        //allows to access coredata database
                        let context: NSManagedObjectContext = appDel.managedObjectContext!
                        
                        //create a request that allows us to get data from users entity
                        let request = NSFetchRequest(entityName: "USER")
                        let results = context.executeFetchRequest(request, error:nil)
                        
                        if results?.count == 0 {
                            print("adding user to db")
                            //1.specify which entity your going to use
                            let user = NSEntityDescription.insertNewObjectForEntityForName("USER", inManagedObjectContext: context) as NSManagedObject
                            
                            //2.set the value for username
                            user.setValue(jsondata["username"], forKey: "username")
                            user_data["username"] = jsondata["username"]
                            
                            //3. set value for password
                            user.setValue(userPassword, forKey: "password")
                            user_data["password"] = userPassword
                            
                            //4. set value for email
                            user.setValue(jsondata["email"], forKey: "email")
                            user_data["email"] = jsondata["email"]
                            
                            //5. set value for user_id
                            user.setValue(jsondata["user_id"], forKey: "id")
                            user_data["id"] = jsondata["user_id"]// as? String
                            
                            //6. set value for user_id
                            user.setValue(jsondata["phone_number"], forKey: "phone_number")
                            user_data["phone_number"] = jsondata["phone_number"]// as? String
                            
                            //7. set value for user_id
                            user.setValue(jsondata["country_code"], forKey: "country_code")
                            user_data["country_code"] = jsondata["country_code"]// as? String
                            
                            //8. save to db
                            context.save(nil)
                            logged_user = jsondata["username"] as String
                            logged_user_id = jsondata["user_id"] as Int
                        }
                        
                        self.performSegueWithIdentifier("goToLogin", sender: nil)
                        
                    })
                }
                else{
                    
                    
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

    func updatePostLabel(text: String) {
        print("POST : " + "Successful")
    }
    
    //Show NavigationBar
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    
    
}
