# GameFinder
This is an App I made at the Iron Yard to help connect Ultimate Frisbee players find games. It uses the Parse Cocoa pod, mapkit, geocoding/reverse geocoding. To find a game I pass a geocoded location to an NSURL request at http://pickupultimate.com/cities, I parse the XML and save the information to a database on Parse. I also use parse to create player profiles, so I can include a attendance feature. The map displays each game within a 10 mile radius of your searched location. Each game then shows a satallite view of the fields and gives the players to mark their attendance by using a many to many relationship between games and players on parse. 


![GameFinder](http://i.imgur.com/OQOO67h.png) ![GameFinder](http://i.imgur.com/BonQck1.png)  ![GameFinder](http://i.imgur.com/SQr3uM7.png) ![GameFinder](http://i.imgur.com/Zah7xWz.png) ![GameFinder](http://i.imgur.com/wOP1e0m.png) 
