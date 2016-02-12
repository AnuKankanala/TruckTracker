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
                if let value = currentMenuOption["total"] as? CGFloat {
                    if let date = currentMenuOption["timestamp"] as? Double{
                    let cost = String(format: "%.2f", value)
                    var temp = NSDate.getDefaultTimeUsingGMTDoubleValue(date, dateFormat: "MM/d/yyyy h.mm aa")
                        temp = "\(temp),total price $.\(cost)"

                    cell.detailTextLabel?.text = temp
                    //cell.detailTextLabel?.text = "Price $\(cost)"
                    }
                }
                
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
    
}