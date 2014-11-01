//
//  PlaceAndLocation.swift
//  LocationTracker
//
//  Created by Aditya Bansod on 10/27/14.
//  Copyright (c) 2014 Aditya Bansod. All rights reserved.
//

import UIKit
import CoreLocation

@objc
class PlaceAndLocation: NSObject, Printable, NSCoding {
    var location: CLLocation
    var name: String
    var id: String
    var url: NSURL? {
        get {
            let url = NSURL(string: "https://foursquare.com/v/\(id)")
            return url
        }
    }
    
    init(location: CLLocation, name: String, id: String) {
        self.location = location
        self.name = name
        self.id = id
    }
    
    required init(coder aDecoder: NSCoder) {
        self.location = aDecoder.decodeObjectForKey("location") as CLLocation
        self.name = aDecoder.decodeObjectForKey("name") as String
        self.id = aDecoder.decodeObjectForKey("id") as String
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(location, forKey: "location")
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(id, forKey: "id")
    }
    
    override var description: String {
        get {
            return name
        }
    }
}

class PlaceCollection: NSObject, NSCoding, Printable {
    var places = [PlaceAndLocation]()
    
    override init() {
        super.init()
    }
   
    
    required init(coder aDecoder: NSCoder) {
        self.places = aDecoder.decodeObjectForKey("listOfPlaces") as [PlaceAndLocation]
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(places, forKey: "listOfPlaces")
    }
    
    func save() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(self)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "savedPlaces")
    }
    
    func exists(placeToFind: PlaceAndLocation) -> Bool {
        for place in self.places {
            if place.id == placeToFind.id {
                return true
            }
        }
        return false
    }
    
    class func loadData() -> PlaceCollection? {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("savedPlaces") as? NSData {
            let dataSet:AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithData(data)
            let pcDataSet:PlaceCollection? = dataSet as? PlaceCollection
            return pcDataSet
        }
        return nil
    }
    
    class func createOrLoadLocationFromStorage() -> PlaceCollection {
        if let tempLoc = PlaceCollection.loadData() {
            return tempLoc
        } else {
            let locations = PlaceCollection()
            locations.save()
            return locations
        }
    }
    
    func clear() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("savedPlaces")
    }
    
    override var description: String {
        get {
            return "places has \(places.count) count"
        }
    }
    
}