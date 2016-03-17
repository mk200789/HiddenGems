//
//  RegisterViewController.swift
//  HiddenGems
//
//  Created by Bryan Posso on 3/9/16.
//  Copyright © 2016 Melissa Rojas. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    
    
    @IBOutlet weak var registerBox: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerBox.layer.cornerRadius = 10;

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
    
    //Adding space
    }
    
    comitooo
    */

}
