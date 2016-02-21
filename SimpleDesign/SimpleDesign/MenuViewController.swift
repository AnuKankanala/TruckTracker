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
    @IBOutlet var ordersPopUpButton: UIButton!
    var menuDictionary = NSDictionary()
    var currentTruck : MapAnnotation!
    var ref = Firebase(url:"https://trucktracker.firebaseio.com/Trucks")
    var itemsDict : [String: NSDictionary] = Dictionary()
    var isOrdering = false
    var totalPrice: Float = 0.0
    var selectedItems = [String]()
    var ordersDict = NSDictionary()
    var allowsEditing = false
    var currentUserID = ""
    var currentUserName = ""

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
    
    func showAlertForNewMenuItem(type: String?) {
        let add = UIAlertController(title: "New Menu Item", message: "Add new menu item, fill the details.", preferredStyle: UIAlertControllerStyle.Alert)
        add.view.tintColor = UIColor.mydarkPinkColor
        if let _ = type {} else {
            add.addTextFieldWithConfigurationHandler({textField in
                textField.placeholder = "Enter new item type"
                textField.keyboardType = UIKeyboardType.Alphabet
                textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
                textField.returnKeyType = UIReturnKeyType.Next
            })
        }
        add.addTextFieldWithConfigurationHandler({textField in
            textField.placeholder = "Enter new item name"
            textField.keyboardType = UIKeyboardType.Alphabet
            textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
            textField.returnKeyType = UIReturnKeyType.Next
        })
        add.addTextFieldWithConfigurationHandler({textField in
            textField.placeholder = "Enter new item price"
            textField.keyboardType = UIKeyboardType.NumberPad
            textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
            textField.returnKeyType = UIReturnKeyType.Next
        })
        let ok = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default, handler: { action in
            //Update Price
            if let exist = type {
                Firebase(url: "https://trucktracker.firebaseio.com/Trucks/\(self.currentTruck.id!)/Menu/\(exist)/\(add.textFields![0].text!)").setValue(Float(add.textFields![1].text!))
            } else {
                Firebase(url: "https://trucktracker.firebaseio.com/Trucks/\(self.currentTruck.id!)/Menu/\(add.textFields![0].text!)/\(add.textFields![1].text!)").setValue(Float(add.textFields![2].text!))
            }
        })
        let nothing = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
            self.view.stopLoading()})
        add.addAction(ok)
        add.addAction(nothing)
        self.presentViewController(add, animated: true, completion: nil)
    }
    
    func addNewItem() {
        let Type = self.menuDictionary.allKeys as! [String]
        if Type.count > 0 {
            let typeAlert = UIAlertController(title: "Choose", message: "Choose a type of menu item", preferredStyle: UIAlertControllerStyle.ActionSheet)
            let new = UIAlertAction(title: "New Type", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
                self.showAlertForNewMenuItem(nil)
            })
            typeAlert.addAction(new)
            for each in Type {
                let existing = UIAlertAction(title: each, style: UIAlertActionStyle.Default, handler: {(action) -> Void in
                    self.showAlertForNewMenuItem(each)
                })
                typeAlert.addAction(existing)
            }
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action) -> Void in
            })
            typeAlert.addAction(cancel)
            self.presentViewController(typeAlert, animated: true, completion: nil)
        } else {
            self.showAlertForNewMenuItem(nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startOrdering", name: "order", object: nil)
        if self.allowsEditing {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Item", style: UIBarButtonItemStyle.Plain, target: self, action: "addNewItem")
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Order", style: UIBarButtonItemStyle.Plain, target: self, action: "startOrdering")
        }
        
        
        self.ordersPopUpButton.layer.cornerRadius = 20.0
        
        if let exists = currentTruck.menu {
            self.menuDictionary = exists
        }
        
        if let name = currentTruck.title {
            self.title = name
        }
        Firebase(url:"https://trucktracker.firebaseio.com/Orders").queryOrderedByChild("truckID").queryEqualToValue(self.currentTruck.id!).observeEventType(.Value, withBlock: { snapshot -> Void in
            //print("User orders are \(snapshot)")
            if let newValue = snapshot.value as? NSDictionary {
                if self.allowsEditing {
                    if self.ordersDict.count < newValue.count {
                        NSUserDefaults.standardUserDefaults().setObject(newValue.count - self.ordersDict.count, forKey: "NewUpdates")
                        self.updateOrderNotifications()
                    }
                } else {
                    for (key,value) in self.ordersDict {
                        print("Current key is \(key)")
                        if let currentStatus = value["status"] as? String {
                            if let newOrderUpdate = newValue[key as! String] as? NSDictionary {
                                if let newStatus = newOrderUpdate["status"] as? String {
                                    if newStatus != currentStatus && newStatus == "DONE" {
                                        if let counter = NSUserDefaults.standardUserDefaults().objectForKey("NewUpdates") as? Int {
                                            NSUserDefaults.standardUserDefaults().setObject(counter + 1, forKey: "NewUpdates")
                                            if let orderinfo = value["Order"] as? String {
                                                if newStatus == "DONE" {
                                                    UIAlertView.showAlertView("Order Update", text: "Your order \(orderinfo) is now Ready for pick up", vc: self)
                                                }
                                            }
                                        } else {
                                            NSUserDefaults.standardUserDefaults().setObject(1, forKey: "NewUpdates")
                                            if let orderinfo = value["Order"] as? String {
                                                if newStatus == "DONE" {
                                                    UIAlertView.showAlertView("Order Update", text: "Your order \(orderinfo) is now Ready for Pick up", vc: self)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                self.ordersDict = newValue
            }
            //self.addMyOrdersButton()
        })
        // Do any additional setup after loading the view.
        
        Firebase(url:"https://trucktracker.firebaseio.com/Trucks/\(self.currentTruck.id!)/Menu").observeEventType(.Value, withBlock: { snapshot -> Void in
            //print("User orders are \(snapshot)")
            if let value = snapshot.value as? NSDictionary {
                self.menuDictionary = value
                self.menuTableView.reloadData()
            }
            //self.addMyOrdersButton()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        self.updateOrderNotifications()
    }
    
    func updateOrderNotifications() {
        if let newUpdates = NSUserDefaults.standardUserDefaults().objectForKey("NewUpdates") as? Int {
            self.ordersPopUpButton.hidden = false
            self.ordersPopUpButton.setTitle("\(newUpdates)", forState: UIControlState.Normal)
        } else {
            self.ordersPopUpButton.hidden = true
        }
    }

    func startOrdering() {
        self.isOrdering = true
        self.selectedItems = []
        self.menuTableView.allowsMultipleSelection = true
       //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelOrder")
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
            let place = UIAlertAction(title: "Place order", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
                Firebase(url:"https://trucktracker.firebaseio.com/Orders").childByAutoId().setValue(["timestamp": FirebaseServerValue.timestamp(),"userID": self.currentUserID, "Order": self.orderSummary().stringByReplacingOccurrencesOfString("\n", withString: ""),"id": UIDevice.currentDevice().identifierForVendor!.UUIDString, "status": "NEW", "total": self.totalPrice, "truckID": self.currentTruck.id!])
                UIAlertView.showAlertView("Success", text: "Placed order for \(self.orderSummary()) items. Thank you ", vc: self)
                self.resetValues()
            })
            order.addAction(place)
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {(action) -> Void in
                self.cancelOrder()
            })
            order.addAction(cancel)
            self.presentViewController(order, animated: true, completion: nil)
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
        if self.allowsEditing {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Item", style: UIBarButtonItemStyle.Plain, target: self, action: "addNewItem")
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Order", style: UIBarButtonItemStyle.Plain, target: self, action: "startOrdering")
        }
        self.selectedItems = []
        self.totalPrice = 0
        //self.addMyOrdersButton()
        self.menuTableView.allowsSelection = false
        self.menuTableView.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? OrdersViewController {
            vc.currentUser = self.currentUserID
            if self.allowsEditing {
                vc.truckId = self.currentTruck.id!
                self.resetValues()
            }
        }
    }

}

extension MenuViewController {
    //TableView Row Methods
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell
        
        if let reuseCell = tableView.dequeueReusableCellWithIdentifier("CELL")  {
            cell = reuseCell
        } else {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CELL")
        }
        
        cell.selectionStyle = self.isOrdering ? UITableViewCellSelectionStyle.Default : UITableViewCellSelectionStyle.None
        
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
                if self.isOrdering{
                    let Type = self.menuDictionary.allKeys[indexPath.section] as! String
                    cell.accessoryView = UIImageView(image: UIImage(named: "addcheck")?.tintWithColor(UIColor.lightGrayColor()), highlightedImage: UIImage(named: "addcheck")?.tintWithColor(UIColor.mydarkPinkColor))
                    if self.selectedItems.contains("\(key)(\(Type))") {
                        cell.setSelected(true, animated: false)
                    } else {
                        cell.setSelected(false, animated: false)
                    }
                } else {
                    cell.accessoryView = nil
                }
            }
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if isOrdering {
            let Type = self.menuDictionary.allKeys[indexPath.section] as! String
            if let currentMenuOption = menuDictionary[menuDictionary.allKeys[indexPath.section] as! String] as? NSDictionary {
                if let key = currentMenuOption.allKeys[indexPath.row] as? String {
                    let price = currentMenuOption[currentMenuOption.allKeys[indexPath.row] as! String] as! Float
                    //let price = currentMenuOption[object] as! Float
                    totalPrice += price
                    self.selectedItems.append("\(key)(\(Type))")
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Order(\(self.selectedItems.count))", style: UIBarButtonItemStyle.Plain, target: self, action: "startOrder")
                } else {
                    self.menuTableView.deselectRowAtIndexPath(indexPath, animated: false)
                }
            }
        }
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let Type = self.menuDictionary.allKeys[indexPath.section] as! String
        if let currentMenuOption = menuDictionary[menuDictionary.allKeys[indexPath.section] as! String] as? NSDictionary {
            if let key = currentMenuOption.allKeys[indexPath.row] as? String {
                let price = currentMenuOption[currentMenuOption.allKeys[indexPath.row] as! String] as! Float
                //let price = currentMenuOption[object] as! Float
                totalPrice -= price
                self.selectedItems.removeObject(&self.selectedItems, object: "\(key)(\(Type))")
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Order(\(self.selectedItems.count))", style: UIBarButtonItemStyle.Plain, target: self, action: "startOrder")
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
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        var buttons = [UITableViewRowAction]()
        let button = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Change Price") { (action, indexPath) -> Void in
            let Type = self.menuDictionary.allKeys[indexPath.section] as! String
            if let currentMenuOption = self.menuDictionary[Type] as? NSDictionary {
                if let key = currentMenuOption.allKeys[indexPath.row] as? String {
                    if let value = currentMenuOption[key] as? CGFloat {
                        let cost = String(format: "%.2f", value)
                        let add = UIAlertController(title: "\(key)(\(Type))", message: "Would you like to change the price of \(key) $\(cost) ?", preferredStyle: UIAlertControllerStyle.Alert)
                        add.view.tintColor = UIColor.mydarkPinkColor
                        add.addTextFieldWithConfigurationHandler({textField in
                            textField.placeholder = "Enter new price"
                            textField.keyboardType = UIKeyboardType.NumberPad
                            textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
                            textField.returnKeyType = UIReturnKeyType.Next
                        })
                        let ok = UIAlertAction(title: "Change", style: UIAlertActionStyle.Default, handler: { action in
                            //Update Price
                            if let value = add.textFields![0].text {
                                Firebase(url: "https://trucktracker.firebaseio.com/Trucks/\(self.currentTruck.id!)/Menu/\(Type)/\(key)").setValue(Float(value))
                            }
                        })
                        add.addAction(ok)
                        self.presentViewController(add, animated: true, completion: nil)
                    }
                }
            }
        }
        button.backgroundColor = UIColor.greenColor()
        buttons.append(button)
        
        let button1 = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") { (action, indexPath) -> Void in
            let Type = self.menuDictionary.allKeys[indexPath.section] as! String
            if let currentMenuOption = self.menuDictionary[Type] as? NSDictionary {
                if let key = currentMenuOption.allKeys[indexPath.row] as? String {
                    let add = UIAlertController(title: "\(key)(\(Type))", message: "Would you like to delete \(key)?", preferredStyle: UIAlertControllerStyle.Alert)
                    add.view.tintColor = UIColor.mydarkPinkColor
                    let ok = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: { action in
                        //Delete Item
                        Firebase(url: "https://trucktracker.firebaseio.com/Trucks/\(self.currentTruck.id!)/Menu/\(Type)/\(key)").setValue(nil)
                    })
                    add.addAction(ok)
                    
                    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
                    })
                    add.addAction(cancel)
                    
                    self.presentViewController(add, animated: true, completion: nil)
                }
            }
        }
        button1.backgroundColor = UIColor.redColor()
        buttons.append(button1)
        
        return buttons
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.allowsEditing
    }
}

