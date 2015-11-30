//
//  ViewController.swift
//  Final
//
//  Created by Cameron Westbury on 11/24/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

import UIKit
import ParseUI
import Parse
import CoreLocation
import MapKit


class ViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var gameMap: MKMapView!
    @IBOutlet var loginButton : UIBarButtonItem!
    
    var loggedIN = false
    
    var locManger = LocationManager.sharedInstance
    

    
    //MARK: - Login Methods
    
    @IBAction func loginButtonPresesd(sender:UIBarButtonItem) {
        if let _ = PFUser.currentUser() {
            PFUser.logOut()
            loginButton.title = "Login"
        } else {
            let loginVC = PFLogInViewController()
            loginVC.delegate = self
            let signUpVC = PFSignUpViewController()
            signUpVC.delegate = self
            loginVC.signUpController = signUpVC
            presentViewController(loginVC, animated: true, completion: nil)
        }
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        dismissViewControllerAnimated(true, completion: nil)
        loginButton.title = "Log Out"
        
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func signUpViewControllerDidCancelSignUp(signUpController: PFSignUpViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func centerMapView() {
        locManger.centerMapView(gameMap)
    }
    
    //MARK: - LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        locManger.setUpLocationMonitoring()
        gameMap.showsUserLocation = true
        centerMapView()
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "centerMapView", name: "recievedLocationFromUser", object: nil)
        
     
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

