//
//  ExploreViewController.swift
//  HiddenGems
//
//  Created by Melissa Rojas on 3/1/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit
import CoreData

var preferenceList: NSArray!

class ExploreViewController: UIViewController {
    
    @IBOutlet var welcomeLabel: UILabel!
    
    @IBOutlet weak var myAccount: UIButton!
    
    @IBOutlet weak var logout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "background1.png")
        self.view.insertSubview(backgroundImage, atIndex: 0)
        welcomeLabel.text = "Welcome \(logged_user) id \(logged_user_id)"
        print(logged_user)
        
        //Remove keyboard on touch
        self.hideKeyboardWhenTappedAround()
        
        //retrieving user's preferences
        let attemptUrl = NSURL(string:"http://54.152.30.2/hg/getPreferences")
        
        
        if let url = attemptUrl{
            //prepare data for post request
            let postParams = ["user_id": toString(logged_user_id)] as Dictionary<String,String>
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
                        
                        if results?.count == 0{
                            //no preferences in db. let's start adding!
                            
                            print("\n")
                            print("There's no preference set in db!")
                            print(data)
                            print("\n")
                            for pref in jsondata{
                                //1.specify which entity your going to use
                                let preference = NSEntityDescription.insertNewObjectForEntityForName("PREFERENCES", inManagedObjectContext: context) as NSManagedObject
                                //2. set preference name, preference id, and user id
                                preference.setValue(pref["place_name"], forKey: "preference_name")
                                preference.setValue(pref["pref_id"], forKey: "preference_id")
                                preference.setValue(pref["user_id"], forKey: "id")
                                //3. save preference
                                context.save(nil)
                                //print(pref["place_name"])
                                //print(pref["pref_id"])
                                //print("\n\n")
                                
                            }
                            preferenceList = jsondata as NSArray
                            print(preferenceList)
                            print("\n\n")
                        }
                        
                        if results?.count > 0 {
                            print("\n")
                            print("There's preference saved in db!")
                            print("\n")
                            
                            var temp = [AnyObject]()
                            
                            for result in results as [NSManagedObject] {
                                var val = [String : AnyObject]()
                                val["user_id"] = result.valueForKey("id")
                                val["pref_id"] = result.valueForKey("preference_id")
                                val["place_name"] = result.valueForKey("preference_name")
                                print(val)
                                temp.append(val)
                                print("\n\n")
                            }

                            preferenceList = temp
                        }
                        
                        tempSize = preferenceList.count

                    })
                    
                    
                    
                    
                    
                }
            })
            session.resume()
            
        }
        

        
        

    }

    @IBAction func logout(sender: AnyObject) {
        //when logout make sure user is erased from db
        //save json data in local storage
        
        //refers to AppDelegate
        let appDel: AppDelegate =  UIApplication.sharedApplication().delegate as AppDelegate
        
        //allows to access coredata database
        let context: NSManagedObjectContext = appDel.managedObjectContext!
        
        //create a request that allows us to get data from users entity
        let request = NSFetchRequest(entityName: "USER")
        
        let results = context.executeFetchRequest(request, error:nil)
        
        if results?.count > 0 {
            for result in results as [NSManagedObject]{
                print("Deleting \(result)")
                context.deleteObject(result)
                context.save(nil)
            }

        }
        else{
            print("no result to delete!")
        }
        
        //create a request that allows us to get data from preference entity
        let requestPref = NSFetchRequest(entityName: "PREFERENCES")
        
        let resultsPref = context.executeFetchRequest(requestPref, error: nil)
        
        print("\n")
        if resultsPref?.count > 0{
            for results in resultsPref as [NSManagedObject]{
                var result = results.valueForKey("preference_name") as String
                print("Deleting \(result)")
                print("\n")
                context.deleteObject(results)
                context.save(nil)
            }
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //Hide NavigationBar.
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
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
