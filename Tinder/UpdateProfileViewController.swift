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
        
        // POPULATE VIEW WITH USER INFO
        // Load user image
        if let photo = PFUser.current()?["profilePicture1"] as? PFFile {
            photo.getDataInBackground { (data, error) in
                if let imageData = data {
                    guard let image = UIImage(data: imageData) else {fatalError("Could not format image data")}
                    self.profileImageView.image = image
                }
            }
        } else {
            print("Could not load user profile picture")
        }
        
        // Load username
        if let profileName = PFUser.current()?["profileName"] as? String {
            usernameTextField.text = profileName
        } else if let username = PFUser.current()?["username"] as? String {
            usernameTextField.text = username
        }
        
        // Load age
        if let age = PFUser.current()?["age"] as? String {
            userAgeTextField.text = age
        }
        
        // Load user gender
        if let isWoman = PFUser.current()?["isFemale"] as? Bool {
            genderSwitch.isOn = isWoman
        }
        
        // Load user interest
        if let isInterestedInWomen = PFUser.current()?["isInterestedInWomen"] as? Bool {
            interestSwitch.isOn = isInterestedInWomen
        }
        
        // Update users location
        updateUserLocation()
        
        //Creating new users for testing purposes
        //createWoman()
        
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
            PFUser.current()?["profileName"] = username
        }
        
        if let age = userAgeTextField.text {
            PFUser.current()?["age"] = age
        }
        
        PFUser.current()?["isFemale"] = genderSwitch.isOn
        PFUser.current()?["isInterestedInWomen"] = interestSwitch.isOn
        saveUserData()
        
        dismiss(animated: true, completion: nil)
        //performSegue(withIdentifier: "homeSegue", sender: nil)
    }
    
    
    // MARK: - PARSE (BACKEND) METHODS
    
    // METHOD TO SAVE USER DATA
    func saveUserData() {
        PFUser.current()?.saveInBackground(block: { (success, error) in
            if success {
                print("User data has been saved")
            } else {
                print("Error registering user")
                if let errorMessage = self.unwrap(error: error) {
                    self.errorMessageLabel.text = errorMessage
                    self.errorMessageLabel.isHidden = false
                }
            }
        })
        
    }
    
    
    // METHOD FOR UPDATING THE USERS CURRENT LOCATION
    func updateUserLocation() {
        PFGeoPoint.geoPointForCurrentLocation { (geoPoint, error) in
            if error != nil {
                print("Error encountered while trying to get geoPoint")
                self.unwrapAndPrint(error: error)
            } else {
                if let location = geoPoint {
                    PFUser.current()?["location"] = location
                    PFUser.current()?.saveInBackground()
                }
            }
        }
    }
    
    // METHOD FOR UNWRAPPING AND PRINT ERRORS RETURNED BY PARSE
    func unwrapAndPrint(error: Error?) {
        if let message = unwrap(error: error) {
                print(message)
        }
    }
    
    func unwrap(error: Error?) -> String? {
        if let parseError = error as NSError? {
            if let errorMessage = parseError.userInfo["error"] as? String {
                return errorMessage
            }
        }
        return nil
    }
    
    func createWoman() {
        
        var counter = 0
        
        let names = ["Alexa"
                    ,"Becky"
                    ,"Catherine"
                    ,"Elynn"
                    ,"Jackie"
                    ,"Jasmine"
                    ,"Katie"
                    ,"Lisa"
                    ,"Melissa"
                    ,"Rachel"
                    ,"Sarah"
                    ,"Stacey"
                    ,"Tiffany"
                    ,"Loala"
                    ,"Chrys"
                    ,"Cheyenne"
                    ,"Jennifer"
                    ,"Lexi"
                    ]
        
        
        let imageURLs = ["https://www.nancyjophoto.com/gallery/kids/teengirlheadshot.jpg"
                        ,"http://www.jaydjackson.com/media/cache/a6/28/a62803155c388b91e7d7568aaf6a3257.jpg"
                        ,"https://www.robertmcgee.ca/wp-content/uploads/2016/12/actor-headshots-Toronto-2027.jpg"
                        ,"https://img.etimg.com/thumb/msid-59878652,width-643,imgsize-122108,resizemode-4/this-new-app-will-help-you-perfect-the-art-of-taking-a-selfie.jpg"
                        ,"http://www.jaydjackson.com/media/cache/61/db/61db9fda96be7565b70b1afb870ff9b6.jpg"
                        ,"http://www.jaydjackson.com/media/cache/4d/de/4dde43a6f23cd0dfafb8380f9ff08bd0.jpg"
                        ,"https://ae01.alicdn.com/kf/HTB1mh0wSVXXXXX_aXXXq6xXFXXXS.jpg"
                        ,"https://cdn.images.dailystar.co.uk/dynamic/140/photos/264000/Cheryl-Cole-selfie-995264.jpg"
                        ,"http://dalalnews.com/wp-content/uploads/2018/04/dalal-news-YanetGarcia6.jpg"
                        ,"https://nbclatino.files.wordpress.com/2013/02/isaheadshot-crop.jpg"
                        ,"https://static.makeuseof.com/wp-content/uploads/2017/07/bad-selfie-habits-670x447.jpg"
                        ,"https://i.pinimg.com/736x/57/48/40/5748408fcb4588168e1afdb350fcf214--headshot-ideas-headshot-poses.jpg"
                        ,"http://michaelroud.com/wp-content/uploads/2017/02/FAITH-DYER-RETOUCHES-copy-650x975.jpg"
                        ,"https://static1.squarespace.com/static/54d942d5e4b0c4d5e7b8e4f0/54d94392e4b01f7975efddce/5acfa8e26d2a73de679ee24f/1523558680724/acting_headshots-12.jpg"
                        ,"https://www.ajc.com/rf/image_inline/Pub/p8/AJC/2017/11/09/Images/stephe-headshot2%20(002)_2939x1839.jpg"
                        ,"http://www.pazzaphoto.com/wp-content/uploads/2014/06/cleveland-ohio-model-headshot-photographer-pazza-photography.jpg"
                        ]
        
        for imageURL in imageURLs {
            
            print("Counter: \(counter)")
            if let url = URL(string: imageURL) {
                if let data = try? Data(contentsOf: url) {
                    if let imageFile = PFFile(name: "Photo.jpg", data: data) {
                        
                        print("Preparing to create new user")
                        
                        let user = PFUser()
                        
                        user["profilePicture1"] = imageFile
                        user.username = names[counter]
                        user.password = names[counter]
                        user["age"] = String(counter + 20)
                        user["isFemale"] = true
                        user["isInterestedInWomen"] = false
                        user["isTestAccount"] = true
                        user.signUpInBackground { (success, error) in
                            if success {
                                print("New account created")
                            }
                        }
                        
                    }
                }
            }
            
            counter += 1
        }
        
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
