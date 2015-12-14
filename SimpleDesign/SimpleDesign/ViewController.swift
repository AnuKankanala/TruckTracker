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
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var password: UITextField!
    
    var ref = Firebase(url: "https://trucktracker.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        /*
        ref.observeEventType(.Value, withBlock: { snapshot -> Void in
            print("Data in my server is \(snapshot)")
        })*/
        //Firebase(url: "https://trucktracker.firebaseio.com/Truck/Menu/Cupcakes/Item3").setValue("Double-Chocolate")
    }
    
    @IBAction func loginExistingUser() {
        let ref = Firebase(url: "https://trucktracker.firebaseio.com/")
        self.view.startLoading()
        ref.authUser(self.emailTF.text, password: self.password.text,
            withCompletionBlock: { error, authData in
                self.view.stopLoading()
                if error != nil {
                    // There was an error logging in to this account
                    if error.description == "INVALID_PASSWORD" {
                        UIAlertView.showAlertView("Failure", text: "Wrong Password. Please try again.", vc: self)
                    } else if true {
                        //do not have account. please sign up
                    } else {
                        //network conenctivity
                    }
                    UIAlertView.showAlertView("Failure", text: "\(error). Please try again.", vc: self)
                } else {
                    // We are now logged in
                    self.performSegueWithIdentifier("showLocation", sender: nil)
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: "user")
                    let success = UIAlertController(title: "Success", message: "Successfully Logged into user account with your uid: \(authData.uid)", preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "Welcome back", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
                        self.view.stopLoading()
                        //print("Successfully created user account with uid: \(uid)")
                    })
                    success.addAction(action)
                    self.presentViewController(success, animated: true, completion: nil)
                    
                }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       if(segue.identifier == "SignUpDetails"){
        if let _ = segue.destinationViewController as? SecondVC {
       
        
        }
        
        }
    }
}

