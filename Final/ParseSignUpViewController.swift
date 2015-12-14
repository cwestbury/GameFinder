//
//  ParseSignUpViewController.swift
//  Final
//
//  Created by Cameron Westbury on 12/9/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

import UIKit
import Parse

class ParseSignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet var profilePic: UIImageView!
    
    
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var genderSegControl: UISegmentedControl!
    @IBOutlet var experienceSegControl: UISegmentedControl!
    
    var gender = "Male"
    var experience = "PickUp"
    
    
    //MARK: - Image Methods
    
    
    @IBAction func openPhotoLibraryButton(sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        print("picked Image")
        profilePic.image = image
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    //MARK: - Sign Up Methods
    
    @IBAction func signUpAction(sender: UIButton) {
        
        let username = self.usernameField.text
        let password = self.passwordField.text
        
        
        
        
        if username!.characters.count < 3 {
            genericAlertView("Username Invalid", message: "Your username must be more than 3 characters long")
            
        } else if password!.characters.count < 4 {
            genericAlertView("Password Invalid", message: "Password must be more than 4 characters long")
        } else {
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 150, 150)) as UIActivityIndicatorView
            
            spinner.startAnimating()
            
            let newUser = PFUser()
            
            newUser.username = username
            newUser.password = password
            
            print("NewUser Name & password \(newUser.username!) \(newUser.password!)")
            
            newUser.signUpInBackgroundWithBlock({ (succeed, error) -> Void in
                
                spinner.stopAnimating()
                if ((error) != nil) {
                    
                    self.genericAlertView("Error", message: "\(error)")
                    
                } else {
                    do {
                        try PFUser.logInWithUsername(newUser.username!, password: newUser.password!)
                        print("logged in")
                        self.SaveUserInfoToParse()
                        let vc : ViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MainView") as! ViewController
                        let navigationController = UINavigationController(rootViewController: vc)
                        
                        self.presentViewController(navigationController, animated: true, completion: nil)
                        
                        
                    } catch {
                        print("Got error signing up")
                    }
                    
                    
                }
            })
            
        }
        
    }
    
    
    //MARK: Save Info Methods
    func SaveUserInfoToParse(){
        var currentUser = PFUser.currentUser()
        if let uCurrentUser = currentUser {
            currentUser = uCurrentUser
            uCurrentUser["Name"] = nameTextField.text
            uCurrentUser["Gender"] = gender
            uCurrentUser["Experience"] = experience
            let imageData = UIImageJPEGRepresentation(profilePic.image!, 1.0)
            let imageFile = PFFile(name:"\(nameTextField.text!)ProfilePicture.png", data:imageData!)
            uCurrentUser["imageName"] = "\(nameTextField.text!)Picture"
            uCurrentUser["imageFile"] = imageFile
            uCurrentUser.saveInBackground()
            print("saved to parse")
        }
        else {
            print("No Current User")
        }
    }
    
    
    //MARK: Segmented Controller Methods
    
    @IBAction func SetGender(sender: UISegmentedControl) {
        switch genderSegControl.selectedSegmentIndex
        {
        case 0:
            gender = "Male"
            print("Selected Gender: \(gender) ")
        case 1:
            gender = "Female"
            print("Selected Gender: \(gender)")
        case 2:
            gender = "Other"
            print("Selected Gender: \(gender)")
        default:
            break;
        }
        
    }
    @IBAction func SetExp(sender: UISegmentedControl) {
        switch experienceSegControl.selectedSegmentIndex
        {
        case 0:
            experience = "PickUp"
            print("Selected Gender: \(experience) ")
        case 1:
            experience = "College"
            print("Selected Gender: \(experience) ")
        case 2:
            experience = "Club"
            print("Selected Gender: \(experience) ")
        default:
            break;
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