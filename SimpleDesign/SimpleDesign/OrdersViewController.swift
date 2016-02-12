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
    var myOrders = NSDictionary()
    var currentUser = ""
    @IBOutlet var ordersTable: UITableView!
    var truckId : String?
    
    var phoneNumberDictionary = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Orders"

        // Do any additional setup after loading the view.
        if let exists = self.truckId {
            Firebase(url:"https://trucktracker.firebaseio.com/Orders").queryOrderedByChild("truckID").queryEqualToValue(exists).observeEventType(.Value, withBlock: { snapshot -> Void in
                //print("User orders are \(snapshot)")
                if let value = snapshot.value as? NSDictionary {
                    self.myOrders = value
                    self.ordersTable.reloadData()
                }
            })
        } else {
            Firebase(url:"https://trucktracker.firebaseio.com/Orders").queryOrderedByChild("userID").queryEqualToValue(self.currentUser).observeEventType(.Value, withBlock: { snapshot -> Void in
                //print("User orders are \(snapshot)")
                if let value = snapshot.value as? NSDictionary {
                    self.myOrders = value
                    self.ordersTable.reloadData()
                }
            })
        }
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
        var cell : UITableViewCell
        
        if let reuseCell = tableView.dequeueReusableCellWithIdentifier("CELL")  {
            cell = reuseCell
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CELL")
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.Default
        
        cell.textLabel?.textColor = UIColor.mybrownColor
        cell.textLabel?.highlightedTextColor = UIColor.mydarkPinkColor
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(15)
        cell.detailTextLabel?.textColor = UIColor.mybrownColor
        cell.detailTextLabel?.highlightedTextColor = UIColor.mydarkPinkColor
        
        if let currentMenuOption = myOrders[myOrders.allKeys[indexPath.row] as! String] as? NSDictionary {
            if let order = currentMenuOption["Order"] as? String {
                cell.textLabel?.text = order
                self.updateInformationForThisUserOnTextField(currentMenuOption, label: cell.detailTextLabel!)
            }
            
        }
    
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.ordersTable.deselectRowAtIndexPath(indexPath, animated: false)
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myOrders.allKeys.count
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        var buttons = [UITableViewRowAction]()
        let button1 = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Call") { (action, indexPath) -> Void in
            if let order = self.myOrders[self.myOrders.allKeys[indexPath.row] as! String] as? NSDictionary {
                if let id = order["userID"] as? String {
                    if let phone = self.phoneNumberDictionary[id] {
                        UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(phone)")!)
                    }
                }
                
            }
        }
        button1.backgroundColor = UIColor.greenColor()
        buttons.append(button1)
        
        return buttons
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if let _ = self.truckId {
            return true
        }
        return false
    }
    
}