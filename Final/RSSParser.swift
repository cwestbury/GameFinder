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

    var xmlParser: NSXMLParser!

    var titleList = [String]()
    var gameDescriptions = [String]()
    
    var gameLat = 0.0 as Double
    var gameLong = 0.0 as Double
    var LatArray = [0.0]
    var LongArray = [0.0]
    
    var currentlyParsedElement = String()
    var parsingAnItem = false
    
    
    
        
        //MARK: - XML Parsing Methods
        
        func getGameInfo() {
           // let urlString = NSURL(string: "http://pickupultimate.com/rss/city/\(cityname)")
            let urlString = NSURL(string: "http://pickupultimate.com/rss/city/annarbor")
            let rssURLRequest: NSURLRequest = NSURLRequest(URL: urlString!)
            
            let urlSession = NSURLSession.sharedSession()
            let task = urlSession.dataTaskWithRequest(rssURLRequest) { (data, response, error) -> Void in
                if data != nil {
                    print("Got Data")
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
            //dataManager.removeAllEpisodes()
            gameDescriptions.removeAll()
            titleList.removeAll()
            LatArray.removeAll()
            LongArray.removeAll()
            //write a method that clears the array
        }
        
        func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if elementName == "item" {
            parsingAnItem = true
        }
        if parsingAnItem {
            switch elementName {
            case "title":
                //Title = String()
                currentlyParsedElement = "title"
            case "description":
//                entryDate = String()
                currentlyParsedElement = "description"
//            case "description":
//                entryDescription = String()
//                currentlyParsedElement = "description"
//            case "duration":
//                entryDuration = String()
//                currentlyParsedElement = "duration"
                
            default: break
            }
        }
    }
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        if parsingAnItem {
            switch currentlyParsedElement {
            case "title":
                titleList.append(string)
            case "description":
                gameDescriptions.append(string)
                //                case "pubDate":
                //                    //entryDate = string
                //                case "description":
                //                   // entryDescription = string
                //                case "duration":
                //                   // entryDuration = string
            default: break
            }
        }
    }


        
        
        func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
            
            if parsingAnItem {
                switch elementName {
                case "title":
                    currentlyParsedElement = ""
//                case "pubDate":
//                    currentlyParsedElement = ""
//                case "description":
//                    currentlyParsedElement = ""
//                case "duration":
//                    currentlyParsedElement = ""
                default: break
                }
            }
            if elementName == "item" {
                print(gameDescriptions)
//                let itemEpisode = NSEntityDescription.insertNewObjectForEntityForName("Episode", inManagedObjectContext: self.managedObjectContext!) as! Episode
//                itemEpisode.episodeTitle = entryTitle
//                itemEpisode.episodeDate = entryDate
//                itemEpisode.episodeDescription = entryDescription
//                itemEpisode.episodeDuration = entryDuration
//                appDelegate.saveContext()
                
                parsingAnItem = false
            }
        }
        
        func parserDidEndDocument(parser: NSXMLParser) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                print("Received Game Data")
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "parsedEpisodeData", object: nil))
            })
        }

        
    }
    
    
    