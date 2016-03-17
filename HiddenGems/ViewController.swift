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

