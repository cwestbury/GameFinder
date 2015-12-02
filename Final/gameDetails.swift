//
//  gameDetails.swift
//  Final
//
//  Created by Cameron Westbury on 11/30/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

import UIKit
import ParseUI
import Parse
import CoreLocation
import MapKit

class gameDetails: UIViewController {
    
    //MARK: - Properties
    
    let servManager = serverManager.sharedInstance
    
    @IBOutlet var location : UILabel!
    
    @IBOutlet var date: UITextField!
    @IBOutlet var time: UITextField!
    @IBOutlet var name: UITextField!
    @IBOutlet var cost: UITextField!
    @IBOutlet var creatorName: UITextField!
    
    
    @IBOutlet var email: UITextView!
    @IBOutlet var facebook: UITextView!
    @IBOutlet var gameDescription: UITextView!
    @IBOutlet var website: UITextView!
    @IBOutlet var phone: UITextView!
    
    
    //MARK: - Interactivity 
    
    @IBAction func saveAndPop() {
        servManager.saveGameDetails(date.text!, Title: time.text!, GameDescription: gameDescription.text!, Cost: cost.text!, Email: email.text!, Facebook:facebook.text!, Website: website.text!, Phone: phone.text!, creatorName: creatorName.text!)
            self.navigationController!.popToRootViewControllerAnimated(true)
    }
    
    
    
    
    
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
