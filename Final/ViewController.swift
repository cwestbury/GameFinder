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
    let currentUser = PFUser.currentUser()
    
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
    
    
    //MARK: - Parse Login Methods
    
    
    func checkForLogin(){
        if currentUser == nil {
            
            loginButton.title = "Login"
            loggedIN = false
            settingsButton.enabled = false
            settingsButton.title = ""
            let LoginVC = self.storyboard?.instantiateViewControllerWithIdentifier("ParseLogin")
            presentViewController(LoginVC!, animated: true, completion: nil)

            
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
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        dismissViewControllerAnimated(true, completion: nil)
        settingsButton.enabled = true
        settingsButton.title = "⚙"
        loginButton.title = "Log Out"
        loggedIN = true
        
    }
    
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        dismissViewControllerAnimated(true, completion: nil)
        checkForLogin()
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
            // searchedCity = locManger.searchedCity
            //print(searchedCity)
            // RSSParser.searchedNSURLString(locManger.searchedCity)
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
        //servManager.saveGeoPoint(newGameLat, long: newGameLong)
        if loggedIN == true {
        let annotation = view.annotation as! GamePointAnnotation
        selectedGame = annotation.pinGame
        performSegueWithIdentifier("gameDetailSegue", sender: self)
        } else {
            genericAlertView("Please Login", message: "You must login before viewing games!")
        }
    }

    func removePins() {
        var pins: [MKAnnotation] = NSArray(array: gameMap.annotations) as! [MKAnnotation]
        gameMap.removeAnnotations(pins)
        pins.removeAll()
    }

    func currentLocationRecieved() {
        print("CurrentLocation Recived")
        RSSParser.currentLocationNSURLString()
        RSSParser.getGameInfo()
    }
    
    @IBAction func SearchCurrentLocation() {
        LocationSearchBar.text = ""
        searchBarCity = locManger.userCurrentCity
        
        var city = locManger.userCurrentCity
        print("\(city)")
        if city == "Washington" {
            city = "WashingtonDC"
        }
        
//        var NSUrl = NSURL()
//        URLRequest = NSURLRequst(
        let url = NSURL(string: "http://pickupultimate.com/rss/city/\(city)")!
        let URLRequest = NSURLRequest(URL: url)
        //let URLRequest = (NSURL: "http://pickupultimate.com/rss/city/\(city)")
        RSSParser.SearchCurrentLocation(URLRequest)
        
        
        //currentLocationRecieved()
        //        RSSParser.currentLocationNSURLString()
        //        RSSParser.getGameInfo()
        locManger.centerMapView(gameMap)
        
    }
    
    
    func addGamesToMap() {
        centerMapButton.enabled = true
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
    

    
    //MARK: - Alert View
    
    func genericAlertView(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - LifeCycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centerMapButton.enabled = false
        RSSParser.queryParseForGames()
        locManger.setUpLocationMonitoring()
        checkForLogin()
        gameMap.showsUserLocation = true
       
        locManger.centerMapView(gameMap)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentLocationRecieved", name: "recievedLocationFromUser", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addGamesToMap", name: "parsedGameData", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "searchCity", name: "recievedSearchedCityFromUser", object: nil)
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    override func viewDidDisappear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

