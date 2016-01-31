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
    @IBOutlet var ordersTable: UITableView!
    var isadmin = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Orders"

        // Do any additional setup after loading the view.
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

extension OrdersViewController{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.ordersTable.deselectRowAtIndexPath(indexPath, animated: false)
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myOrders.count
    }
    
}