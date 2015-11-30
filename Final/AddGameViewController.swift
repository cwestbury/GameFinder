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
import MapKit


class AddGameViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
   
    //MARK: - Properties
    var locManager = LocationManager.sharedInstance
    @IBOutlet var addGameMap: MKMapView!
    
    //MARK: Functions
    
    func centerMapView() {
        locManager.centerMapView(addGameMap)
    }
    
    

    func aletView() {
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

    
    @IBAction func tapForCoordinates(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.Began { return }
        removePins()
        let touchLocation = sender.locationInView(addGameMap)
        let locationCoordinate = addGameMap.convertPoint(touchLocation, toCoordinateFromView: addGameMap)
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
        let tappedLocation = CLLocationCoordinate2DMake(locationCoordinate.latitude, locationCoordinate.longitude)
        // Loop through and remove all old pins
        let gamePin = MKPointAnnotation()
        gamePin.coordinate = tappedLocation
        gamePin.title = "New Game"
        addGameMap.addAnnotation(gamePin)
        
    }
    
    // viewForAnnotation - drop animation
    
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //addGameMap.removeAnnotations
        addGameMap.showsUserLocation = true
        centerMapView()
        aletView()
     

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
