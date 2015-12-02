//
//  LocationManager.swift
//  Final
//
//  Created by Cameron Westbury on 11/30/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, CLLocationManagerDelegate, MKMapViewDelegate {

    
     //MARK: - Properties


    static let sharedInstance = LocationManager()
    var locationManager: CLLocationManager = CLLocationManager()
    var userLocationCoordinates = CLLocationCoordinate2D()
    var userCity: String!
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if (userLocationCoordinates.latitude == 0 && userLocationCoordinates.longitude == 0) {
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            userLocationCoordinates = CLLocationCoordinate2D(latitude: locations.last!.coordinate.latitude, longitude:locations.last!.coordinate.longitude)
            print("Location Manager: User location = Lat: \(locValue.latitude) Long: \(locValue.longitude)")
            let location = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + error!.localizedDescription)
                    return
                }
                if placemarks!.count > 0 {
                    let pm = placemarks![0]
                    self.userCity = pm.locality!
                    print(pm.locality!)
                    
                    dispatch_async(dispatch_get_main_queue()){
                        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "recievedLocationFromUser", object: nil))
                    }
                    
                } else {
                    print("Problem with the data received from geocoder")
                }
            })
        }
        
    }

    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Loc Manager Error \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("Got new auth status \(status.rawValue)")
//        setUpLocationMonitoring()
    }
    
    func convertCoordinateToString(coordinate: CLLocationCoordinate2D) -> String {
        print("Coordinate to String: \(coordinate.latitude),\(coordinate.longitude)")
        return "\(coordinate.latitude),\(coordinate.longitude)"
    }
    
    func setUpLocationMonitoring() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .AuthorizedAlways, .AuthorizedWhenInUse:
                print("have access to location \(userLocationCoordinates) l:\(userLocationCoordinates.latitude)")
                locationManager.requestLocation()
            case .Denied, .Restricted:
                print("Location services disabled/restricted")
            case .NotDetermined:
                if (locationManager.respondsToSelector("requestWhenInUseAuthorization")) {
                    print("requesting loc auth")
                    locationManager.requestWhenInUseAuthorization()
                }
            }
        } else {
            print("Turn on location services in Settings!")
        }
        
    }

    func centerMapView(map:MKMapView) {
        print("AddGame: Center Map View Running")
        let currentLocaiton = locationManager.location!.coordinate
        print(currentLocaiton)
        let center = CLLocationCoordinate2DMake(currentLocaiton.latitude, currentLocaiton.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.0675, longitudeDelta: 0.0675))
        map.setRegion(region, animated: true)
    }
    
    func addMapPins(map:MKMapView, lat:Double, long:Double, Title:String) {
        let gamePin = MKPointAnnotation()
        let gameCoords = CLLocationCoordinate2DMake(lat, long)
        gamePin.coordinate = gameCoords
        gamePin.title = Title
        map.addAnnotation(gamePin)
        
    }
    
    
    
}
