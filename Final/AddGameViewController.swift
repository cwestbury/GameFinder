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


class AddGameViewController: UIViewController, CLLocationManagerDelegate {
   
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
    
    func addAnnotation (Lat:Double, Long:Double) {
        let gameLocation = CLLocationCoordinate2DMake(Lat, Long)
        let gamePin = MKPointAnnotation()
        gamePin.coordinate = gameLocation
        gamePin.title = "New Game Location"
    }
    
    @IBAction func tapForCoordinates(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.Began { return }
        let touchLocation = sender.locationInView(addGameMap)
        let locationCoordinate = addGameMap.convertPoint(touchLocation, toCoordinateFromView: addGameMap)
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
        let tappedLocation = CLLocationCoordinate2DMake(locationCoordinate.latitude, locationCoordinate.longitude)
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = tappedLocation
        addGameMap.addAnnotation(dropPin)
        
    }
    
    
    //MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
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
