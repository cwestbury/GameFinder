//
//  ParseSignUpViewController.swift
//  Final
//
//  Created by Cameron Westbury on 12/9/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

import UIKit
import Parse

class ParseSignUpViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    
    @IBAction func signUpAction(sender: AnyObject) {
        
        let username = self.usernameField.text
        let password = self.passwordField.text
        let email = self.emailField.text
        let finalEmail = email!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        //MARK: - Sign Up Methods
        if username!.characters.count < 3 {
            genericAlertView("Username Invalid", message: "Your username must be more than 3 characters long")
            
        } else if password!.characters.count < 4 {
            genericAlertView("Password Invalid", message: "Password must be more than 4 characters long")
            
        } else if email!.characters.count < 8 {
             genericAlertView("Email Invalid", message: "Email must be more than 4 characters long")
        } else {
            
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            
            spinner.startAnimating()
            
            let newUser = PFUser()
            
            newUser.username = username
            newUser.password = password
            newUser.email = finalEmail
            
            // Sign up the user asynchronously
            newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                if ((error) != nil) {
                     self.genericAlertView("Error", message: "\(error)")
                    
                    
                } else {
//                    var alert = UIAlertView(title: "Success", message: "Signed Up", delegate: self, cancelButtonTitle: "OK")
//                    alert.show()
//                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Home")
//                        self.presentViewController(viewController, animated: true, completion: nil)
//                    })
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
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}