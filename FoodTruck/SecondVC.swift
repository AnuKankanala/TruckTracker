//
//  SecondVC.swift
//  FoodTruck
//
//  Created by Anusha Kankanala on 12/10/15.
//  Copyright © 2015 Anusha Kankanala. All rights reserved.
//

import UIKit

//interface for protocol
protocol EditNameDelegate {
    func changeName(name: String)
}

class SecondVC: UIViewController {
    
    var delegate: EditNameDelegate!
    
    var title1 = ""

    @IBOutlet var changeName: UITextField!
    @IBOutlet var nameLabel: UILabel!
    
    @IBAction func done() {
        self.changeName.resignFirstResponder()
        self.delegate.changeName(changeName.text!)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.nameLabel.text = title1
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
