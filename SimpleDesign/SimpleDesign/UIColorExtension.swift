//
//  UIColorExtension.swift
//  PlayNFLBetting
//
//  Created by Vemula, Manoj (Contractor) on 4/10/15.
//  Copyright (c) 2015 Vemula, Manoj (Contractor). All rights reserved.
//

import Foundation
import UIKit
extension UIColor
{
    public class func colorWithHexString (hex:String, andAlpha:CGFloat) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            let index1 = cString.startIndex.advancedBy(1)
            cString = cString.substringFromIndex(index1)
            //cString = cString.substringFromIndex(1)
        }
        
        if cString.utf16.count != 6 {
            return UIColor.grayColor()
        }
        
        //var rString = cString.substringToIndex(2)
        let rString = cString.substringToIndex(cString.startIndex.advancedBy(2))
        
        //var gString = cString.substringFromIndex(2).substringToIndex(2)
        let gString = cString.substringFromIndex(cString.startIndex.advancedBy(2)).substringToIndex(cString.startIndex.advancedBy(2))
        
        //var bString = cString.substringFromIndex(4).substringToIndex(2)
        let bString = cString.substringFromIndex(cString.startIndex.advancedBy(4)).substringToIndex(cString.startIndex.advancedBy(2))
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0
        NSScanner(string:rString).scanHexInt(&r)
        NSScanner(string:gString).scanHexInt(&g)
        NSScanner(string:bString).scanHexInt(&b)
        let rDouble = Double(r) / 255.0
        let gDouble = Double(g) / 255.0
        let bDouble = Double(b) / 255.0
        
        return UIColor(red: CGFloat(rDouble), green: CGFloat(gDouble), blue: CGFloat(bDouble), alpha: andAlpha)
    }
    
    public class func colorWithByteValues(r:Int, g:Int, b:Int, a:CGFloat) -> UIColor {
        let rDouble = Double(r) / 255.0
        let gDouble = Double(g) / 255.0
        let bDouble = Double(b) / 255.0
        return UIColor(red: CGFloat(rDouble), green: CGFloat(gDouble), blue: CGFloat(bDouble), alpha: a)
    }
    
    class func addColorForTableView(table : UITableView) {
//        table.backgroundColor = UIColor.footballColor
//        table.separatorColor = UIColor.footballColor
//        table.tintColor = UIColor.footballColor
    }
    
    class var myblueColor : UIColor {
        return UIColor.colorWithHexString("#5FDEDD", andAlpha: 1)
    }
    
    class var mydarkPinkColor : UIColor {
        return UIColor.colorWithHexString("#FE7BAB", andAlpha: 1)
    }
    
    class var mypinkColor : UIColor {
        return UIColor.colorWithHexString("#FDD2E1", andAlpha: 1)
    }
    
    class var myBackgroundColor : UIColor {
        return UIColor.colorWithHexString("#FDF4F7", andAlpha: 1)
    }
    
    class var mybrownColor : UIColor {
        return UIColor.colorWithHexString("#6A472C", andAlpha: 1)
    }
    
    
    
}