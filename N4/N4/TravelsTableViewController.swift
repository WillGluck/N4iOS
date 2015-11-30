//
//  TravelsTableViewController.swift
//  N4
//
//  Created by Teclógica Serviços em Informática LTDA on 18/11/15.
//  Copyright © 2015 FURB. All rights reserved.
//

import UIKit
import CoreData

/**
 View Controller responsável pela tela de lista de viagens
 */
class TravelsTableViewController: UITableViewController {
    
    /** Lista de viagens. */
    var travels = [NSManagedObject]()
    /** Última viagem selecionada. */
    var selectedTravel:NSManagedObject?
    
    //Controller's
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTravels()
    }
    
    override func viewDidAppear(animated:Bool) {
        super.viewDidAppear(animated)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.travels.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("travel", forIndexPath: indexPath) as! TravelTableViewCell
        let travel = self.travels[indexPath.row]
        let isSecureText = (travel.valueForKey("secure") as! Bool) ? " (secure) " : ""
        let isFinishedText = (travel.valueForKey("finished") as! Bool) ? " - finished" : ""
        let text = "\(travel.valueForKey("name") as! String)\(isSecureText)\(isFinishedText)"
        cell.travelName.text = text
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedTravel = travels[indexPath.row]
    }
    
    
    
    //Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard let tableView = sender as? UITableViewCell else {
            return
        }
        guard let index = self.tableView.indexPathForCell(tableView) else {
            return
        }
        
        self.selectedTravel = self.travels[index.row]
        
        if segue.identifier == "travelsUnwindSegue" {
            self.prepareMapView(segue.destinationViewController as? MapViewController)
        }
    }
    
    //Métodos
    
    /**
    Carrega as viagens.
    */
    func loadTravels() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Travel")
        self.travels = try! managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
    }
    
    /**
     Prepara o MapViewController com a viagem selecionada.
     - Parameter mapViewController: Referência ao viewController a ser configurado.
     */
    func prepareMapView(mapViewController:MapViewController?) {
        if let mapView = mapViewController {
            mapView.loadTravel(self.selectedTravel!.valueForKey("name") as! String)
        }
    }
}
