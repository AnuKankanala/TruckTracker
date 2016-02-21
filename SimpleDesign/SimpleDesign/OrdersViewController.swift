//
//  OrdersViewController.swift
//  SimpleDesign
//
//  Created by Anusha Kankanala on 1/30/16.
//  Copyright © 2016 Anusha Kankanala. All rights reserved.
//

import UIKit
import Firebase

class OrdersViewController: UIViewController {
    var myOrders = [NSDictionary]()
    var adminDict = NSDictionary()
    var currentUser = ""
    @IBOutlet var ordersTable: UITableView!
    var truckId : String?
    
    var phoneNumberDictionary = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Orders"
        
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "NewUpdates")

        // Do any additional setup after loading the view.
        if let exists = self.truckId {
            Firebase(url:"https://trucktracker.firebaseio.com/Orders").queryOrderedByChild("truckID").queryEqualToValue(exists).observeEventType(.Value, withBlock: { snapshot -> Void in
                //print("User orders are \(snapshot)")
                if let value = snapshot.value as? NSDictionary {
                    self.adminDict = value
                    self.myOrders = value.allValues as! [NSDictionary]
                    self.myOrders = self.myOrders.sort{return $0["timestamp"] as! Double >  $1["timestamp"] as! Double}
                    self.ordersTable.reloadData()
                }
            })
        } else {
            Firebase(url:"https://trucktracker.firebaseio.com/Orders").queryOrderedByChild("userID").queryEqualToValue(self.currentUser).observeEventType(.Value, withBlock: { snapshot -> Void in
                //print("User orders are \(snapshot)")
                if let value = snapshot.value as? NSDictionary {
                    self.adminDict = value
                    self.myOrders = value.allValues as! [NSDictionary]
                    self.myOrders = self.myOrders.sort{return $0["timestamp"] as! Double >  $1["timestamp"] as! Double}
                    self.ordersTable.reloadData()
                }
            })
        }
        
        self.ordersTable.registerNib(UINib(nibName: "OrdersTVCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "orderCell")
    }
    
    func updateInformationForThisUserOnTextField(order: NSDictionary, label: UILabel) {
        if let value = order["total"] as? CGFloat {
            if let date = order["timestamp"] as? Double{
                let cost = String(format: "%.2f", value)
                let date = NSDate.getDefaultTimeUsingGMTDoubleValue(date, dateFormat: "M/d/yy h.mm aa")
                var temp = "Price $\(cost) Date: \(date)"
                
                if let _ = self.truckId {
                    if let id = order["userID"] as? String {
                        Firebase(url:"https://trucktracker.firebaseio.com/Users/\(id)").observeEventType(.Value, withBlock: { snapshot -> Void in
                            if let value = snapshot.value as? NSDictionary {
                                if let fn = value["firstName"] as? String {
                                    temp = fn + ": \(temp)"
                                }
                                
                                if let ph = value["phone_no"] as? String {
                                    self.phoneNumberDictionary[id] = ph
                                }
                                dispatch_async(dispatch_get_main_queue(), {
                                    label.text = "\(temp)"
                                })
                            }
                            
                        })
                    }
                } else {
                    label.text = "\(temp)"
                }
                
            }
        }
    }
}

extension OrdersViewController{
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       
        var cell : OrdersTVCell? = tableView.dequeueReusableCellWithIdentifier("orderCell", forIndexPath: indexPath) as? OrdersTVCell
        
        if cell == nil {
            let nib:Array = NSBundle.mainBundle().loadNibNamed("OrdersTVCell", owner: self, options: nil)
            cell = nib[0] as? OrdersTVCell
        }
        

        cell?.order = myOrders[indexPath.row]
        for (key,value) in self.adminDict {
            if value as! NSDictionary == self.myOrders[indexPath.row] {
                cell?.orderID = key as! String
            }
        }
        if let _ = self.truckId {
            cell?.isCustomer = false
        }
    
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.ordersTable.deselectRowAtIndexPath(indexPath, animated: false)
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myOrders.count
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        var buttons = [UITableViewRowAction]()
        let button1 = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Call") { (action, indexPath) -> Void in
            
            let currentCell = tableView.cellForRowAtIndexPath(indexPath) as! OrdersTVCell
            if let phoneNumber = currentCell.phoneNumber {
                UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(phoneNumber)")!)
            }
        }
        button1.backgroundColor = UIColor.greenColor()
        buttons.append(button1)
        
        let currentCell = tableView.cellForRowAtIndexPath(indexPath) as! OrdersTVCell
        if let status = currentCell.order["status"] as? String {
            let button2 = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: status == "NEW" ? "DONE" : "CLOSED") { (action, indexPath) -> Void in
                Firebase(url:"https://trucktracker.firebaseio.com/Orders").childByAppendingPath("/\(currentCell.orderID)/status").setValue(status == "NEW" ? "DONE" : "CLOSED")
            }
            button2.backgroundColor = UIColor.redColor()
            if status != "CLOSED"  {
                buttons.append(button2)
            }
        }
        
        return buttons
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let _ = self.truckId {
            return true
        }
        return false
    }
    
}