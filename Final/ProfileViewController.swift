//
//  ProfileViewController.swift
//  Final
//
//  Created by Cameron Westbury on 12/6/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate {
    
    
    //MARK: - Properties
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var NavBarTitle: UINavigationItem!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var genderSegControl: UISegmentedControl!
    @IBOutlet var experienceSegControl: UISegmentedControl!
    var gender = "Male"
    var genderSegment = 0
    var experience = "Pickup"
    var experienceSegment = 0
    var currentUser = PFUser.currentUser()
    
    //MARK: - Text Delegate Methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK: - Save/Querry Server Methods
    
    @IBAction func submitValuesToParse(sender: UIButton){
        
        if let uCurrentUser = currentUser {
            currentUser = uCurrentUser
            
            uCurrentUser["Name"] = nameTextField.text
            uCurrentUser["Gender"] = gender
            uCurrentUser["Experience"] = experience
            
            
            let imageData = UIImageJPEGRepresentation(profilePic.image!, 1.0)
            let imageFile = PFFile(name:"\(nameTextField.text!)ProfilePicture.png", data:imageData!)
            let Imagename = (nameTextField.text)!.stringByReplacingOccurrencesOfString(" ", withString: "")
            uCurrentUser["imageName"] = "\(Imagename)Picture"
            //uCurrentUser["imageName"] = "\(nameTextField.text!)Picture"
            uCurrentUser["imageFile"] = imageFile
            
            uCurrentUser.saveInBackground()
            
            print("saved to parse")
            self.navigationController!.popToRootViewControllerAnimated(true)
        }
        else {
            print("No Current User")
        }
    }
    
    func getInformationFromServer() {
        if let uCurrentUser = currentUser {
            currentUser = uCurrentUser
            //print("\(uCurrentUser["Name"] as! String)")
            NavBarTitle.title = (uCurrentUser["Name"] as! String)
            nameTextField.text = (uCurrentUser["Name"] as! String)
            
            
            experience = (uCurrentUser["Experience"] as! String)
            gender = (uCurrentUser["Gender"] as! String)
            print("Got Gender: \(gender) & Experience: \(experience)")
            switch gender {
            case "Male":
                genderSegment = 0
            case "Female":
                genderSegment = 1
            case "Other":
                genderSegment = 2
            default:
                break;
            }
            switch experience {
            case "Pick Up":
                experienceSegment = 0
            case "College":
                experienceSegment = 1
            case "Club":
                experienceSegment = 2
            default:
                break;
            }
            
            genderSegControl.selectedSegmentIndex = genderSegment
            experienceSegControl.selectedSegmentIndex = experienceSegment
            
            print("current username: \(uCurrentUser["username"]as! String)")
            
            
            let userImageFile = uCurrentUser["imageFile"] as? PFFile
            userImageFile?.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        self.profilePic.image = UIImage(data:imageData)
                    }
                    
                }
                
            }
        } else {
            alertView("Error", message: "Could not contact server")
            print("No Current User")
            
        }
    }
    
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
            experience = "Pick Up"
            print("Selected Exp: \(experience) ")
        case 1:
            experience = "College"
            print("Selected Exp: \(experience) ")
        case 2:
            experience = "Club"
            print("Selected Exp: \(experience) ")
        default:
            break;
        }
        
    }
    
    //MARK: - Image Methods
    
    
    @IBAction func openPhotoLibraryButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        //print("picked Image")
        profilePic.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //MARK: - Alert View
    
    func alertView(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getInformationFromServer()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}
