//
//  MasterViewController.swift
//  LocationTracker
//
//  Created by Aditya Bansod on 10/20/14.
//  Copyright (c) 2014 Aditya Bansod. All rights reserved.
//

import UIKit
import CoreLocation

class MasterViewController: UITableViewController,CLLocationManagerDelegate {

    var objects = NSMutableArray()
    
    var locationManager:CLLocationManager?
    var locations: PlaceCollection = PlaceCollection.createOrLoadLocationFromStorage()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startMonitoringSignificantLocationChanges()
                
        if locations.places.count > 0 { // we already had some data, reload the view
            self.tableView.reloadData()
        }
    }

    @IBAction func clearButtonTapped(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Clear All", message: "Are you sure you wish to clear all suggestions?", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            println("clear cancelled")
        }
        alert.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Clear", style: .Destructive) { (action) in
            self.locations = PlaceCollection()
            self.locations.save()
            self.tableView.reloadData()
        }
        alert.addAction(destroyAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewLocation(place: PlaceAndLocation) {
        if(!locations.exists(place)) {
            self.locations.places.insert(place, atIndex: 0)
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            self.tableView.reloadData()
            locations.save()
        }
    }
    
    func lookupLocationInFourSquare(location: CLLocation) {
        let coordinate = location.coordinate
        
        /* 
            4d4b7105d754a06374d81259 - food
            4d4b7104d754a06370d81259 - arts and entertainment
            4d4b7105d754a06376d81259 - nightlife
        */
        
        let url = NSURL(string: "https://api.foursquare.com/v2/venues/search?client_id=OVKVVXIZOYQLBPHQBORX1ZL5IZUYNZ1UOYW5URULAO3X3DPN&client_secret=VMZHWMJVXKMCQX3TSLBHJ5DJ0M0MWNQXT0OPVPERTUVEZK4M&ll=\(coordinate.latitude),\(coordinate.longitude)&intent=browse&radius=500&categoryid=4d4b7105d754a06374d81259,4d4b7104d754a06370d81259,4d4b7105d754a06376d81259&v=20140806&m=foursquare")
        
        var jsonError: NSError?
        
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            if let results = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &jsonError) as? NSDictionary {
                if let response = results["response"] as? NSDictionary {
                    if let venues = response["venues"] as? NSArray {
                        if let closestVenue = venues[0] as? NSDictionary {
                            if let name = closestVenue["name"] as? String {
                                if let id = closestVenue["id"] as? String {
                                    let thisPlace = PlaceAndLocation(location: location, name: name,  id: id)
                                    self.insertNewLocation(thisPlace)
                                }
                            }
                        }
                    }
                }
            }
            
        }
        task.resume()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("failed with error \(error)")
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        lookupLocationInFourSquare(locations.last as CLLocation)
    }
    
    func locationManager(manager: CLLocationManager!, didVisit visit: CLVisit!) {
        println("entered \(visit.arrivalDate) exited \(visit.departureDate)")
        //lookupLocationInFourSquare(visit.coordinate)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let location = locations.places[indexPath.row] as PlaceAndLocation
                (segue.destinationViewController as DetailViewController).location = location
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.places.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        //let object = objects[indexPath.row] as NSDate
        cell.textLabel.text = (locations.places[indexPath.row] as PlaceAndLocation).name
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }


}

