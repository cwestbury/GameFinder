//
//  AddGameViewController.swift
//  Final
//
//  Created by Cameron Westbury on 11/30/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

import UIKit
import CoreLocation
import ParseUI
import Parse
import MapKit


class AddGameViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
   
    //MARK: - Properties
    var servManager = serverManager.sharedInstance
    var locManager = LocationManager.sharedInstance
    var newGameLat = 0.0 as Double
    var newGameLong = 0.0 as Double
    
    @IBOutlet var addGameMap: MKMapView!
    
    
    //MARK: - Functions
    
    func centerMapView() {
        locManager.centerMapView(addGameMap)
    }
    
    

    func alertView() {
        let alert = UIAlertController(title: "Add New Game", message: "Give the game a location by using the search bar or pressing on the map", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
  
    //MARK: - Map Methods
    
    func removePins() {
        var pins: [MKAnnotation] = NSArray(array: addGameMap.annotations) as! [MKAnnotation]
        addGameMap.removeAnnotations(pins)
        pins.removeAll()
    }
    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isMemberOfClass(MKUserLocation.self) {
            return nil
        } else {
            let identifier = "pin"
            var pin = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
            if pin == nil {
                pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                pin!.canShowCallout = true
                pin!.pinTintColor = UIColor.blueColor()
                pin!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            pin!.annotation = annotation
            return pin
        }
        
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
       servManager.saveGeoPoint(newGameLat, long: newGameLong)
         self .performSegueWithIdentifier("gameDetails", sender: self)
    }
    
    
    //MARK: - Interactivity
    
    
    @IBAction func tapForCoordinates(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.Began { return }
        removePins()
        let touchLocation = sender.locationInView(addGameMap)
        let locationCoordinate = addGameMap.convertPoint(touchLocation, toCoordinateFromView: addGameMap)
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
        newGameLat = locationCoordinate.latitude
        newGameLong = locationCoordinate.longitude
        
        let tappedLocation = CLLocationCoordinate2DMake(locationCoordinate.latitude, locationCoordinate.longitude)
        let gamePin = MKPointAnnotation()
        gamePin.coordinate = tappedLocation
        gamePin.title = "Click Here ->"
        addGameMap.addAnnotation(gamePin)
        
    }
    
    // viewForAnnotation - drop animation
    
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGameMap.showsUserLocation = true
        centerMapView()
        alertView()
     

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
