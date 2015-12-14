//
//  CustomPlayerUITableView.swift
//  Final
//
//  Created by Cameron Westbury on 12/8/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

import UIKit
import MapKit

class CustomPlayerUITableViewCell: UITableViewCell, MKMapViewDelegate {
    //@IBOutlet var GameDescriptionTextView: UITextView!
    
    @IBOutlet var SingleGameMapView:MKMapView!
    
    @IBOutlet var PlayerNameLabel: UILabel!
    @IBOutlet var PlayerImage: UIImageView!
    @IBOutlet var PlayerExpLabel: UILabel!
    @IBOutlet var PlayerGenderLabel: UILabel!


    
}
