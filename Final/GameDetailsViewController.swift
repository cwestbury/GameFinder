//
//  GameDetailsViewController.swift
//  Final
//
//  Created by Cameron Westbury on 12/2/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

import UIKit
import MapKit


class GameDetailsViewController: UIViewController, MKMapViewDelegate {
    
    //MARK: - Properties
    @IBOutlet var SingleGameMap: MKMapView!
    @IBOutlet var GameDescription: UITextView!
    @IBOutlet var mapController: UISegmentedControl!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    let locManager = LocationManager.sharedInstance
    var selectedGame :Games!
    var emailCleanedString :String!
    var mailingListCleanedString: String!
    var cleanString: String!
    var dirtyString: String!
    
    //MARK: - Map Functions
    
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
    
    @IBAction func selectedSegmentChanged(sender:UISegmentedControl){
        switch mapController.selectedSegmentIndex
        {
        case 0:
            SingleGameMap.mapType = .Hybrid
        case 1:
            SingleGameMap.mapType = .Standard
        case 2:
            centerMapOnSearch()
        default:
            break
            
        }
        
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        route()
        bottomConstraint.constant = 0
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
    
    //MARK: - XMLString Cleaning Methods
    
    func removeCharactersFromString(uncleanString:String, characterToRemove:String, characterReplacedBy:String){
        
        cleanString =  uncleanString.stringByReplacingOccurrencesOfString("\(characterToRemove)", withString: "\(characterReplacedBy)")
        dirtyString = cleanString
        
        
    }
    
    func removeRange(searchStart:String, SearchEnd:String) {
        if let rangeToRemove = dirtyString.rangeOfString("(?<=\(searchStart))[^\(SearchEnd)]+", options: .RegularExpressionSearch) {
            let stringToRemove = dirtyString.substringWithRange(rangeToRemove)
            print(stringToRemove)
            let clean = dirtyString.stringByReplacingCharactersInRange(rangeToRemove, withString: "")
            dirtyString = clean
            cleanString = dirtyString
        }
        
    }
    
    
    
    
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SingleGameMap.mapType = .Hybrid
        addGameToMap()
        centerMapOnSearch()
        
        dirtyString = selectedGame.GameDescription as String
        removeCharactersFromString(dirtyString, characterToRemove: "<b>", characterReplacedBy: "")
        removeCharactersFromString(dirtyString, characterToRemove: "</b>", characterReplacedBy: "")
        removeCharactersFromString(dirtyString, characterToRemove: "<br />", characterReplacedBy: "\r\n")
        removeCharactersFromString(dirtyString, characterToRemove: "</b>", characterReplacedBy: "")
        removeCharactersFromString(dirtyString, characterToRemove: "<a>", characterReplacedBy: "")
        removeCharactersFromString(dirtyString, characterToRemove: "</a>", characterReplacedBy: "")
        
        
        removeRange("Email:", SearchEnd: ">")
        removeRange("Website:", SearchEnd: ">")
        removeRange("List:", SearchEnd: ">")
        
        removeCharactersFromString(dirtyString, characterToRemove: ">", characterReplacedBy: " ")
        
        GameDescription.font = UIFont(name: "Damascus", size: 20.0) //not working
        GameDescription.text = cleanString
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
