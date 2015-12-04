//
//  RSSParser.swift
//  Final
//
//  Created by Cameron Westbury on 12/1/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

import Foundation

class rssParser: NSObject, NSXMLParserDelegate {
    
    static let sharedInstance = rssParser()
    let LocManager = LocationManager.sharedInstance
    let servManager = serverManager.sharedInstance
    
    var xmlParser: NSXMLParser!
    
    var currentlyParsedElement = String()
    var parsingAnItem = false
    
    var gameArray = [Games]()
    var newGame = Games()
    var city = String()
    var searchedUrlString = NSURL()
    var currentLocationUrlString = NSURL()
    var rssUrlRequest = NSURLRequest()
    
    var cleanString: String!
    var dirtyString: String!
    
    
    
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
    
    func cleaningString() {
        removeCharactersFromString(dirtyString, characterToRemove: "<b>", characterReplacedBy: "")
        removeCharactersFromString(dirtyString, characterToRemove: "</b>", characterReplacedBy: "")
        removeCharactersFromString(dirtyString, characterToRemove: "<br />", characterReplacedBy: "\r\n")
        removeCharactersFromString(dirtyString, characterToRemove: "</b>", characterReplacedBy: "")
        removeCharactersFromString(dirtyString, characterToRemove: "<a>", characterReplacedBy: "")
        removeCharactersFromString(dirtyString, characterToRemove: "</a>", characterReplacedBy: "")
        
        
        removeRange("Email:", SearchEnd: ">")
        removeRange("Website:", SearchEnd: ">")
        removeRange("List:", SearchEnd: ">")
    }
    
    
    
    //MARK: - XML Parsing Methods
    
    func searchedNSURLString(SeachedCity: String) {
        let dirtyString = SeachedCity
        
        var cleanString = dirtyString.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "")
        print(cleanString)
        if cleanString == "washington" {
            cleanString = "washingtonDC"
        }
        if cleanString == "newyork"{
            cleanString = "nyc"
        }
        if cleanString == "newyorkcity"{
            cleanString = "nyc"
        }
        if cleanString == "sanfrancisco"{
            cleanString = "sfbayarea"
        }
        print(cleanString)
        searchedUrlString = NSURL(string: "http://pickupultimate.com/rss/city/\(cleanString)")!
        print("City to Parse! - \(searchedUrlString)")
    }
    
    func currentLocationNSURLString(){
        city = LocManager.userCity
        if city == "Washington" {
            city = "WashingtonDC"
        }
        //currentLocationUrlString = NSURL(string: "http://pickupultimate.com/rss/city/\(city)")!
        currentLocationUrlString = NSURL(string: "http://pickupultimate.com/rss/city/annarbor")!
        
        
    }
    
    func getGameInfo() {
        print("Search String: \(searchedUrlString.relativeString)")
        if searchedUrlString.relativeString == nil {
            rssUrlRequest = NSURLRequest(URL: currentLocationUrlString)
            print("Current Location String: \(currentLocationUrlString)")
            
        } else {
            rssUrlRequest = NSURLRequest(URL: searchedUrlString)
            print("Searched String: \(searchedUrlString)")
        }
        let urlSession = NSURLSession.sharedSession()
        let task = urlSession.dataTaskWithRequest(rssUrlRequest) { (data, response, error) -> Void in
            if data != nil {
                print("Got XML Data")
                self.xmlParser = NSXMLParser(data: data!)
                self.xmlParser.delegate = self
                self.xmlParser.parse()
            } else {
                print("Error Getting Data")
            }
        }
        task.resume()
        
    }
    
    func parserDidStartDocument(parser: NSXMLParser) {
        gameArray.removeAll()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == "item" {
            parsingAnItem = true
            newGame = Games()
        }
        if parsingAnItem {
            switch elementName {
            case "title":
                currentlyParsedElement = "title"
            case "description":
                currentlyParsedElement = "description"
            case "geo:lat":
                currentlyParsedElement = "geo:lat"
            case "geo:long":
                currentlyParsedElement = "geo:long"
            default: break
            }
        }
    }
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        if parsingAnItem {
            
            switch currentlyParsedElement {
            case "title":
                newGame.Title = string
            case "description":
                newGame.GameDescription = string
                dirtyString  = newGame.GameDescription //will this work?
                cleaningString()
            case "geo:lat":
                let latCoords = Double(string)!
                newGame.GameLat = latCoords
            case "geo:long":
                let longCoords = Double(string)!
                newGame.GameLong = longCoords
            default: break
            }
        }
    }
    
    
    
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if parsingAnItem {
            switch elementName {
            case "title":
                currentlyParsedElement = ""
            case "description":
                currentlyParsedElement = ""
            case "geo:lat":
                currentlyParsedElement = ""
            case "geo:long":
                currentlyParsedElement = ""
            default: break
            }
        }
        if elementName == "item" {
            //print(newGame.Title)
            gameArray.append(newGame)
            print("new game:\(newGame.Title)") //prints 3 games?
            //print("Clean Sting Starts here: \(cleanString)")
            
            servManager.saveGameFromWebsite(newGame.Title, gameDescription: cleanString, gameLat: newGame.GameLat, gameLong: newGame.GameLong) //but this only saves the last game?
     
            parsingAnItem = false
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            print("Parsed XML Game Data")
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "parsedGameData", object: nil))
        })
    }
    
    
}


    