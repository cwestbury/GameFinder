//
//  GameDetailsViewController.swift
//  Final
//
//  Created by Cameron Westbury on 12/2/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

import UIKit
import MapKit
import Parse


class GameDetailsViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    //MARK: - Properties
    
    @IBOutlet var playersTableView: UITableView!
    var playersArray  = [Player]()
    var playerObject = Player()
    
    @IBOutlet var SingleGameMap: MKMapView!
    @IBOutlet var GameDescription: UITextView!
    //@IBOutlet var mapController: UISegmentedControl!
    //@IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var NavBarTitle: UINavigationItem!
    @IBOutlet var attendanceSwtich: UISwitch!
    
    let locManager = LocationManager.sharedInstance
    var selectedGame :Games!
    
    var cleanString: String!
    var dirtyString: String!
    
    let currentUser = PFUser.currentUser()
    var parseGame = PFObject(className: "Games")
    
    //MARK: - Switch Functions
    
    @IBAction func switchPressed() {
        let relation = parseGame.relationForKey("User")
        relation.addObject(currentUser!)
        print("added \(currentUser!["Name"] as! String)")
        parseGame.saveInBackground()
        
    }
    
    
    
    //MARK: - TableViewMethods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if playersArray.count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
            cell.textLabel?.text = playersArray[indexPath.row].playerName
            //cell.imageView?.image = playersArray[indexPath.row].playerImage
            playersTableView.hidden = false
            print("Displaying Players")
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
            playersTableView.hidden = true
            print("No Players to Display")
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("TableView Row Count: \(playersArray.count)")
        return playersArray.count
    }
    
    //MARK: - Map Functions
    
    func openAppleMaps(){
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(selectedGame.GameLat, selectedGame.GameLong)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(selectedGame.Title!)"
        mapItem.openInMapsWithLaunchOptions(options)
        
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
                pin!.animatesDrop = true
            }
            pin!.annotation = annotation
            return pin
        }
    }
    
    func centerMapOnSearch() {
        let center = CLLocationCoordinate2D(latitude:selectedGame.GameLat , longitude: selectedGame.GameLong)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
        SingleGameMap.setRegion(region, animated: true)
    }
    
    func addGameToMap(){
        locManager.addMapPins(SingleGameMap, lat: selectedGame.GameLat, long: selectedGame.GameLong, Title: "Route", game: selectedGame)
    }
    
    //    @IBAction func selectedSegmentChanged(sender:UISegmentedControl){
    //        switch mapController.selectedSegmentIndex
    //        {
    //        case 0:
    //            SingleGameMap.mapType = .Hybrid
    //        case 1:
    //            SingleGameMap.mapType = .Standard
    //        case 2:
    //            centerMapOnSearch()
    //        default:
    //            break
    //
    //        }
    //
    //    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //route()
        openAppleMaps()
        //bottomConstraint.constant = 0
    }
    //MARK: - Rounting Methods
    
    func route() {
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: locManager.userLocationCoordinates.latitude, longitude: locManager.userLocationCoordinates.longitude), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: selectedGame.GameLat, longitude: selectedGame.GameLong), addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .Automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            for route in unwrappedResponse.routes {
                self.SingleGameMap.addOverlay(route.polyline)
                self.SingleGameMap.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                for step in route.steps {
                    print(step.instructions)
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5
        return renderer
    }
    
    
    
    //MARK: - Parse Query Methods
    
    func QueryParseForCurrentGame() {
        let query = PFQuery(className:"Games")
        print("QueryGame title: \(selectedGame.Title)")
        query.whereKey("Title", equalTo: "\(selectedGame.Title!)")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                print("Successfully retrieved \(objects!.count) Games.")
                if let uObjects = objects {
                    self.parseGame = uObjects[0]
                    self.QueryGamesForPlayers()
                    print("Current ParseGame: \(self.parseGame["Title"])")
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func QueryGamesForPlayers() {
        let relation = parseGame.relationForKey("User")
        let query = relation.query()
        query.findObjectsInBackgroundWithBlock { (players, error) -> Void in
            if error == nil {
                for player in players! {
                    self.playerObject.playerName = player["Name"] as! String
                    //self.playerObject.playerImage = player["imageFile"] as! UIImage
                    
                    if self.playersArray.contains(self.playerObject) {
                        print("Already contains \(player["Name"])")
                    } else {
                        self.playersArray.append(self.playerObject)
                        print("Added: \(player["Name"])")
                    }
                    self.playersTableView.reloadData()
                    
                    //print(self.playersArray)
                }
                
                
                
                print("Successfully retrieved \(players!.count) Players.")
                
            } else {
                print("Error: \(error!) \(error!.userInfo)")
            }
            
        }
    }
    
    
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SingleGameMap.mapType = .Hybrid
        addGameToMap()
        centerMapOnSearch()
        NavBarTitle.title = selectedGame.Title!
        
        GameDescription.font = UIFont(name: "Damascus", size: 20.0)
        GameDescription.text = selectedGame.GameDescription
        GameDescription.contentOffset = CGPoint.zero
        QueryParseForCurrentGame()
        print("Players Array Count: \(playersArray.count)")
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
