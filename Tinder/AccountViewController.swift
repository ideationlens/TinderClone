//
//  AccountViewController.swift
//  Tinder
//
//  Created by Douglas Putnam on 8/1/18.
//  Copyright © 2018 Douglas Putnam. All rights reserved.
//

import Parse
import UIKit

class AccountViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameAndAgeLabel: UILabel!
    @IBOutlet weak var jobAndCompanyLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //POPULATE VIEW WITH USER INFO
        //load user image
        if let photo = PFUser.current()?["profilePicture1"] as? PFFile {
            photo.getDataInBackground { (data, error) in
                if let imageData = data {
                    guard let image = UIImage(data: imageData) else {fatalError("Could not format image data")}
                    self.userImageView.image = image
                }
            }
        } else {
            print("Could not load user profile picture")
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Image Picker

    
    // MARK: - Navigation
     
     @IBAction func settingsButtonPressed(_ sender: Any) {
        print("settingsButtonPressed on Account View Controller")
        //performSegue(withIdentifier: "settingsSegue", sender: nil)
     }
    

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
    

}
