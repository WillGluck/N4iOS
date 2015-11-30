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

/**
 View Controller responsável pela tela de exibição do mapa.
 */
class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    //Atributos
    
    /** Contexto Core Data. */
    var managedContext:NSManagedObjectContext!
    /** Referência ao objeto de viagens. */
    var travel:NSManagedObject?
    /** Botão de finalizar viagem */
    @IBOutlet weak var finishTravelButton: UIButton!
    /** Lazy load do locationManager */
    lazy var locationManager:CLLocationManager! = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.delegate = self
        manager.requestAlwaysAuthorization()
        return manager
    }()
    /** MapView */
    @IBOutlet weak var mapView: MKMapView!
    
    //Overrides
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.mapView.removeAnnotations(self.mapView.annotations)
        locationManager.startUpdatingLocation()
        self.loadMap()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.finishTravelButton.enabled = false
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.managedContext = appDelegate.managedObjectContext
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Métodos
    
    /**
    Realiza a finalização de uma viagem.
    - Parameter sender: Botão que dispara a ação
    */
    @IBAction func finishTravel(sender: UIButton) {
        travel!.setValue(true, forKey: "finished")
        try! managedContext.save()
        sender.enabled = false
    }
    
    /**
    Carrega a viagem que possui o nome passado no atributo travel da classe.
     - Parameter travelName: nome da viagem a ser carregada.
    */
    func loadTravel(travelName:String) {
        let fetchRequest = NSFetchRequest(entityName: "Travel")
        let predicate = NSPredicate(format: "name = %@", travelName)
        fetchRequest.predicate = predicate
        self.travel = try! managedContext.executeFetchRequest(fetchRequest).first as? NSManagedObject
        self.finishTravelButton.enabled = !(self.travel!.valueForKey("finished") as! Bool)
    }
    
    /**
     Adiciona a localização passada ao mapa.
     - Parameter location: Localização a ser adicionada.
     - Throws
     */
    func addLocationAnnotation(location:NSManagedObject) throws {
        if let travel = self.travel {
            let annotation = MKPointAnnotation()
            var dataLatitude:NSData = location.valueForKey("latitude") as! NSData
            var dataLongitude:NSData = location.valueForKey("longitude") as! NSData
            
            if travel.valueForKey("secure") as! Bool {
                
                let encryptor = AES128Encryptor()
                dataLatitude = try! encryptor.decrypt(dataLatitude)
                dataLongitude = try! encryptor.decrypt(dataLongitude)
            }
            
            var latitude:Double = 0.0
            var longitude:Double = 0.0
            
            dataLatitude.getBytes(&latitude, length: sizeof(Double))
            dataLongitude.getBytes(&longitude, length: sizeof(Double))
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            self.mapView.addAnnotation(annotation)
        }
    }
    
    /**
    Carrega o mapa com todas as localizações da viagem ativa.
     */
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
    
    //Implementação do protocolo CLLocationManagerDelegate

    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        
        if let travel = self.travel {
            if !(travel.valueForKey("finished") as! Bool) {
                
                let locationEntity =  NSEntityDescription.entityForName("Location",inManagedObjectContext: managedContext)
                let userLocation = newLocation
                let location = NSManagedObject(entity: locationEntity!, insertIntoManagedObjectContext:managedContext)
                var latitude:Double = userLocation.coordinate.latitude
                var longitude:Double = userLocation.coordinate.longitude
                
                var dataLatitude = NSMutableData(capacity: 0)!
                var dataLongitude = NSMutableData(capacity: 0)!
                
                dataLatitude.appendBytes(&latitude, length: sizeof(Double))
                dataLongitude.appendBytes(&longitude, length: sizeof(Double))
                
                if travel.valueForKey("secure") as! Bool {
                    
                    let encryptor = AES128Encryptor()
                    dataLatitude  = NSMutableData(data:try! encryptor.encrypt(dataLatitude))
                    dataLongitude = NSMutableData(data:try! encryptor.encrypt(dataLongitude))
                }
                
                location.setValue(travel, forKey: "travel")
                location.setValue(dataLatitude, forKey: "latitude")
                location.setValue(dataLongitude, forKey: "longitude")
                
                try! self.addLocationAnnotation(location)
                try! managedContext.save()
                
                self.loadMap()
                
            }
        }
        
    }
    
    //Navigation.
    
    @IBAction func newTravelReturns(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        //Nothing
    }
    @IBAction func travelReturns(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        //Nothing
    }

}

