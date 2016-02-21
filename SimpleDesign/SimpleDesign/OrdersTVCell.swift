//
//  OrdersTVCell.swift
//  SimpleDesign
//
//  Created by Manasa Kankanala on 2/21/16.
//  Copyright © 2016 Anusha Kankanala. All rights reserved.
//

import UIKit
import Firebase

class OrdersTVCell: UITableViewCell {
    
    @IBOutlet var customerNameLabel: UILabel!
    @IBOutlet var orderInfoLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    var phoneNumber: String?
    var orderID: String!
    
    var isCustomer = true
    
    var order: NSDictionary! {
        didSet {
            if let order = self.order["Order"] as? String {
                self.orderInfoLabel.text = order
                self.orderInfoLabel.adjustsFontSizeToFitWidth = true
            }
            
            if let date = order["timestamp"] as? Double{
                self.dateLabel.text = NSDate.getDefaultTimeUsingGMTDoubleValue(date, dateFormat: "M/d/yy h:mm aa")
            }
            
            if let value = order["total"] as? CGFloat {
                self.priceLabel.text = String(format: "Price: $%.2f", value)
            }
            
            if let status = order["status"] as? String {
                
                
                self.statusLabel.text = "Status: \(status)"
                switch status {
                case "NEW":
                    if isCustomer {
                        self.statusLabel.text = "Preparing"
                    }
                    self.statusLabel.textColor = UIColor.orangeColor()
                case "DONE":
                    if isCustomer {
                        self.statusLabel.text = "Ready For Pick up"
                    }
                    self.statusLabel.textColor = UIColor.greenColor()
                default:
                    if isCustomer {
                        self.statusLabel.text = "Complete"
                    }
                    self.statusLabel.textColor = UIColor.redColor()
                }
            }
            
            self.updateInformationForThisUserOnTextField(self.order)
        }
    }
    
    func updateInformationForThisUserOnTextField(order: NSDictionary) {
        if let id = order["userID"] as? String {
            Firebase(url:"https://trucktracker.firebaseio.com/Users/\(id)").observeEventType(.Value, withBlock: { snapshot -> Void in
                if let value = snapshot.value as? NSDictionary {
                    dispatch_async(dispatch_get_main_queue(), {
                        if let fn = value["firstName"] as? String {
                            self.customerNameLabel.text = fn
                        }
                        
                        if let ph = value["phone_no"] as? String {
                            self.phoneNumber = ph
                        }
                    })
                }
                
            })
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
