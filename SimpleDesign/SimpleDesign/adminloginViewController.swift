//
//  adminloginViewController.swift
//  SimpleDesign
//
//  Created by Anusha Kankanala on 1/27/16.
//  Copyright © 2016 Anusha Kankanala. All rights reserved.
//

import UIKit
import Firebase

class adminlogin: UIViewController, UITextFieldDelegate {

    
    @IBOutlet var truckImage: UIImageView!
    @IBOutlet var adminLoginUIView: UIView!
    
    @IBOutlet var adminPassword: UILabel!
    @IBOutlet var adminID: UILabel!
    
    @IBOutlet var adminIDTF: UITextField!
    @IBOutlet var adminPasswordTF: UITextField!

    var ref = Firebase(url: "https://trucktracker.firebaseio.com/")

    
        override func viewDidLoad() {
        super.viewDidLoad()
        if let exists = ref.authData {
            self.view.startLoading()
            self.updateUser(exists)
        }
        self.addDoneButtonFor(self.adminIDTF)
        self.addDoneButtonFor(self.adminPasswordTF)

        // Do any additional setup after loading the view.
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func adminLogin(sender: UIButton) {
        let ref = Firebase(url: "https://trucktracker.firebaseio.com/")
        self.view.startLoading()
        ref.authUser(self.adminIDTF.text, password: self.adminPasswordTF.text,
            withCompletionBlock: { error, authData in
                if error != nil {
                    // There was an error logging in to this account
                    if (self.adminIDTF.text == "") {
                        UIAlertView.showAlertView("Login Failure", text: "EmailId or password incorrect, Please try again.", vc: self)
                    } else if(self.adminPasswordTF.text == ""){
                        UIAlertView.showAlertView("Login Failure", text: "EmailId or password incorrect, Please try again.", vc: self)
                    }
                    if error.description == "INVALID_PASSWORD" {
                        UIAlertView.showAlertView("Failure", text: "Wrong Password. Please try again.", vc: self)
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
                    let success = UIAlertController(title: "Success", message: "Successfully Logged into user account with your uid: \(authData.uid)", preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "Welcome back", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
                        self.view.stopLoading()
                    })
                    success.addAction(action)
                    self.presentViewController(success, animated: true, completion: nil)
                    
                }
        })


    }
    func updateUser(authData: FAuthData!){
        self.performSegueWithIdentifier("showTrucks", sender: nil)
        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: "user")
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.adminIDTF {
            self.adminPasswordTF.becomeFirstResponder()
        } else {
            self.adminLogin(UIButton())
        }
        return true
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
