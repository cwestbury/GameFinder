//
//  ViewController.swift
//  Final
//
//  Created by Cameron Westbury on 11/24/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

import UIKit
import ParseUI
import Parse
import CoreLocation
import MapKit


class ViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var gameMap: MKMapView!
    @IBOutlet var loginButton : UIBarButtonItem!
    
    var loggedIN = false
    
    var locManger = LocationManager.sharedInstance
    var servManger = serverManager.sharedInstance
    var RSSParser = rssParser.sharedInstance
    
    
    
    //MARK: - Login Methods
    
    @IBAction func loginButtonPresesd(sender:UIBarButtonItem) {
        if let _ = PFUser.currentUser() {
            PFUser.logOut()
            loginButton.title = "Login"
        } else {
            let loginVC = PFLogInViewController()
            loginVC.delegate = self
            let signUpVC = PFSignUpViewController()
            signUpVC.delegate = self
            loginVC.signUpController = signUpVC
            presentViewController(loginVC, animated: true, completion: nil)
        }
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        dismissViewControllerAnimated(true, completion: nil)
        loginButton.title = "Log Out"
        
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Map Methods
    
    @IBAction func centerMapView() {
        locManger.centerMapView(gameMap)
    }
    
    
    // not working??
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
    
    func placeLocationsOnMapViaParse(gameArray:[PFObject]) {
        for game in gameArray {
            let loc = game["GameCoords"] as! PFGeoPoint
            let gamePin = MKPointAnnotation()
            let coords = CLLocationCoordinate2DMake(loc.latitude, loc.longitude)
            gamePin.coordinate = coords
            gamePin.title = game["Title"] as? String
            gameMap.addAnnotation(gamePin)
        }
    }
    
    func removePins() {
        var pins: [MKAnnotation] = NSArray(array: gameMap.annotations) as! [MKAnnotation]
        gameMap.removeAnnotations(pins)
        pins.removeAll()
    }
    func currentLocationRecieved() {
        RSSParser.getGameInfo()
    }
    
    func addGamesToMap() {
        print("adding Parsed Games")
        //let GamesToParse = Games()
        for GamesToParse in RSSParser.gameArray {
            print("For Loop \(GamesToParse.Title) lat \(GamesToParse.GameLat) lon \(GamesToParse.GameLong)")
            locManger.addMapPins(gameMap, lat: GamesToParse.GameLat, long: GamesToParse.GameLong, Title: GamesToParse.Title)
        }
    }
    
    
    //MARK: - LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locManger.setUpLocationMonitoring()
        gameMap.showsUserLocation = true
        centerMapView()
        removePins()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentLocationRecieved", name: "recievedLocationFromUser", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addGamesToMap", name: "parsedGameData", object: nil)
        servManger.getGameLocation()

    }
    
    override func viewDidAppear(animated: Bool) {
        placeLocationsOnMapViaParse(servManger.gameArray)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

