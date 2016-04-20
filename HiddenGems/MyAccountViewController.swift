//
//  MyAccountViewController.swift
//  HiddenGems
//
//  Created by Melissa Rojas on 3/31/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit
import CoreData

class MyAccountViewController: UIViewController {


    @IBOutlet var phone: UITextField!

    @IBOutlet var email: UITextField!

    @IBOutlet var countryCode: UITextField!
    
    @IBOutlet var updateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if user_data.count > 0{
            email.placeholder = user_data["email"] as? String
            countryCode.placeholder = user_data["country_code"] as? String
            phone.placeholder = user_data["phone_number"] as? String
        }
        
        
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
        
        updateUserAccount()
        //print("Completed Updates!")
        self.performSegueWithIdentifier("toExplore", sender: nil)
    }
    
    func updateUserAccount(){

        let attemptURL = NSURL(string:"http://54.152.30.2/hg/update_user")
        
        if let url = attemptURL{
            
            let postParams = ["email": email.text, "country_code": countryCode.text, "phone_number": phone.text] as Dictionary<String, String>
            
            //create a request instance
            let request = NSMutableURLRequest(URL: url)
            //set to post method
            request.HTTPMethod = "POST"
            request.setValue("application/json; charset=utf8", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions(), error: nil)
            
            //create session
            let session = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                
                let status_code = (response as NSHTTPURLResponse).statusCode
                
                print(status_code)
                if status_code == 200 {

                    dispatch_async(dispatch_get_main_queue(),{() ->Void in
                        
                        let content = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
                        
                        //save json data in local storage
                        
                        //refers to AppDelegate
                        let appDel: AppDelegate =  UIApplication.sharedApplication().delegate as AppDelegate
                        
                        //allows to access coredata database
                        let context: NSManagedObjectContext = appDel.managedObjectContext!
                        
                        //create a request that allows us to get data from users entity
                        let request = NSFetchRequest(entityName: "USER")
                        
                        request.predicate = NSPredicate(format: "id == \(logged_user_id )")
                        
                        let results = context.executeFetchRequest(request, error:nil)
                        
                        if results?.count > 0{
                            //update user info
                            for result in results as [NSManagedObject]{
                                result.setValue(content["email"], forKey: "email")
                                user_data["email"] = content["email"]
                                
                                
                                result.setValue(content["phone_number"], forKey: "phone_number")
                                user_data["phone_number"] = content["phone_number"]
                                
                                result.setValue(content["country_code"], forKey: "country_code")
                                user_data["country_code"] = content["country_code"]
                                
                                context.save(nil)
                            }
                        }
                        
                        
                    })
                    
                    
                    
                }
                else{
                    
                
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        let alert = UIAlertController(title: "Update account error", message: "Couldn't update account. Please try again.", preferredStyle: .Alert)
                        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
