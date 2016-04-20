//
//  ViewController.swift
//  HiddenGems
//
//  Created by Melissa Rojas on 2/23/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit
import CoreData

// Function to remove keyboard on touch
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

var logged_user: String!
var logged_user_id: Int!
var user_data = [String: AnyObject]()

class ViewController: UIViewController {
    
    @IBOutlet weak var CreateAccount: UIButton!
    
    @IBOutlet weak var logInBox: UIView!
    
    @IBOutlet var username: UITextField!
    
    @IBOutlet weak var password: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "HiddenGemsBackground.png")
        self.view.insertSubview(backgroundImage, atIndex: 0)
        self.logInBox.layer.cornerRadius = 10
        self.logInBox.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
        
        self.hideKeyboardWhenTappedAround()
        
        //refers to AppDelegate
        let appDel: AppDelegate =  UIApplication.sharedApplication().delegate as AppDelegate
        
        //allows to access coredata database
        let context: NSManagedObjectContext = appDel.managedObjectContext!
        
        //create a request that allows us to get data from users entity
        let request = NSFetchRequest(entityName: "USER")
        
        let results = context.executeFetchRequest(request, error:nil)
        
        if results?.count > 0 {
            
            for result in results as [NSManagedObject]{
                logged_user = result.valueForKey("username") as String
                logged_user_id = result.valueForKey("id") as Int
                
                user_data["username"] = result.valueForKey("username") as? String
                user_data["country_code"] = result.valueForKey("country_code") as? String
                user_data["phone_number"] = result.valueForKey("phone_number") as? String
                user_data["id"] = result.valueForKey("id") as? String
                user_data["email"] = result.valueForKey("email") as? String
                user_data["password"] = result.valueForKey("password") as? String
            }
            let attemptUrl = NSURL(string:"http://54.152.30.2/hg/login")
            
            if let url = attemptUrl{
                
                let postParams = ["username": user_data["username"] as String, "password": user_data["password"] as String] as Dictionary<String, String>
                print(postParams)
                let request = NSMutableURLRequest(URL: url)
                request.HTTPMethod = "POST"
                request.setValue("application/json; charset=utf8", forHTTPHeaderField: "Content-Type")
                request.HTTPBody = NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions(), error: nil)
                
                let session = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                    let status_code = (response as NSHTTPURLResponse).statusCode
                    if status_code == 200 {
                        print("success logged \(user_data) \n")
                    }
                    else{
                        print("unsuccess login attempt \n")
                    }
                })
                session.resume()
                
            }
            
            
            //if there is a user in db change view to explore
            self.performSegueWithIdentifier("LoginToExplore", sender: nil)
        }
        
    }

    
    @IBAction func login(sender: AnyObject) {
        
        if username.text.isEmpty{
            print("blank username!")
            let alert = UIAlertController(title: "Login error", message: "Please enter a username.", preferredStyle: .Alert)
            
            let agree = UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
            })
            
            alert.addAction(agree)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else if password.text.isEmpty{
            print("blank password!")
            let alert = UIAlertController(title: "Login error", message: "Please enter a password.", preferredStyle: .Alert)
            
            let agree = UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
            })
            
            alert.addAction(agree)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else{
            let attemptUrl = NSURL(string:"http://54.152.30.2/hg/login")
            
            if let url = attemptUrl{
                
                //prepare data for post request
                let postParams = ["username": username.text, "password": password.text] as Dictionary<String, String>
                
                let userPassword = password.text
                
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
                        
                        //force queue to come to a close so when can perfom the segue
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            let jsondata = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                            
                            //save json data in local storage
                            
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
                                user_data["username"] = jsondata["username"]// as? String
                                
                                //3. set value for password
                                user.setValue(userPassword, forKey: "password")
                                user_data["password"] = userPassword
                                
                                //4. set value for email
                                user.setValue(jsondata["email"], forKey: "email")
                                user_data["email"] = jsondata["email"]// as? String
                                
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
                                print(logged_user_id)
                            }
                            
                            if results?.count > 0 {
                                print("there is results!: \n")
                                for result in results as [NSManagedObject]{
                                    print(result.valueForKey("username"))
                                    print("\n")
                                }
                            }
                            
                            self.performSegueWithIdentifier("LoginToExplore", sender: nil)
                            
                        })
                    }
                    else{
                        //force queue to come to a close
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            let alert = UIAlertController(title: "Login error", message: "Invalid password/username. Please try again.", preferredStyle: .Alert)
                            
                            let agree = UIAlertAction(title: "OK", style: .Default, handler: { (action:UIAlertAction!) -> Void in
                            })
                            
                            alert.addAction(agree)
                            self.presentViewController(alert, animated: true, completion: nil)
                            
                        })
                    }
                })
                session.resume()
                
                username.text = ""
                password.text = ""
            }
        }
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    @IBAction func unwindAction(sender: UIStoryboardSegue){
        
        self.username.text = ""
        self.password.text = ""
        
    }
    
    
    //Show NavigationBar
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    


}

