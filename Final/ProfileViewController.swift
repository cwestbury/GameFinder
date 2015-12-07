//
//  ProfileViewController.swift
//  Final
//
//  Created by Cameron Westbury on 12/6/15.
//  Copyright © 2015 Cameron Westbury. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    //MARK: - Properties
    @IBOutlet var profilePic: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var genderLabel: UILabel!
    @IBOutlet var experienceLabe: UILabel!
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var ageTextField: UITextField!
    @IBOutlet var genderTextField: UITextField!
    var currentUser = PFUser.currentUser()
    //@IBOutlet var picImageButton: UIButton!
    
    //MARK: - Save/Querry Server Methods
    
    @IBAction func submitValuesToParse(sender: UIButton){
        //var objectToSave :PFUser!
        
        if let uCurrentUser = currentUser {
            currentUser = uCurrentUser
            
            //            objectToSave = PFObject(className: "Places")
            //        }
            uCurrentUser["Name"] = nameTextField.text
            //uCurrentUser["Age"] = ageTextField.text
            //uCurrentUser["Gender"] = genderTextField.text
            
            
            let imageData = UIImageJPEGRepresentation(profilePic.image!, 1.0)
            let imageFile = PFFile(name:"\(nameTextField.text!)ProfilePicture.png", data:imageData!)
            uCurrentUser["imageName"] = "\(nameTextField.text!)Picture"
            uCurrentUser["imageFile"] = imageFile
            uCurrentUser.saveInBackground()
            print("saved to parse")
            //self.navigationController!.popToRootViewControllerAnimated(true)
        }
        else {
            print("No Current User")
        }
    }
    
    func getInformationFromServer() {
        if let uCurrentUser = currentUser {
            currentUser = uCurrentUser
            
            nameLabel.text! = (uCurrentUser["Name"] as! String)
            
            
            let userImageFile = uCurrentUser["imageFile"] as! PFFile
            userImageFile.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        self.profilePic.image = UIImage(data:imageData)
                    }
                    
                }
                
            }
        } else {
            print("No Current User")

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
        self.dismissViewControllerAnimated(true, completion: nil);
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
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
