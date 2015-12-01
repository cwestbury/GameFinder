//
//  serverManager.swift
//  Final
//
//  Created by Cameron Westbury on 12/1/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

import Foundation
import Parse

class serverManager: NSObject {
    
    //MARK: - Properties 
    
    static let sharedInstance = serverManager()
    let gameClass = PFObject(className: "Game")
    
    //MARK: - Parse Methods
    
    func saveGeoPoint(lat:Double, long:Double) {
        //let PFLocation = PFObject(className: "Game")
        let GeoPoint = PFGeoPoint(latitude: lat, longitude: long)
        gameClass["GameCoords"] = GeoPoint
        gameClass.saveInBackground()
 
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

    
    
}