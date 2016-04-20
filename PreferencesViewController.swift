//
//  PreferencesViewController.swift
//  HiddenGems
//
//  Created by Melissa Rojas on 3/31/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit
import CoreData

class PreferencesViewController: UIViewController {
    
    @IBOutlet var toggleTags: [UISwitch]!

    @IBAction func preferenceToggle(sender: UISwitch) {

        var found = false
        
        //set user's preferences
        let attemptUrl = NSURL(string:"http://54.152.30.2/hg/setPreferences")

        
        for preference in preferenceList{
            var prefId = preference["pref_id"] as Int
            
            if sender.tag == prefId {
                //removing preference
                
                if let url = attemptUrl{
                    //prepare data for post request
                    let postParams = ["user_id": toString(logged_user_id), "pref_id": String(sender.tag), "action": "delete"] as Dictionary<String,String>
                    //create a request instance
                    let request = NSMutableURLRequest(URL: url)
                    //set to post method
                    request.HTTPMethod = "POST"
                    request.setValue("application/json; charset=utf8", forHTTPHeaderField: "Content-Type")
                    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions(), error: nil)
                    
                    //create session
                    let session = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                        let status_code = (response as NSHTTPURLResponse).statusCode
                        
                        if status_code == 200 {
                            
                            //force queue to come to a close so when can perfom the segue
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                //save json data in local storage
                                
                                //refers to AppDelegate
                                let appDel: AppDelegate =  UIApplication.sharedApplication().delegate as AppDelegate
                                
                                //allows to access coredata database
                                let context: NSManagedObjectContext = appDel.managedObjectContext!
                                
                                let request = NSFetchRequest(entityName: "PREFERENCES")
                                
                                let jsondata = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSArray
                                
                                //update preference list
                                preferenceList = jsondata as NSArray
                                
                                //add a predicate to search for pref_id
                                request.predicate = NSPredicate(format: "preference_id == \(sender.tag)")
                                
                                let results = context.executeFetchRequest(request, error:nil)
                                
                                if results?.count > 0{
                                    for result in results as [NSManagedObject]{
                                        print(result.valueForKey("preference_name"))
                                        context.deleteObject(result)
                                        context.save(nil)
                                    }
                                }
                                
                                
                            })
                        }
                    })
                    session.resume()
                    
                    
                }
                print("Bingo!")
                print("\n\n")
                found = true
                break
            }
        }
        
        if !found {
            //add preference

            
            if let url = attemptUrl{
                //prepare data for post request
                let postParams = ["user_id": toString(logged_user_id), "pref_id": String(sender.tag), "action": "add"] as Dictionary<String,String>
                //create a request instance
                let request = NSMutableURLRequest(URL: url)
                //set to post method
                request.HTTPMethod = "POST"
                request.setValue("application/json; charset=utf8", forHTTPHeaderField: "Content-Type")
                request.HTTPBody = NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions(), error: nil)
                
                //create session
                let session = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                    let status_code = (response as NSHTTPURLResponse).statusCode
                    
                    if status_code == 200 {
                        
                        //force queue to come to a close so when can perfom the segue
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            //save json data in local storage
                            
                            //refers to AppDelegate
                            let appDel: AppDelegate =  UIApplication.sharedApplication().delegate as AppDelegate
                            
                            //allows to access coredata database
                            let context: NSManagedObjectContext = appDel.managedObjectContext!
                            
                            let request = NSFetchRequest(entityName: "PREFERENCES")
                            let results = context.executeFetchRequest(request, error:nil)
                            
                            let jsondata = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSArray
                            
                            
                            preferenceList = jsondata as NSArray
                            
                            if results?.count == 0{
                                //no preferences in db. let's start adding!

                                for pref in jsondata{
                                    //1.specify which entity your going to use
                                    let preference = NSEntityDescription.insertNewObjectForEntityForName("PREFERENCES", inManagedObjectContext: context) as NSManagedObject
                                    //2. set preference name, preference id, and user id
                                    preference.setValue(pref["place_name"], forKey: "preference_name")
                                    preference.setValue(pref["pref_id"], forKey: "preference_id")
                                    preference.setValue(pref["user_id"], forKey: "id")
                                    //3. save preference
                                    context.save(nil)
                                    
                                    
                                }
                            }
                            
                            if results?.count > 0{
                                for pref in jsondata{
                                    if (pref["pref_id"] as Int) == sender.tag{
                                        //1.specify which entity your going to use
                                        let preference = NSEntityDescription.insertNewObjectForEntityForName("PREFERENCES", inManagedObjectContext: context) as NSManagedObject
                                        //2. set preference name, preference id, and user id
                                        preference.setValue(pref["place_name"], forKey: "preference_name")
                                        preference.setValue(pref["pref_id"], forKey: "preference_id")
                                        preference.setValue(pref["user_id"], forKey: "id")
                                        //3. save preference
                                        context.save(nil)
                                        break
                                    }
                                }
                            }
                        })
                    }
                })
                session.resume()
            }
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for tag in toggleTags{
            if (preferenceList.count > 0) {
                for pref in preferenceList{
                    var prefId = pref["pref_id"] as Int
                    if tag.tag == prefId {
                        tag.on = true
                        break
                    }
                    tag.on = false
                }
            }
            else{
                tag.on = false
            }
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
    

}
