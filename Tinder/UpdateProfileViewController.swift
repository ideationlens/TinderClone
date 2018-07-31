//
//  UpdateProfileViewController.swift
//  Tinder
//
//  Created by Douglas Putnam on 7/30/18.
//  Copyright © 2018 Douglas Putnam. All rights reserved.
//

import Parse
import UIKit

class UpdateProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var genderSwitch: UISwitch!
    @IBOutlet weak var interestSwitch: UISwitch!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var userAgeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorMessageLabel.isHidden = true
        
        //POPULATE VIEW WITH USER INFO
        //load user image
        if let imageData = PFUser.current()?["profilePicture1"] as? Data {
            guard let image = UIImage(data: imageData, scale: 1.0) else {fatalError("Could not format image data")}
            profileImageView.image = image
            print("Loading picture")
        } else {
            print("Could not load image data")
        }
        
        //load user gender
        if let isWoman = PFUser.current()?["isFemale"] as? Bool {
            genderSwitch.isOn = isWoman
        }
        
        //load user interest
        if let isInterestedInWomen = PFUser.current()?["isInterestedInWomen"] as? Bool {
            interestSwitch.isOn = isInterestedInWomen
        }
        
        //load username
        if let age = PFUser.current()?["age"] as? String {
            userAgeTextField.text = age
        }
        
        
        //load age
        if let username = PFUser.current()?["username"] as? String {
            userAgeTextField.text = username
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Update Profile Picture Methods
    // When user taps the Update Profile Picture button
    @IBAction func updateProfileImagePressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    // when the user selects a picture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImageView.image = userImage
        }
        
        dismiss(animated: true, completion: nil)
        
        if let image = profileImageView.image {
            guard let imageData = UIImagePNGRepresentation(image)
                else {fatalError("Could not convert image to PNG format")}
            PFUser.current()?["profilePicture1"] = PFFile(name: "profilePicture1.png", data: imageData)
        }
    }
    
    @IBAction func genderSwitched(_ sender: Any) {
        PFUser.current()?["isFemale"] = genderSwitch.isOn
    }
    
    @IBAction func interestSwitched(_ sender: Any) {
        PFUser.current()?["isInterestedInWomen"] = interestSwitch.isOn
    }
    
    @IBAction func donePressed(_ sender: Any) {
        
        if let username = usernameTextField.text {
            PFUser.current()?["username"] = username
        }
        
        if let age = userAgeTextField.text {
            PFUser.current()?["age"] = age
        }
        
        PFUser.current()?["isFemale"] = genderSwitch.isOn
        PFUser.current()?["isInterestedInWomen"] = interestSwitch.isOn
        saveUserData()
    }
    
    
    // MARK: - Parse Backend Methods
    // save user data
    func saveUserData() {
        PFUser.current()?.saveInBackground(block: { (success, error) in
            if success {
                print("User data has been saved")
            } else {
                print("Error registering user")
                if let currentError = error as NSError? {
                    if let errorMessage = currentError.userInfo["error"] as? String {
                        self.errorMessageLabel.text = errorMessage
                        self.errorMessageLabel.isHidden = false
                    }
                }
            }
        })
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
