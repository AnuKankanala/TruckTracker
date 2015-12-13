//
//  ViewController.swift
//  SimpleDesign
//
//  Created by Anusha Kankanala on 12/3/15.
//  Copyright © 2015 Anusha Kankanala. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    
    @IBOutlet var WelcomeLabel: UILabel!
    @IBOutlet var TruckImage: UIImageView!
    
    //var ref : Firebase! //(url: "https://cieldessertbar.firebaseio.com/Orders")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /*ref.observeEventType(.Value, withBlock: { snapshot -> Void in
            print("Data in my server is \(snapshot)")
        })*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       if(segue.identifier=="SignUpDetails"){
        if let _ = segue.destinationViewController as? SecondVC {
       
        
        }
        
        }
    }
}

