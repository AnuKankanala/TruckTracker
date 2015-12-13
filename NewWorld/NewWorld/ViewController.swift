//
//  ViewController.swift
//  NewWorld
//
//  Created by Anusha Kankanala on 12/1/15.
//  Copyright © 2015 Anusha Kankanala. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    

    @IBOutlet var nameLabel: UILabel!
    
    override func viewDidLoad() {
super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func nameTextAction(nameTextField: UITextField) {
        nameLabel.text = "hi \(nameTextField.text)"
    }
}

