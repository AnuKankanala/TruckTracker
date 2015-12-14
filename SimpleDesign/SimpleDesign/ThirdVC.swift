//
//  ThirdVC.swift
//  SimpleDesign
//
//  Created by Anusha Kankanala on 12/11/15.
//  Copyright © 2015 Anusha Kankanala. All rights reserved.
//

import UIKit
import Firebase

class ThirdVC: UIViewController {
 
    var text1 : String!
    
    @IBOutlet var WelcomeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = NSUserDefaults.standardUserDefaults().valueForKey("user") as? String {
            Firebase(url: "https://trucktracker.firebaseio.com/Users/\(user)").observeEventType(.Value, withBlock: { snapshot -> Void in
                if let value = snapshot.value as? NSDictionary {
                    if let name = value["firstName"] as? String {
                        self.WelcomeLabel.text = "Welcome to TruckTracker \(name)"
                    }
                }
            })
        }
        self.navigationItem.hidesBackButton = true
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        //add logic for successful login
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
    }
    */

}
