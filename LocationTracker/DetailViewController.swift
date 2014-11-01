//
//  DetailViewController.swift
//  LocationTracker
//
//  Created by Aditya Bansod on 10/20/14.
//  Copyright (c) 2014 Aditya Bansod. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var location: PlaceAndLocation!
    @IBOutlet weak var mapView: MKMapView!
    
    typealias JSON = AnyObject
    typealias JSONDictionary = Dictionary<String, JSON>
    typealias JSONArray = Array<JSON>
    


    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        let pin = MapAnnotation(coordinate: location.location.coordinate, title: location.name)
        mapView.addAnnotation(pin)
        mapView.delegate = self
        
        let coordiateRegion = MKCoordinateRegionMake(location.location.coordinate, MKCoordinateSpanMake(0.01, 0.01))
        
        mapView.setRegion(coordiateRegion, animated: false)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is MapAnnotation {
            var pinView:MKPinAnnotationView = MKPinAnnotationView()
            pinView.annotation = annotation
            pinView.pinColor = MKPinAnnotationColor.Red
            pinView.animatesDrop = true
            pinView.canShowCallout = true
            pinView.enabled = true
            
            //mapView.selectAnnotation(annotation, animated: true)

            
            let button: UIButton = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIButton
            button.addTarget(self, action: "disclosureButtonTapped:", forControlEvents: .TouchUpInside)
            pinView.rightCalloutAccessoryView = button as UIView
            
            return pinView
        }
        else {
            return nil
        }
        
    }
    
    func disclosureButtonTapped(sender: UIButton!) {
        UIApplication.sharedApplication().openURL(location.url!)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

