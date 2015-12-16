//
//  ParseLoginViewController.swift
//  Final
//
//  Created by Cameron Westbury on 12/9/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

import UIKit
import Parse

class ParseLoginViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var RSSParser = rssParser.sharedInstance
    var locManager = LocationManager.sharedInstance
    
    @IBAction func loginAction(sender: AnyObject) {
        let username = self.usernameField.text
        let password = self.passwordField.text
        
        //MARK: - Validation + Login
        
        if username!.characters.count < 3
            
        {
            genericAlertView("Username Invalid", message: "Your username must be more than 3 characters long")
            
        } else if password!.characters.count < 4 {
            genericAlertView("Password Invalid", message: "Password must be more than 4 characters long")
            
        } else {
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            PFUser.logInWithUsernameInBackground(username!, password: password!, block: { (user, error) -> Void in
                
                spinner.stopAnimating()
                
                if ((user) != nil) {
                    //                    let alert = UIAlertView(title: "Success", message: "Logged In", delegate: self, cancelButtonTitle: "OK")
                    //                    alert.show()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        //print("\(PFUser.currentUser()!.username!)")
                        self.navigationController!.popToRootViewControllerAnimated(true)
                        
                    })
                    
                } else {
                    self.genericAlertView("Error", message: "\(error)")
                    
                }
            })
        }
    }
 
    //MARK: - Alert View
    
    func genericAlertView(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.text = "1234"
        usernameField.text = "cwestbury"
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
