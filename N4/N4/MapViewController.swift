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
    
    var managedContext:NSManagedObjectContext!
    var travel:NSManagedObject?
    
    @IBOutlet weak var finishTravelButton: UIButton!
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
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.loadMap()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.startUpdatingLocation()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedContext = appDelegate.managedObjectContext
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func finishTravel(sender: UIButton) {
        travel!.setValue(true, forKey: "finished")
        try! managedContext.save()
        sender.enabled = false
    }
    
    func loadTravel(travelName:String) {
        let fetchRequest = NSFetchRequest(entityName: "Travel")
        let predicate = NSPredicate(format: "name = %@", travelName)
        fetchRequest.predicate = predicate
        self.finishTravelButton.enabled = true
        self.travel = try! managedContext.executeFetchRequest(fetchRequest).first as? NSManagedObject
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        if let travel = self.travel {
            if !(travel.valueForKey("finished") as! Bool) {
                
                let locationEntity =  NSEntityDescription.entityForName("Location",inManagedObjectContext: managedContext)
                let userLocation = newLocation
                let location = NSManagedObject(entity: locationEntity!, insertIntoManagedObjectContext:managedContext)
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
                
                location.setValue(travel, forKey: "travel")
                location.setValue(latitude, forKey: "latitude")
                location.setValue(longitude, forKey: "longitude")
                
                try! self.addLocationAnnotation(location)
                try! managedContext.save()
                
                self.loadMap()

            }
        }

    }
    
    func addLocationAnnotation(location:NSManagedObject) throws {
        if let travel = self.travel {
            let annotation = MKPointAnnotation()
            var latitude = location.valueForKey("latitude") as! CLLocationDegrees
            var longitude = location.valueForKey("longitude") as! CLLocationDegrees
            
            if travel.valueForKey("secure") as! Bool {
                let dataLatitude = NSMutableData(capacity: 0)!
                let dataLongitude = NSMutableData(capacity: 0)!
                dataLatitude.appendBytes(&latitude, length: sizeof(CLLocationDegrees))
                dataLongitude.appendBytes(&longitude, length: sizeof(CLLocationDegrees))
                
                let encryptor = AES128Encryptor()
                let _ = try? encryptor.decrypt(dataLatitude).getBytes(&latitude, length: sizeof(CLLocationDegrees))
                let _ = try? encryptor.decrypt(dataLongitude).getBytes(&longitude, length: sizeof(CLLocationDegrees))
            }
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func loadMap() {
        if let travel = self.travel {
            do {
                let locations = travel.mutableSetValueForKey("locations")
                
                for location in locations {
                    try self.addLocationAnnotation(location as! NSManagedObject)
                }
            } catch let error as NSError {
                print("Could not fetch locations \(error), \(error.userInfo)")
            }
        }

    }
    
    @IBAction func mapReturns(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
    }   

}

