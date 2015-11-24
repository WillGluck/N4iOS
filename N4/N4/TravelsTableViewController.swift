//
//  TravelsTableViewController.swift
//  N4
//
//  Created by Teclógica Serviços em Informática LTDA on 18/11/15.
//  Copyright © 2015 FURB. All rights reserved.
//

import UIKit
import CoreData

class TravelsTableViewController: UITableViewController {
    
    var travels = [NSManagedObject]()
    var selectedTravel:NSManagedObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        //self.tableView.registerClass(TravelTableViewCell.self, forCellReuseIdentifier: "TravelTableViewCell")
        self.loadTravels()
    }
    
    override func viewDidAppear(animated:Bool) {
        super.viewDidAppear(animated)

    }
    
    func loadTravels() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Travel")
        self.travels = try! managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.travels.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("travel", forIndexPath: indexPath) as! TravelTableViewCell
        // Configure the cell...
        let travel = self.travels[indexPath.row]
        cell.travelName.text = travel.valueForKey("name") as? String
        return cell
    }
    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        self.selectedTravel = travels[indexPath.row]
//    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
    
//    func prepareForSegue(segue: UIStoryboardSegue, sender: UITableViewCell?) {
//        
//        guard let tableView = sender else {
//            return
//        }
//        guard let index = self.tableView.indexPathForCell(tableView) else {
//            return
//        }
//        
//        self.selectedTravel = self.travels[index.row]
//        if segue.identifier == "travelsUnwindSegue" {
//            self.prepareMapView(segue.destinationViewController as! MapViewController)
//            self.dismissViewControllerAnimated(true, completion: nil)
//        }
//        
//        self.prepareMapView(segue.destinationViewController as! MapViewController)
//
//    }
    
    func prepareMapView(mapViewController:MapViewController?) {
        if let mapView = mapViewController {
            mapView.travelName = self.selectedTravel!.valueForKey("name") as? String
            mapView.isEnded = self.selectedTravel!.valueForKey("finished") as! Bool
            mapView.isSecure = self.selectedTravel!.valueForKey("secure") as! Bool
        }

    }


}
