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

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var travelName:String!
    var isSecure:Bool = false
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.travelName = ""
        self.isSecure = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) throws {

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let location =  NSEntityDescription.entityForName("location", inManagedObjectContext:managedContext)
        let fetchRequest = NSFetchRequest(entityName: "Travel")
        let predicate = NSPredicate(format: "name = %@", self.travelName)
        fetchRequest.predicate = predicate
        let travel = try managedContext.executeFetchRequest(fetchRequest)[0]
        
        var latitude = userLocation.coordinate.latitude
        var longitude = userLocation.coordinate.longitude
        
        if travel.valueForKey("secure") as! Bool {
            
            let dataLatitude = NSMutableData(capacity: 0)!
            let dataLongitude = NSMutableData(capacity: 0)!
            dataLatitude.appendBytes(&latitude, length: sizeof(CLLocationDegrees))
            dataLongitude.appendBytes(&longitude, length: sizeof(CLLocationDegrees))
            
            let encryptor = AES128Encryptor()
            try encryptor.encrypt(dataLatitude).getBytes(&latitude, length: sizeof(CLLocationDegrees))
            try encryptor.encrypt(dataLongitude).getBytes(&longitude, length: sizeof(CLLocationDegrees))
        }
        
        location?.setValue(travel, forKey: "travel")
        location?.setValue(latitude, forKey: "longitude")
        location?.setValue(userLocation.coordinate.latitude, forKey: "latitude")
        
        let _ = NSManagedObject(entity: location!, insertIntoManagedObjectContext: managedContext)
        try! managedContext.save()
        
        self.loadMap(managedContext)
        
    }
    
    func loadMap(managedContext:NSManagedObjectContext) {
        do {
            let fetchRequest = NSFetchRequest(entityName: "Location")
            let predicate = NSPredicate(format: "title = %@", self.travelName)
            fetchRequest.predicate = predicate
            
            let results = try managedContext.executeFetchRequest(fetchRequest)
            let locations = results as! [NSManagedObject]
            for location in locations {
                
                let annotation = MKPointAnnotation()
                var latitude = location.valueForKey("latitude") as! CLLocationDegrees
                var longitude = location.valueForKey("longitude") as! CLLocationDegrees
                
                if isSecure {
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
    
    @IBAction func mapReturns(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
    }
}

