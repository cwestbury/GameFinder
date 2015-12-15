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
    
    var playerUsernameArray  = [String]()
    
    var height = 0.0 as CGFloat
    
    @IBOutlet var NavBarTitle: UINavigationItem!
    @IBOutlet var attendanceSwitch: UISwitch!
    
    let locManager = LocationManager.sharedInstance
    var selectedGame :Games!
    
    let currentUser = PFUser.currentUser()
    var parseGame = PFObject(className: "Games")
    
    //MARK: - Switch Functions
    
    @IBAction func switchPressed(sender:UISwitch) {
        let relation = parseGame.relationForKey("User")
        if currentUser == nil {
            alertView("Please Login", message: "Please login on the homescreen before marking your attendance")
        } else {
            if attendanceSwitch.on {
                attendanceSwitch.enabled = false
                relation.addObject(currentUser!)
                print("added: \(currentUser!["username"] as! String) to Game List")
                do {
                    try parseGame.save()
                    QueryGamesForPlayers()
                } catch {
                    print("Error")
                }
                attendanceSwitch.enabled = true
            } else {
                attendanceSwitch.enabled = false
                relation.removeObject(currentUser!)
                playerUsernameArray.removeLast()
                print("Removed: \(currentUser!["username"] as! String) From Game List")
                
                let nameToRemove = currentUser!["username"] as! String
                let playerToRemove = playersArray.filter({$0.userName == nameToRemove}).first!
                Player().userName = nameToRemove
                let playerToRemoveIndex = playersArray.indexOf(playerToRemove)
                playersArray.removeAtIndex(playerToRemoveIndex!)
                playersTableView.reloadData()
                do{
                    try parseGame.save()
                    attendanceSwitch.enabled = true
                } catch {
                    print("Error saving relationship")
                }
                
                
                
            }
            
            
            
        }
    }
    func setSwitchState() {
        if currentUser != nil {
            let currentUserName = currentUser!["username"] as! String
            if playerUsernameArray.contains(currentUserName) {
                attendanceSwitch.on = true
                print("\(playerUsernameArray) contains \(currentUserName): Switch On")
            } else {
                attendanceSwitch.on = false
            }
        }
    }
    
    
    
    //MARK: - TableView Methods
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Map"
        case 1:
            return " Game Description"
        case 2:
            return "Attending This Week: \(playersArray.count)"
        default:
            return "Uknown"
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0  {
            let mapCell = tableView.dequeueReusableCellWithIdentifier("MapCell") as! CustomMapTableViewCell
            removePins(mapCell.SingleGameMapView)
            
            addGameToMap(mapCell.SingleGameMapView)
            centerMapOnSearch(mapCell.SingleGameMapView)

            mapCell.SingleGameMapView.mapType = .Hybrid
            mapCell.selectionStyle = .None
            
            return mapCell
            
        } else if indexPath.section == 1 {
            // REPLACE WITH DESC CELL
            let gameDescriptionCell = tableView.dequeueReusableCellWithIdentifier("TextCell") as! CustomTextViewTableViewCell
            //GameDescription.font = UIFont(name: "Damascus", size: 20.0)
        

            gameDescriptionCell.GameDescriptionTextView.text = selectedGame.GameDescription
            height = gameDescriptionCell.GameDescriptionTextView.bounds.height
            return gameDescriptionCell
            
        } else {
            let CustomPlayerCell : CustomPlayerUITableViewCell = tableView.dequeueReusableCellWithIdentifier("CustomCell") as! CustomPlayerUITableViewCell
            CustomPlayerCell.PlayerGenderLabel.text = playersArray[indexPath.row].gender
            CustomPlayerCell.PlayerExpLabel.text = "Exp: " + playersArray[indexPath.row].experience
            CustomPlayerCell.PlayerNameLabel.text = playersArray[indexPath.row].playerName
            CustomPlayerCell.PlayerImage.image = playersArray[indexPath.row].playerImage
            return CustomPlayerCell
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // print("TableView Rows Count: \(playersArray.count)")
        if section == 2 {
            return playersArray.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 250.0
        } else if indexPath.section == 1 {
            return 100.0
        } else {
            return 80.0
        }
    }
    

    
    //MARK: - Map Functions
    
    func removePins(mapView: MKMapView) {
        var pins: [MKAnnotation] = NSArray(array: mapView.annotations) as! [MKAnnotation]
        mapView.removeAnnotations(pins)
        pins.removeAll()
    }
    
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
    
    func centerMapOnSearch(map:MKMapView) {
        let center = CLLocationCoordinate2D(latitude:selectedGame.GameLat , longitude: selectedGame.GameLong)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        map.setRegion(region, animated: true)
    }
    
    func addGameToMap(map:MKMapView){
        locManager.addMapPins(map, lat: selectedGame.GameLat, long: selectedGame.GameLong, Title: "Route", game: selectedGame)
    }
 
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        openAppleMaps()
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
                self.alertView("Error", message: "Could not reach server")// Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    
    func QueryGamesForPlayers() {
        playersArray.removeAll()
        playerUsernameArray.removeAll()
        let relation = parseGame.relationForKey("User")
        let query = relation.query()
        query.findObjectsInBackgroundWithBlock { (players, error) -> Void in
            if error == nil {
                for player in players! {
                    let playerObject = Player()
                    playerObject.playerName = player["Name"] as! String
                    playerObject.userName = player["username"] as! String
                    playerObject.gender = player["Gender"] as! String
                    playerObject.experience = player["Experience"] as! String
                    playerObject.userName = player["username"] as! String
                    
                    self.playerUsernameArray.append(player["username"] as! String)
                    let imageFile = (player["imageFile"] as! PFFile)
                    imageFile.getDataInBackgroundWithBlock {
                        (imageData: NSData?, error: NSError?) -> Void in
                        if error == nil {
                            if let imageData = imageData {
                                playerObject.playerImage = UIImage(data:imageData)
                                
                                self.playersTableView.reloadData()
                            }
                        } else {
                            self.alertView("Error", message: "Could not reach serevr")
                            print("No Image Found")
                        }
                    }
                    
                    if self.playersArray.contains(playerObject) {
                        print("Already contains: \(player["Name"])")
                    } else {
                        self.playersArray.append(playerObject)
                        print("Added: \(player["Name"])")
                    }
                    
                    //print(self.playersArray)
                }
                self.playersTableView.reloadData()
                print("Successfully retrieved \(players!.count) Players.")
                self.setSwitchState()
                
            } else {
                self.alertView("Error", message: "Could not reach server")
                print("Error: \(error!) \(error!.userInfo)")
            }
            
        }
    }
    //MARK: - Alert View
    
    func alertView(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NavBarTitle.title = selectedGame.Title!
        QueryParseForCurrentGame()
        
        playersTableView.estimatedRowHeight = 100.0
        playersTableView.rowHeight = UITableViewAutomaticDimension
   
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
