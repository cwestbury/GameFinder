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
import SafariServices


class ViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, CLLocationManagerDelegate, UISearchBarDelegate, MKMapViewDelegate {
    
    @IBOutlet var gameMap: MKMapView!
    @IBOutlet var loginButton : UIBarButtonItem!
    @IBOutlet var LocationSearchBar: UISearchBar!
    @IBOutlet var settingsButton: UIBarButtonItem!
    @IBOutlet var centerMapButton: UIButton!
    
    var selectedGame :Games!
    //let currentUser = PFUser.currentUser()
    
    var loggedIN = false
    let loginVC = PFLogInViewController()
    let signUpVC = PFSignUpViewController()
    
    var locManger = LocationManager.sharedInstance
    var servManger = serverManager.sharedInstance
    var RSSParser = rssParser.sharedInstance
    
    var searchBarCity : String!
    
    //MARK: - Interacvity

    @IBAction func addGamePressed() {
        
        if let url = NSURL(string: "http://pickupultimate.com/game/add") {
            let viewcont = SFSafariViewController(URL: url)
            presentViewController(viewcont, animated: true, completion: nil)
        }
    }
    
    @IBAction func SearchCurrentLocation() {
        LocationSearchBar.text = ""
        searchBarCity = locManger.userCurrentCity
        
        let city = locManger.userCurrentCity
        print("Searching Current: \(city)")
        locManger.getSearchedLocation(city)
        locManger.centerMapView(gameMap)
    }
    
    func searchYourLocation(){
        locManger.getSearchedLocation(locManger.userCurrentCity)
    }

    
    
    //MARK: - Parse Login Methods
    
    
    func checkForLogin(){
         print("Current UserName: \(PFUser.currentUser()?.username!)")
        if PFUser.currentUser() == nil {
            
            loginButton.title = "Login"
            loggedIN = false
            settingsButton.enabled = false
            settingsButton.title = ""
            performSegueWithIdentifier("LoginSegue", sender: self)

            
        } else {
            //print("currentUsername: \(currentUser)")
            loginButton.title = ""
            settingsButton.enabled = true
            settingsButton.title = "⚙"
            loggedIN = true

        }
    }
        
    
    @IBAction func loginButtonPresesd(sender:UIBarButtonItem) {
        if let _ = PFUser.currentUser() {
            PFUser.logOut()
            loginButton.title = "Login"
            settingsButton.enabled = false
            settingsButton.title = ""
            
        } else {
            
            let LoginVC = self.storyboard?.instantiateViewControllerWithIdentifier("ParseLogin")
            presentViewController(LoginVC!, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - Search Bar Methods
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if LocationSearchBar.text != nil {
            var textToSearch = LocationSearchBar.text!
            textToSearch = textToSearch.lowercaseString
            
            if textToSearch == "dc" {
                textToSearch = "washingtonDC"
            }
            print("input text: \(textToSearch)")
            locManger.getSearchedLocation(textToSearch)
     
            searchBar.resignFirstResponder()
        }
    }
    
    @IBAction func removeKeyboard() {
        LocationSearchBar.resignFirstResponder()
        LocationSearchBar.text = ""
    }
    
    func searchCity() {
        searchBarCity = locManger.searchedCity
        //print("searchBar City: \(searchBarCity)")
        RSSParser.searchedNSURLString(searchBarCity)
        RSSParser.getGameInfo()
        locManger.centerMapOnSearch(gameMap)
    }
    
    

    //MARK: - Map Methods
    

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
                pin!.animatesDrop = true
                pin!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            pin!.annotation = annotation
            return pin
        }
        
    }
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if loggedIN == true {
        let annotation = view.annotation as! GamePointAnnotation
        selectedGame = annotation.pinGame
        performSegueWithIdentifier("gameDetailSegue", sender: self)
        } else {
            LoginAlertView("Please Login", message: "Please Login before viewing games!")
        }
    }

    func removePins() {
        var pins: [MKAnnotation] = NSArray(array: gameMap.annotations) as! [MKAnnotation]
        gameMap.removeAnnotations(pins)
        pins.removeAll()
    }

    func currentLocationRecieved() {
        print("Current Location Recived")
        RSSParser.currentLocationNSURLString()
        RSSParser.getGameInfo()
        centerMapButton.enabled = true
    }
    
    
    
    func addGamesToMap() {
        removePins()
        print("adding XML parsed Games")
        print("Game count: \(RSSParser.gameArray.count)")
        if RSSParser.gameArray.count == 0 && searchBarCity == nil {
            genericAlertView("😭😭😭", message: "No games found near you")
        } else if RSSParser.gameArray.count == 0 {
            genericAlertView("😭😭😭", message: "No games found in \(searchBarCity)")
        } else if RSSParser.gameArray.count >= 1 {
        for GamesToParse in RSSParser.gameArray {
            // print("For Loop \(GamesToParse.Title) lat \(GamesToParse.GameLat) lon \(GamesToParse.GameLong)")
            locManger.addMapPins(gameMap, lat: GamesToParse.GameLat, long: GamesToParse.GameLong, Title: GamesToParse.Title, game: GamesToParse)
        }
        }
        
    }
 
    //MARK: - Segue Methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "gameDetailSegue"){
            let destController = segue.destinationViewController as! GameDetailsViewController
            destController.selectedGame = selectedGame
            
        }
    }
    
    
    //MARK: - Alert Views
    
    func genericAlertView(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func LoginAlertView(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let Login = UIAlertAction(title: "Login", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            self.checkForLogin()
            
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(Login)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // print(currentUser?.username)
        //PFUser.logOut()
        RSSParser.queryParseForGames()
        locManger.setUpLocationMonitoring()
        
        gameMap.showsUserLocation = true
        locManger.centerMapView(gameMap)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentLocationRecieved", name: "recievedLocationFromUser", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addGamesToMap", name: "parsedGameData", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "searchCity", name: "recievedSearchedCityFromUser", object: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        checkForLogin()
    }
    override func viewDidDisappear(animated: Bool) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

