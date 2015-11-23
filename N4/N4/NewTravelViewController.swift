//
//  NewTravelViewController.swift
//  N4
//
//  Created by Teclógica Serviços em Informática LTDA on 18/11/15.
//  Copyright © 2015 FURB. All rights reserved.
//

import UIKit
import CoreData

class NewTravelViewController: UIViewController {

    @IBOutlet weak var travelName: UITextField!    
    @IBOutlet weak var secure: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mapUnwindSegue" {
            if let travelName = self.travelName.text {
                self.createTravel(travelName)
                self.prepareMapView(segue.destinationViewController as! MapViewController)
            }
        }
    }
    
    func prepareMapView(mapViewController:MapViewController) {
        mapViewController.travelName = self.travelName.text
        mapViewController.isSecure = self.secure.on
        mapViewController.isEnded = false
    }
    
    func createTravel(travelName:String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let travel =  NSEntityDescription.insertNewObjectForEntityForName("Travel", inManagedObjectContext: managedContext)
        travel.setValue(travelName, forKey: "name")
        travel.setValue(self.secure.on, forKey: "secure")
        
        try! managedContext.save()
    }
}
