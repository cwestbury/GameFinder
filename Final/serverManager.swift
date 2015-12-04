//
//  serverManager.swift
//  Final
//
//  Created by Cameron Westbury on 12/1/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

import Foundation
import Parse
import MapKit

class serverManager: NSObject {
    
    //MARK: - Properties 
    
    static let sharedInstance = serverManager()
    var locManager = LocationManager.sharedInstance
    var gameClass = PFObject(className: "Games")
    var gameArray = [PFObject]()
    
    //MARK: -  Save Parse Methods
    
    func saveGeoPoint(lat:Double, long:Double) {
        //let PFLocation = PFObject(className: "Game")
        let GeoPoint = PFGeoPoint(latitude: lat, longitude: long)
        gameClass["GameCoords"] = GeoPoint
        gameClass.saveInBackground()
 
    }
    
    func saveGameFromWebsite(title:String, gameDescription:String, gameLat:Double, gameLong:Double){
        print("Saving \(title)")
        let newGame = PFObject(className: "Games")
        newGame["Title"] = title
        newGame["GameDescprition"] = gameDescription
        let GeoPoint = PFGeoPoint(latitude: gameLat, longitude: gameLong)
        newGame["GameCoords"] = GeoPoint
        newGame.saveInBackground()
    }
    
    
    func saveGameDetails(Date:String, Title:String, GameDescription:String, Cost:String, Email:String, Facebook:String, Website:String, Phone:String, creatorName:String) {
        gameClass["Date"] = Date
        gameClass["Title"] = Title
        gameClass["GameDescprition"] = GameDescription
        gameClass["Cost"] = Cost
        gameClass["Email"] = Email
        gameClass["FaceBook"] = Facebook
        gameClass["website"] = Website
        gameClass["phone"] = Phone
        gameClass["creatorName"] = creatorName
        gameClass.saveInBackground()
 
    }
    
     //MARK: -  Query Parse Methods

    func getGameLocation(){

        let query = PFQuery(className:"Game")
        let userGeoPoint = PFGeoPoint(latitude: locManager.userLocationCoordinates.latitude, longitude: locManager.userLocationCoordinates.longitude)
        query.whereKey("GameCoords", nearGeoPoint:userGeoPoint)
        query.limit = 10
        do {
            try gameArray = query.findObjects()
            
            placeLocationsOnMap(gameArray)
        } catch {
            print("Error")
        }
    }
    
    func placeLocationsOnMap(gameArray: [PFObject]) {
        for game in gameArray {
            let loc = game["GameCoords"] as! PFGeoPoint
           // let coords1 = [loc.latitude, loc.longitude]
            
//            let gamePin = MKPointAnnotation()
//            let coords = CLLocationCoordinate2DMake(loc.latitude, loc.longitude)
//            gamePin.coordinate = coords
//            gamePin.title = game["Title"] as? String
//            map.addAnnotation(gamePin)
            print("Lat:\(loc.latitude) Lon:\(loc.longitude)")
            
        }
    }
    
        
    
    
    
    
}