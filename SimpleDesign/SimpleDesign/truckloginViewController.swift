//
//  truckloginViewController.swift
//  SimpleDesign
//
//  Created by Anusha Kankanala on 1/27/16.
//  Copyright © 2016 Anusha Kankanala. All rights reserved.
//

import UIKit
import Firebase

class truckloginViewController: UIViewController {

    @IBOutlet var truckappView: UIView!
    
    @IBOutlet var truckappIV: UIImageView!
    @IBOutlet var truckPassword: UILabel!
    @IBOutlet var truckIDTF: UITextField!
    @IBOutlet var truckID: UILabel!
    @IBOutlet var truckPasswordTF: UITextField!
    
    var ref = Firebase(url: "https://trucktracker.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let exists = ref.authData {
            self.view.startLoading()
            self.updateUser(exists)
        }
        self.addDoneButtonFor(self.truckIDTF)
        self.addDoneButtonFor(self.truckPasswordTF)

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
    
    func updateUser(authData: FAuthData!){
        self.performSegueWithIdentifier("showtruck", sender: nil)
        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: "user")
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.truckIDTF {
            self.truckPasswordTF.becomeFirstResponder()
        } else {
            self.truckLogin(UIButton())
        }
        return true
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func truckLogin(sender: UIButton) {
        let ref = Firebase(url: "https://trucktracker.firebaseio.com/")
        self.view.startLoading()
        ref.authUser(self.truckIDTF.text, password: self.truckPasswordTF.text,
            withCompletionBlock: { error, authData in
                if error != nil {
                    // There was an error logging in to this account
                    if (self.truckIDTF.text == "") {
                        UIAlertView.showAlertView("Login Failure", text: "EmailId or password incorrect, Please try again.", vc: self)
                    } else if(self.truckPasswordTF.text == ""){
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
