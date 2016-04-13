//
//  ExploreViewController.swift
//  HiddenGems
//
//  Created by Melissa Rojas on 3/1/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit
import CoreData

class ExploreViewController: UIViewController {
    
    @IBOutlet weak var myAccount: UIButton!
    
    @IBOutlet weak var logout: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.image = UIImage(named: "background1.png")
        self.view.insertSubview(backgroundImage, atIndex: 0)
        
        //Remove keyboard on touch
        self.hideKeyboardWhenTappedAround()
    

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
