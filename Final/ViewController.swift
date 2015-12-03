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


class ViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate {
    
    @IBOutlet var gameMap: MKMapView!
    @IBOutlet var loginButton : UIBarButtonItem!
    @IBOutlet var LocationSearchBar: UISearchBar!
    var selectedGame :Games!
    
    var loggedIN = false
    
    var locManger = LocationManager.sharedInstance
    var servManger = serverManager.sharedInstance
    var RSSParser = rssParser.sharedInstance
    
    var searchBarCity : String!
    
    
    
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
    
    //MARK: - Search Bar Methods 
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if LocationSearchBar.text != nil {
            locManger.getSearchedLocation(LocationSearchBar.text!)
           // searchedCity = locManger.searchedCity
            //print(searchedCity)
           // RSSParser.searchedNSURLString(locManger.searchedCity)
            searchBar.resignFirstResponder()
        }
    }
    
    func searchCity() {
        searchBarCity = locManger.searchedCity
        print("searchBar City: \(searchBarCity)")
        RSSParser.searchedNSURLString(searchBarCity)
        RSSParser.getGameInfo()
        locManger.centerMapOnSearch(gameMap)
    }
    
    
    
    
    //MARK: - Map Methods
    
    @IBAction func centerMapView() {
        locManger.centerMapView(gameMap)
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
        //servManager.saveGeoPoint(newGameLat, long: newGameLong)
        let annotation = view.annotation as! GamePointAnnotation
        selectedGame = annotation.pinGame
        self .performSegueWithIdentifier("gameDetailSegue", sender: self)
    }
    
    func placeLocationsOnMapViaParse(gameArray:[PFObject]) {
        for game in gameArray {
            let loc = game["GameCoords"] as! PFGeoPoint
            let gamePin = GamePointAnnotation()
            let coords = CLLocationCoordinate2DMake(loc.latitude, loc.longitude)
            gamePin.coordinate = coords
            gamePin.title = game["Title"] as? String
            //gamePin.subtitle = game["Descritpion"] as? String
           
            
            gameMap.addAnnotation(gamePin)
        }
    }
    
    func removePins() {
        var pins: [MKAnnotation] = NSArray(array: gameMap.annotations) as! [MKAnnotation]
        gameMap.removeAnnotations(pins)
        pins.removeAll()
    }
    
    
    
    func currentLocationRecieved() {
        RSSParser.currentLocationNSURLString()
        RSSParser.getGameInfo()
    }
    
    func addGamesToMap() {
        print("adding Parsed Games")
        //let GamesToParse = Games()
        removePins() //NOTE THIS IS REMOVING THE ADDED GAMES AS WELL
        for GamesToParse in RSSParser.gameArray {
           // print("For Loop \(GamesToParse.Title) lat \(GamesToParse.GameLat) lon \(GamesToParse.GameLong)")
            locManger.addMapPins(gameMap, lat: GamesToParse.GameLat, long: GamesToParse.GameLong, Title: GamesToParse.Title, game: GamesToParse)
        }
    }
    //MARK: - Segue Methods
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "gameDetailSegue"){
           let destController = segue.destinationViewController as! GameDetailsViewController
            destController.selectedGame = selectedGame
            
            //destController.GameDescription.text = RSSParser.gameArray.description
        }
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
//        if (segue.identifier == "YourSegueName") {
//            //get a reference to the destination view controller
//            let destinationVC:ViewControllerClass = segue.destinationViewController
//            
//            //set properties on the destination view controller
//            destinationVC.name = viewName
//            //etc...
//        }
//    }
  
    
    
    
    //MARK: - LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locManger.setUpLocationMonitoring()
        gameMap.showsUserLocation = true
        centerMapView()
        removePins()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentLocationRecieved", name: "recievedLocationFromUser", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addGamesToMap", name: "parsedGameData", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "searchCity", name: "recievedSearchedCityFromUser", object: nil)
        servManger.getGameLocation()

    }
    
    override func viewDidAppear(animated: Bool) {
        placeLocationsOnMapViaParse(servManger.gameArray)
    }
    override func viewDidDisappear(animated: Bool) {
       // gameMap.removeAnnotation()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

