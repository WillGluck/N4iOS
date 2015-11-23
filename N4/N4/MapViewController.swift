//
//  ViewController.swift
//  N4
//
//  Created by Teclógica Serviços em Informática LTDA on 09/11/15.
//  Copyright © 2015 FURB. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    var travelName:String?
    var isSecure:Bool = false
    var isEnded:Bool = true
    var managedContext:NSManagedObjectContext!
    
    lazy var locationManager:CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
    }()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedContext = appDelegate.managedObjectContext
        self.loadMap()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        locationManager.startUpdatingLocation()

    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        if let travelName = self.travelName {
            if !self.isEnded {
            
                let userLocation = newLocation
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let managedContext = appDelegate.managedObjectContext
                
                let location =  NSEntityDescription.entityForName("location", inManagedObjectContext:managedContext)
                let fetchRequest = NSFetchRequest(entityName: "Travel")
                let predicate = NSPredicate(format: "name = %@", travelName)
                fetchRequest.predicate = predicate
                let travel = try! managedContext.executeFetchRequest(fetchRequest)[0]
                
                var latitude = userLocation.coordinate.latitude
                var longitude = userLocation.coordinate.longitude
                
                if travel.valueForKey("secure") as! Bool {
                    
                    let dataLatitude = NSMutableData(capacity: 0)!
                    let dataLongitude = NSMutableData(capacity: 0)!
                    dataLatitude.appendBytes(&latitude, length: sizeof(CLLocationDegrees))
                    dataLongitude.appendBytes(&longitude, length: sizeof(CLLocationDegrees))
                    
                    let encryptor = AES128Encryptor()
                    try! encryptor.encrypt(dataLatitude).getBytes(&latitude, length: sizeof(CLLocationDegrees))
                    try! encryptor.encrypt(dataLongitude).getBytes(&longitude, length: sizeof(CLLocationDegrees))
                }
                
                location?.setValue(travel, forKey: "travel")
                location?.setValue(latitude, forKey: "longitude")
                location?.setValue(userLocation.coordinate.latitude, forKey: "latitude")
                
                let _ = NSManagedObject(entity: location!, insertIntoManagedObjectContext: managedContext)
                try! managedContext.save()
                
                self.loadMap()
            }
        }
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadMap() {
        if let travelName = self.travelName {
            do {
                let travelFetchRequest = NSFetchRequest(entityName: "Travel")
                let travelPredicate = NSPredicate(format: "name = %@", travelName)
                travelFetchRequest.predicate = travelPredicate
                let travel = try managedContext.executeFetchRequest(travelFetchRequest)
                
                let fetchRequest = NSFetchRequest(entityName: "Location")
                let locationPredicate = NSPredicate(format: "travel", argumentArray: travel)
                fetchRequest.predicate = locationPredicate
                
                let locationsResult = try managedContext.executeFetchRequest(fetchRequest)
                let locations = locationsResult as! [NSManagedObject]
                for location in locations {
                    
                    let annotation = MKPointAnnotation()
                    var latitude = location.valueForKey("latitude") as! CLLocationDegrees
                    var longitude = location.valueForKey("longitude") as! CLLocationDegrees
                    
                    if self.isSecure {
                        let dataLatitude = NSMutableData(capacity: 0)!
                        let dataLongitude = NSMutableData(capacity: 0)!
                        dataLatitude.appendBytes(&latitude, length: sizeof(CLLocationDegrees))
                        dataLongitude.appendBytes(&longitude, length: sizeof(CLLocationDegrees))
                        
                        let encryptor = AES128Encryptor()
                        try encryptor.decrypt(dataLatitude).getBytes(&latitude, length: sizeof(CLLocationDegrees))
                        try encryptor.decrypt(dataLongitude).getBytes(&longitude, length: sizeof(CLLocationDegrees))
                    }
                    
                    annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    self.mapView.addAnnotation(annotation)
                }
            } catch let error as NSError {
                print("Could not fetch locations \(error), \(error.userInfo)")
            }
        }

    }
    
    @IBAction func mapReturns(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
    }
    
    @IBAction func travelsReturns(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
    }
}

