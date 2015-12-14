//
//  SecondVC.swift
//  SimpleDesign
//
//  Created by Anusha Kankanala on 12/11/15.
//  Copyright © 2015 Anusha Kankanala. All rights reserved.
//

import UIKit
import Firebase

class SecondVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var FirstNameTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var rePasswordTextField: UITextField!
    
    @IBOutlet var phoneNoTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.addDoneButtonFor(self.FirstNameTextField)
        self.addDoneButtonFor(self.lastNameTextField)
        self.addDoneButtonFor(self.emailTextField)
        self.addDoneButtonFor(self.passwordTextField)
        self.addDoneButtonFor(self.rePasswordTextField)
        self.addDoneButtonFor(self.phoneNoTextField)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeAllTextFieldKeyboards() {
        FirstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        rePasswordTextField.resignFirstResponder()
        phoneNoTextField.resignFirstResponder()
    }
    
    func checkIFValidEmailEntered() -> Bool {
        //TODO
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(self.emailTextField.text)
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
    
    func checkIFValidPhoneNumberEntered() -> Bool {
        if phoneNoTextField.text?.utf16.count == 10 {
            if let _ = Int(phoneNoTextField.text!) {
                return true
            }
        }
        
        return false
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case self.FirstNameTextField:
            self.lastNameTextField.becomeFirstResponder()
        case self.lastNameTextField:
            self.emailTextField.becomeFirstResponder()
        case emailTextField:
            self.passwordTextField.becomeFirstResponder()
        case passwordTextField:
            self.rePasswordTextField.becomeFirstResponder()
        case rePasswordTextField:
            self.phoneNoTextField.becomeFirstResponder()
        default:
            self.createButton(UIButton())
        }
        return true
    }
    
    @IBAction func createButton(sender: UIButton) {
    
        self.closeAllTextFieldKeyboards()
    
        var isNotValid = false
        
        var errorString = ""
        
        if (FirstNameTextField.text == "") {
            errorString = "\(errorString) FirstName"
        }
        
        if (lastNameTextField.text == "") {
            errorString = "\(errorString) LastName"
        }
        if (passwordTextField.text == "") {
            errorString = "\(errorString) Password"
        }
        if (rePasswordTextField.text == "") {
            errorString = "\(errorString) Re enter password"
        }
        if (rePasswordTextField.text != passwordTextField.text) {
            errorString = "\(errorString) Passwords not match"
        }
        if (!self.checkIFValidEmailEntered()) {
            errorString = "\(errorString) Invalid email"
        }
        if (phoneNoTextField.text == "") {
            errorString = "\(errorString) Invalid Phone number"
        } else if phoneNoTextField.text?.utf16.count != 10 {
            errorString = "\(errorString) Invalid Phone number"
        }
        
        if errorString.utf16.count > 0 {
            isNotValid = true
            let popMessage = UIAlertController(title: " Sign up Failed", message: "Please enter all your details \(errorString)", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
                print("")
            })
            popMessage.addAction(action)
            self.presentViewController(popMessage, animated: true, completion: nil)
        }
        
        if !checkIFValidPhoneNumberEntered() {
            //show wrong phone number entered
        }
        
        
        if !isNotValid {
            //valid login
            let myRootRef = Firebase(url: "https://trucktracker.firebaseio.com/")
            myRootRef.createUser(self.emailTextField.text, password: self.passwordTextField.text,
                withValueCompletionBlock: { error, result in
                    
                    if error != nil {
                        // There was an error creating the account
                    } else {
                        let uid = result["uid"] as? String
                        print("Successfully created user account with uid: \(uid)")
                        self.performSegueWithIdentifier("showLocation", sender: nil)
                    }
            })
        }
        
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
         if(segue.identifier=="showLocation")
         {
           if let vc = segue.destinationViewController as? ThirdVC{
            vc.text1 = lastNameTextField.text!
        }
            
        }
    }
}
