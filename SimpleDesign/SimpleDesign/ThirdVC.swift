//
//  ThirdVC.swift
//  SimpleDesign
//
//  Created by Anusha Kankanala on 12/11/15.
//  Copyright © 2015 Anusha Kankanala. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation
import AddressBookUI


class ThirdVC: UIViewController , MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
 
    var text1 : String!
    var ref = Firebase(url:"https://trucktracker.firebaseio.com/Trucks")
    var mapAnnotation = [MapAnnotation]()
    var userAnnotation: MapAnnotation?
    var isEditMode = false
    
    var isadmin = false
    var istruckoperator = false
    var currentUserId = ""
    
    let kLocationUpdateNotification = "LocationUpdateNotification"
    
    @IBOutlet var LocationOptions: UISegmentedControl!
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var addresstextField: UITextField!
    
    let location = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Food Trucks"
        
        
        self.LocationOptions.removeAllSegments()
        
        if let user = NSUserDefaults.standardUserDefaults().valueForKey("user") as? String {
            Firebase(url: "https://trucktracker.firebaseio.com/Users/\(user)").observeEventType(.Value, withBlock: { snapshot -> Void in
                if let id = snapshot.key {
                    self.currentUserId = id
                }
                if let value = snapshot.value as? NSDictionary {
                    if let name = value["firstName"] as? String
                    {
                        print("Logged in user is  \(name)")
                    }
                    if let admin = value["isAdmin"] as? Bool
                    {
                        self.isadmin = admin
                        //print("Logged in user is  \(name)")
                    }
                    if let driver = value["isDriver"] as? Bool
                    {
                        self.istruckoperator = driver
                        //print("Logged in user is  \(name)")
                    }
                    if self.isadmin {
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "addcheck"), style: UIBarButtonItemStyle.Plain, target: self, action: "addTruck")
                    } else if self.istruckoperator {
                        self.doneMapSettings()
                        self.addresstextField.hidden = false
                        self.LocationOptions.insertSegmentWithTitle("Current", atIndex: 0, animated: false)
                        self.LocationOptions.insertSegmentWithTitle("Use Address", atIndex: 2, animated: false)
                    } else {
                        self.addresstextField.hidden = false
                        self.LocationOptions.insertSegmentWithTitle("Current Location", atIndex: 0, animated: false)
                        self.LocationOptions.insertSegmentWithTitle("Use Address", atIndex: 1, animated: false)
                        self.doneMapSettings()
                    }
                }
            })
            
            self.location.delegate = self
            self.location.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            self.location.requestWhenInUseAuthorization()
            self.location.startUpdatingLocation()
            self.mapView.showsUserLocation = true
            
            //Truck location
            self.mapView.delegate = self
        }
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Done, target: self, action: "logout")
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tappedOnMapOptions(segment: UISegmentedControl) {
        switch segment.selectedSegmentIndex {
        case 1:
            self.addresstextField.hidden = false
            self.location.stopUpdatingLocation()
        case 0:
            self.addresstextField.hidden = true
            self.location.startUpdatingLocation()
        default:
            self.location.startUpdatingLocation()
            self.addresstextField.hidden = true
        }
    }
    func showOrders(){
        self.performSegueWithIdentifier("showMyOrders", sender: nil)

    }
    func addTruck(){
        
        let myref = Firebase(url: "https://trucktracker.firebaseio.com/Trucks")
        let add = UIAlertController(title: "New Truck", message: "Give emailID and password", preferredStyle: UIAlertControllerStyle.Alert)
        add.view.tintColor = UIColor.mydarkPinkColor
        add.addTextFieldWithConfigurationHandler({textField in
            textField.placeholder = "Enter Truck EmailID"
            textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
            textField.returnKeyType = UIReturnKeyType.Next
        })
        
        add.addTextFieldWithConfigurationHandler({textField in
            textField.placeholder = "Enter Password"
            textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
            textField.returnKeyType = UIReturnKeyType.Next
        })
        add.addTextFieldWithConfigurationHandler({textField in
            textField.placeholder = "Enter Truck name"
            textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
            textField.returnKeyType = UIReturnKeyType.Next
        })
        add.addTextFieldWithConfigurationHandler({textField in
            textField.placeholder = "Enter Truck time"
            textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
            textField.returnKeyType = UIReturnKeyType.Next
        })
        add.addTextFieldWithConfigurationHandler({textField in
            textField.placeholder = "Enter Truck Latitude"
            textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
            textField.returnKeyType = UIReturnKeyType.Next
        })
        add.addTextFieldWithConfigurationHandler({textField in
            textField.placeholder = "Enter Truck Longitude"
            textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
            textField.returnKeyType = UIReturnKeyType.Next
        })

        add.addTextFieldWithConfigurationHandler({textField in
            textField.placeholder = "Enter Truck phone number"
            textField.autocapitalizationType = UITextAutocapitalizationType.Sentences
            textField.returnKeyType = UIReturnKeyType.Next
        })
       
        let ok = UIAlertAction(title: "ADD ", style: UIAlertActionStyle.Default, handler: { action in
            self.view.startLoading()
            //Create a Truck Driver
            Firebase(url: "https://trucktracker.firebaseio.com").createUser(add.textFields![0].text!, password: add.textFields![1].text!,
                withValueCompletionBlock: { error, result in
                    if error != nil {
                        // There was an error creating the account
                        dispatch_async(dispatch_get_main_queue(), {
                            self.view.stopLoading()
                            UIAlertView.showAlertViewNetworkIssues(self)
                        })
                    } else {
                        if let uid = result["uid"] as? String {
                            //Set user as Truck driver
                            Firebase(url: "https://trucktracker.firebaseio.com/Users/\(uid)").childByAppendingPath("isDriver").setValue(true)
                            //Create a new truck
                            var newdict = [String: AnyObject]()
                            newdict = ["email": add.textFields![0].text!,"password": add.textFields![1].text!,"Name": add.textFields![2].text!,"Time": add.textFields![3].text!,"phoneNumber": add.textFields![6].text!, "latitude": Float(add.textFields![4].text!)!,"longitude": Float(add.textFields![5].text!)!,"truckDriver": uid]
                            myref.childByAutoId().setValue(newdict)
                            self.view.stopLoading()
                            dispatch_async(dispatch_get_main_queue(), {
                                self.view.stopLoading()
                                UIAlertView.showAlertView("Success", text: "Created a new truck driver and truck", vc: self)
                            })
                        }
                    }
            })
        })
        add.addAction(ok)
        /*let nothing = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
        })
        add.addAction(nothing)
        self.presentViewController(add, animated: true, completion: {
            add.view.tintColor = UIColor.mydarkPinkColor
        })*/
        self.presentViewController(add, animated: true, completion: nil)
    

    }
    
    
    func logout() {
        let logout = UIAlertController(title: "Logout", message: "Would you like to logout of the app?", preferredStyle: UIAlertControllerStyle.Alert)
        logout.view.tintColor = UIColor.redColor()
        
        let call = UIAlertAction(title: "Logout", style: UIAlertActionStyle.Destructive, handler: { action in
            Firebase(url:"https://trucktracker.firebaseio.com").unauth()
            self.navigationController?.popToRootViewControllerAnimated(false)
        })
        logout.addAction(call)
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action -> Void in
        })
        logout.addAction(cancel)
        
        self.presentViewController(logout, animated: true, completion: nil)
    }
    
    func showMap() {
        self.LocationOptions.hidden = false
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneMapSettings")
    }
    
    func doneMapSettings() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "location_map"), style: UIBarButtonItemStyle.Plain, target: self, action: "showMap")
        self.LocationOptions.hidden = true
        self.addresstextField.hidden = true
        self.navigationItem.hidesBackButton = true
    }
  
    func convertAddressToLatLon(aAddress: String, save: Bool) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(aAddress, completionHandler: {(placemarks, error) -> Void in
            let placemark = placemarks?.first
            let location = placemark?.location
            if let _ = location {
                self.addresstextField.text = aAddress
                self.cancel()
                self.mapView.showsUserLocation = false
                self.addUserAnnotationWithCoordinates(location!)
                NSUserDefaults.standardUserDefaults().setValue(aAddress, forKey: "UsercustomAddress")
                //UserLocation.manager.locationManager.stopUpdatingLocation()
                
                if self.istruckoperator {
                    self.saveStoreDetailsInServerWithLocation(location!)
                }
            } else {
                self.mapView.showsUserLocation = true
                UIAlertView.showAlertView("Invalid Location", text: "Please re enter again.", vc: self)
                print("cannot find location for this text")
            }
        })
    }
    
    func saveStoreDetailsInServerWithLocation(location: CLLocation) {
        if self.mapAnnotation.count > 0 {
            let truck = self.mapAnnotation[0]
            Firebase(url:"https://trucktracker.firebaseio.com/Trucks/\(truck.id!)/latitude").setValue(location.coordinate.latitude)
            Firebase(url:"https://trucktracker.firebaseio.com/Trucks/\(truck.id!)/longitude").setValue(location.coordinate.longitude)
        }
    }
    
    @IBAction func cancel() {
        if self.isEditMode {
            self.isEditMode = false
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "map"), style: UIBarButtonItemStyle.Plain, target: self, action: "editsave")
            self.LocationOptions.hidden = true
            self.addresstextField.resignFirstResponder()
            self.addresstextField.hidden = true
        }
    }

    func addUserAnnotationWithCoordinates(aLocation: CLLocation)
    {
        if let exists = self.userAnnotation {
            self.mapView.removeAnnotation(exists)
        }
        let aMapAnnotation = MapAnnotation(coordinate: aLocation.coordinate, title: "Me", subtitle: self.LocationOptions.selectedSegmentIndex == 0 ? "Current Location" : self.addresstextField.text!)
        self.userAnnotation = aMapAnnotation
        print("Did get new address location")
        if self.istruckoperator {
            self.saveStoreDetailsInServerWithLocation(aLocation)
        }
            //self.location.stopUpdatingLocation()
        self.getTruckLocations()
    }

    //user location delegate methods
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let exists = self.userAnnotation {
            self.mapView.removeAnnotation(exists)
        }
        let l = locations.last
        let aMapAnnotation = MapAnnotation(coordinate: l!.coordinate, title: "Me", subtitle: "Current Location")
        self.userAnnotation = aMapAnnotation
        print("Did get user location")
        if self.istruckoperator {
            self.saveStoreDetailsInServerWithLocation(locations.last!)
        }
        if istruckoperator || self.mapAnnotation.count == 0 {
            self.getTruckLocations()
        }
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    //Clearing the Map and adding new locations to the Map
    func addTruckAnnotationWithCoordinates(aLocation: [MapAnnotation])
    {
        for each in self.mapAnnotation {
            self.mapView.removeAnnotation(each)
        }
        
        self.mapAnnotation = []
        
        self.mapAnnotation = aLocation
        
        if let exists = self.userAnnotation {
            if !self.istruckoperator {
                var newArray = self.mapAnnotation
                newArray.append(exists)
                self.mapView.showAnnotations(newArray, animated: true)
            } else {
                self.mapView.showAnnotations([exists], animated: true)
            }
        }
    }

    //Parsing
    func updateLocationOnMap(snapshot: FDataSnapshot) {
        if let trucks = snapshot.value as? NSDictionary {
            var locations = [MapAnnotation]()
            for (key, value) in trucks {
                print("current key is \(key)")
                if let truckname =  value["Name"] as? String {
                    if let sub = value["Time"] as? String {
                        if let lat = value["latitude"] as? Double {
                            if let long = value["longitude"] as? Double {
                                let location = CLLocation(latitude: lat, longitude: long)
                                let aMapAnnotation = MapAnnotation(coordinate: location.coordinate, title: truckname, subtitle: sub)
                                aMapAnnotation.id = key as! String
                                if let menu = value["Menu"] as? NSDictionary {
                                    aMapAnnotation.menu = menu
                                }
                                if let phone = value["phoneNumber"] as? String {
                                    aMapAnnotation.phoneNumber = phone
                                }
                                if self.istruckoperator {
                                    if let id = value["truckDriver"] as? String {
                                        if id == self.currentUserId {
                                            locations.append(aMapAnnotation)
                                        }
                                    }
                                } else {
                                    locations.append(aMapAnnotation)
                                }
                            }
                        }
                    }
                }
                
            }
            self.addTruckAnnotationWithCoordinates(locations)
        }
    }

    //Getting data from Parse
    func getTruckLocations(){
        ref.observeEventType(.Value, withBlock: { snapshot in
            print("Inial Value \(snapshot.value)")
            dispatch_async(dispatch_get_main_queue(), {
                self.view.stopLoading()
            })
            self.updateLocationOnMap(snapshot)
            },
            withCancelBlock: { error in
                dispatch_async(dispatch_get_main_queue(), {
                    self.view.stopLoading()
                })
                print(error.description)
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? MenuViewController {
            if let truck = sender as? MapAnnotation {
                vc.currentTruck = truck
                vc.allowsEditing = self.istruckoperator || self.isadmin
                vc.currentUser = self.currentUserId
            }
        }
    }
    
    
}

//MARK: MKMapViewDelegateMethods
// Location & directions
extension ThirdVC {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        
        if let _ = annotation as? MKUserLocation {
            return nil
        } else {
            let identifier = "myAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
            if annotationView != nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = annotation
            }
            
            annotationView?.canShowCallout = true
            
            //annotationView?.rightCalloutAccessoryView =
            return annotationView
        }
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for each in views {
            if let ma = each.annotation as? MapAnnotation {
                if ma.title! == "Me" && !self.istruckoperator{
                    each.tintColor = UIColor.blueColor()
                    //each.image = UIImage(named: "userpin")?.tintWithColor(UIColor.darkPinkCielColor)
                } else {
                    each.tintColor = UIColor.orangeColor()
                    each.image = UIImage(named: "truckIcon")?.tintWithColor(UIColor.redColor())
                    each.canShowCallout = true
                    each.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
                    self.mapView.selectAnnotation(each.annotation!, animated: true)
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let truckFeatures = UIAlertController(title: "Food Truck", message: "Would you like to contact us?", preferredStyle: UIAlertControllerStyle.Alert)
        truckFeatures.view.tintColor = UIColor.mydarkPinkColor
        
        // truckFeatures.view.
        if isadmin{
            let deleteTruck = UIAlertAction(title: "Delete TRUCK", style: UIAlertActionStyle.Default, handler: { action in
                //Show alert message
                let deleteAction = UIAlertController(title: "Delete Truck", message: "Would you like to really delete the Truck?", preferredStyle: UIAlertControllerStyle.Alert)
                truckFeatures.view.tintColor = UIColor.mydarkPinkColor
                
                let deleteTruck = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: { action in
                    for each in self.mapAnnotation {
                        if each == view.annotation as? MapAnnotation {
                            Firebase(url: "https://trucktracker.firebaseio.com/Trucks/\(each.title!)").setValue(nil)
                        }
                    }
                    })
                deleteAction.addAction(deleteTruck)
                
                let cancel = UIAlertAction(title: "NO!", style: UIAlertActionStyle.Cancel, handler: { action in
                })
                deleteAction.addAction(cancel)
                
                self.presentViewController(deleteAction, animated: true, completion: nil)
            })
            
            truckFeatures.addAction(deleteTruck)
        }
        
        let call = UIAlertAction(title: "Call Truck", style: UIAlertActionStyle.Default, handler: { action in
            for each in self.mapAnnotation {
                if each == view.annotation as? MapAnnotation {
                    UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(each.phoneNumber!)")!)
                }
            }
        })
        truckFeatures.addAction(call)
        
        let order = UIAlertAction(title: "Menu", style: UIAlertActionStyle.Default, handler: { action in
            if self.istruckoperator {
                self.performSegueWithIdentifier("showMenu", sender: self.mapAnnotation[0])
            } else {
                for each in self.mapAnnotation {
                    if each == view.annotation as? MapAnnotation {
                        self.performSegueWithIdentifier("showMenu", sender: each)
                    }
                }
            }
        })
        truckFeatures.addAction(order)
        
        let directions = UIAlertAction(title: "Get Directions", style: UIAlertActionStyle.Default, handler: { action in
            let directVia = UIAlertController(title: "Show Directions with", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            directVia.view.tintColor = UIColor.mydarkPinkColor
            // truckFeatures.view.
            var findDirections = true
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied {
                findDirections = false
                if let _ = self.userAnnotation {
                    findDirections = true
                } else {
                    UIAlertView.showAlertView("Location not authorized", text: " needs you to give access to location for providing directions to the truck. Settings -> Ciel -> Turn on Location For 'Ciel' ", vc: self)
                }
            }
            if findDirections {
                let google = UIAlertAction(title: "Google Maps", style: UIAlertActionStyle.Default, handler: { action in
                    for each in self.mapAnnotation {
                        if each == view.annotation as? MapAnnotation {
                            UIApplication.sharedApplication().openURL(NSURL(string: "comgooglemaps://?saddr=\(self.userAnnotation!.coordinate.latitude),\(self.userAnnotation!.coordinate.longitude)&daddr=\(each.coordinate.latitude),\(each.coordinate.longitude)&directionsmode=driving")!)
                        }
                    }
                })
                if UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!) {
                    directVia.addAction(google)
                }
                let apple = UIAlertAction(title: "Apple Maps", style: UIAlertActionStyle.Default, handler: { action in
                    for each in self.mapAnnotation {
                        if each == view.annotation as? MapAnnotation {
                            UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/?saddr=\(self.userAnnotation!.coordinate.latitude),\(self.userAnnotation!.coordinate.longitude)&daddr=\(each.coordinate.latitude),\(each.coordinate.longitude)&dirflg=d")!)
                        }
                    }
                })
                if UIApplication.sharedApplication().canOpenURL(NSURL(string: "http://maps.apple.com/")!) {
                    directVia.addAction(apple)
                }
                let nothing = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
                })
                directVia.addAction(nothing)
                self.presentViewController(directVia, animated: true, completion: {
                    directVia.view.tintColor = UIColor.mydarkPinkColor
                })
            }
        })
        truckFeatures.addAction(directions)
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
        })
        truckFeatures.addAction(cancel)
        
        self.presentViewController(truckFeatures, animated: true, completion: {
            truckFeatures.view.tintColor = UIColor.mydarkPinkColor
        })
    }
    
    func showDirections() {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: self.userAnnotation!.coordinate, addressDictionary: nil))
        //request.destination = MKMapItem(placemark: MKPlacemark(coordinate: self.mapAnnotation!.coordinate, addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .Automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blueColor()
        return renderer
    }
}

extension ThirdVC {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let exists = textField.text {
            self.convertAddressToLatLon(exists, save: false)
        }
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
}



