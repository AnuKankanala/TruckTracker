//
//  ViewController.swift
//  FoodTruck
//
//  Created by Anusha Kankanala on 12/2/15.
//  Copyright © 2015 Anusha Kankanala. All rights reserved.
//

import UIKit

class ViewController: UIViewController, EditNameDelegate, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet var HiLabel: UILabel!
    @IBOutlet var userTextField: UITextField!

    @IBOutlet var exampleTableView: UITableView!
    
    var myArray = ["first name", "second name","password"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      if(segue.identifier=="showWelcome")
      {
        if let vc = segue.destinationViewController as? SecondVC {
            vc.title1 = userTextField.text!
            vc.delegate = self
        }
      }
    
    }
    //Delegate Method
    func changeName(name: String) {
        self.userTextField.text = name
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell
        
        if let reuseCell = tableView.dequeueReusableCellWithIdentifier("CELL")  {
            cell = reuseCell
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CELL")
        }
        
        cell.imageView?.image = UIImage(named: "test")
        cell.textLabel?.text = myArray[indexPath.row]
        cell.detailTextLabel?.text = "A \(indexPath.row)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print("I have tapped on \(indexPath.row) row")
    }
}



