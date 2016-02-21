//
//  ViewController.swift
//  SimpleDesign
//
//  Created by Anusha Kankanala on 12/3/15.
//  Copyright © 2015 Anusha Kankanala. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet var WelcomeLabel: UILabel!
    @IBOutlet var TruckImage: UIImageView!
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var password: UITextField!
    
    var ref = Firebase(url: "https://trucktracker.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let exists = ref.authData {
            //self.view.startLoading()
            self.updateUser(exists)
        }
        self.addDoneButtonFor(self.emailTF)
        self.addDoneButtonFor(self.password)
    }
    
    func addDoneButtonFor(textField: UITextField) {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
            target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .Done,
            target: view, action: Selector("endEditing:"))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        textField.inputAccessoryView = keyboardToolbar
    }
    
    @IBAction func loginExistingUser() {
        
        let ref = Firebase(url: "https://trucktracker.firebaseio.com/")
        self.view.startLoading()
        ref.authUser(self.emailTF.text, password: self.password.text,
            withCompletionBlock: { error, authData in
                if error != nil {
                    // There was an error logging in to this account
                    if (self.emailTF.text == "") {
                        UIAlertView.showAlertView("Login Failure", text: "EmailId or password incorrect, Please try again.", vc: self)
                    } else if(self.password.text == ""){
                        UIAlertView.showAlertView("Login Failure", text: "EmailId or password incorrect, Please try again.", vc: self)
                    }
                    if error.description == "INVALID_PASSWORD" {
                        UIAlertView.showAlertView("Failure", text: "Wrong Password. Please try again.", vc: self)
                    } else if true {
                        //do not have account. please sign up
                         UIAlertView.showAlertView("Failure", text: "Sorry! you are not registered.Please SignUp ", vc: self)
                    }
                    else {
                        //network conenctivity coode
                    }
                    UIAlertView.showAlertView("Failure", text: "\(error). Please try again.", vc: self)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.view.stopLoading()
                    })
                } else {
                    // We are now logged in
                    self.updateUser(authData)
                    let success = UIAlertController(title: "Success", message: "Successfully Logged into user account with your emailID: \(self.emailTF.text)", preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "Welcome back", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
                        self.view.stopLoading()//print("Successfully created user account with uid: \(uid)")
                    })
                    success.addAction(action)
                    self.presentViewController(success, animated: true, completion: nil)
                    
                }
        })
    }
    
    func updateUser(authData: FAuthData!) {
        self.performSegueWithIdentifier("showLocation", sender: nil)
        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: "user")
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.emailTF {
            self.password.becomeFirstResponder()
        } else {
            self.loginExistingUser()
        }
        return true
    }
}

