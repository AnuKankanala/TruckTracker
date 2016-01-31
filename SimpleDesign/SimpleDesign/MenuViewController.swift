//
//  MenuViewController.swift
//  SimpleDesign
//
//  Created by Anusha Kankanala on 1/15/16.
//  Copyright © 2016 Anusha Kankanala. All rights reserved.
//

import UIKit
import Firebase

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var menuTableView: UITableView!
    var menuDictionary = NSDictionary()
    var currentTruck : MapAnnotation!
    var ref = Firebase(url:"https://trucktracker.firebaseio.com/Trucks")
    var itemsDict : [String: NSDictionary] = Dictionary()
    var isOrdering = false
    var totalPrice = 0
    var selectedItems = [String]()
    var ordersDict = NSDictionary()

    func orderSummary() -> String {
        var temp = ""
        for (index,each) in EnumerateSequence(self.selectedItems) {
            if temp.utf16.count > 0 {
                temp = "\(temp) \n\(index+1). \(each)"
            } else {
                temp = "\n\(index+1). \(each)"
            }
        }
        return temp
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startOrdering", name: "order", object: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Order", style: UIBarButtonItemStyle.Plain, target: self, action: "startOrdering")
        if let exists = currentTruck.menu {
            self.menuDictionary = exists
        }
        
        if let name = currentTruck.title {
            self.title = name
        }
        Firebase(url:"https://trucktracker.firebaseio.com/Trucks/Truck1/Orders").queryOrderedByChild("id").queryEqualToValue(UIDevice.currentDevice().identifierForVendor!.UUIDString).observeEventType(.Value, withBlock: { snapshot -> Void in
            //print("User orders are \(snapshot)")
            if let value = snapshot.value as? NSDictionary {
                self.ordersDict = value
            }
            //self.addMyOrdersButton()
        })
        // Do any additional setup after loading the view.
        
        
    }

    func startOrdering() {
        self.isOrdering = true
        self.selectedItems = []
        self.menuTableView.allowsMultipleSelection = true
       // self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelOrder")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Order(0)", style: UIBarButtonItemStyle.Plain, target: self, action: "startOrder")
        self.menuTableView.reloadData()
    }
    func startOrder(){
        if self.selectedItems.count == 0 {
            UIAlertView.showAlertView("Error", text: "No items selected", vc: self)
        }
        else{
        let order = UIAlertController(title: "New Order - Pick up", message: "Placing order for \(self.orderSummary())\nTotal price = Rs.\(totalPrice)", preferredStyle: UIAlertControllerStyle.Alert)
        order.view.tintColor = UIColor.mydarkPinkColor
        

        Firebase(url:"https://trucktracker.firebaseio.com/Trucks/Truck1/Orders").childByAutoId().setValue(["timestamp": FirebaseServerValue.timestamp(),"Name": "Anusha", "Order": self.orderSummary().stringByReplacingOccurrencesOfString("\n", withString: ""),"id": UIDevice.currentDevice().identifierForVendor!.UUIDString, "status": "NEW", "total": self.totalPrice])
            
            UIAlertView.showAlertView("Success", text: "Placed order for \(self.orderSummary()) items. Thank you ", vc: self)
            self.resetValues()
           
        }
    }

    func cancelOrder() {
        if self.selectedItems.count > 0 {
            let order = UIAlertController(title: "Cancel Order", message: "Would you like to cancel this order (self.orderSummary()) ?", preferredStyle: UIAlertControllerStyle.Alert)
            order.view.tintColor = UIColor.mydarkPinkColor
            let cancelOrder = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: { action in
                self.resetValues()
            })
            order.addAction(cancelOrder)
            let nothing = UIAlertAction(title: "NO", style: UIAlertActionStyle.Cancel, handler: { action in
            })
            order.addAction(nothing)
            self.presentViewController(order, animated: true, completion: {
                order.view.tintColor = UIColor.mydarkPinkColor
            })
        } else {
            self.resetValues()
        }
    }
    func resetValues() {
        self.isOrdering = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Order", style: UIBarButtonItemStyle.Plain, target: self, action: "startOrdering")
        self.selectedItems = []
        self.totalPrice = 0
        //self.addMyOrdersButton()
        self.menuTableView.allowsSelection = false
        self.menuTableView.reloadData()
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

extension MenuViewController {
    //TableView Row Methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell
        
        if let reuseCell = tableView.dequeueReusableCellWithIdentifier("CELL")  {
            cell = reuseCell
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CELL")
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
        cell.textLabel?.textColor = UIColor.mybrownColor
        cell.textLabel?.highlightedTextColor = UIColor.mydarkPinkColor
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(15)
        cell.detailTextLabel?.textColor = UIColor.mybrownColor
        cell.detailTextLabel?.highlightedTextColor = UIColor.mydarkPinkColor
        
        if let currentMenuOption = menuDictionary[menuDictionary.allKeys[indexPath.section] as! String] as? NSDictionary {
        
            if let key = currentMenuOption.allKeys[indexPath.row] as? String {
                cell.textLabel?.text = "\(key)"
                if let value = currentMenuOption[key] as? CGFloat {
                    let cost = String(format: "%.2f", value)
                    cell.detailTextLabel?.text = "Price $\(cost)"
                }
            }
            if self.isOrdering{
                cell.accessoryView = UIImageView(image: UIImage(named: "addcheck")?.tintWithColor(UIColor.lightGrayColor()), highlightedImage: UIImage(named: "addcheck")?.tintWithColor(UIColor.mydarkPinkColor))
                /*if self.selectedItems.contains("\(keys[indexPath.row])(\(key))") {
                    cell.setSelected(true, animated: false)
                } else {
                    cell.setSelected(false, animated: false)
                }*/

            }
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if isOrdering {
            if let currentMenuOption = menuDictionary[menuDictionary.allKeys[indexPath.section] as! String] as? NSDictionary {
                if let key = currentMenuOption.allKeys[indexPath.row] as? String {
                    if let item = self.itemsDict[key] {
                        let keys = item.allKeys as! [String]
                        let object = item[keys[indexPath.row]] as! NSDictionary
                        let price = object["price"] as! Int
                        totalPrice += price
                        self.selectedItems.append("\(keys[indexPath.row])(\(key))")
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Order(\(self.selectedItems.count))", style: UIBarButtonItemStyle.Plain, target: self, action: "startOrder")
                    }
                } else {
                    self.menuTableView.deselectRowAtIndexPath(indexPath, animated: false)
                }
            }  }
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if let currentMenuOption = menuDictionary[menuDictionary.allKeys[indexPath.section] as! String] as? NSDictionary {
            if let key = currentMenuOption.allKeys[indexPath.row] as? String {
        if let item = self.itemsDict[key] {
            let keys = item.allKeys as! [String]
            let object = item[keys[indexPath.row]] as! NSDictionary
            let price = object["price"] as! Int
            totalPrice -= price
            self.selectedItems.removeObject(&self.selectedItems, object: "\(keys[indexPath.row])(\(key))")
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Order(\(self.selectedItems.count))", style: UIBarButtonItemStyle.Plain, target: self, action: "startOrder")
        }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let currentMenuOption = menuDictionary[menuDictionary.allKeys[section] as! String] as! NSDictionary
        return currentMenuOption.allKeys.count
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return menuDictionary.count
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return menuDictionary.allKeys[section] as? String
    }
}

