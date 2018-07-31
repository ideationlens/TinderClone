//
//  LogInViewController.swift
//  Tinder
//
//  Created by Douglas Putnam on 7/25/18.
//  Copyright © 2018 Douglas Putnam. All rights reserved.
//

import Parse
import UIKit

class LogInViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        errorLabel.isHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logInButtonPressed(_ sender: Any) {
        
        let user = PFUser()
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        
        PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if error == nil {
                
                print("Sign in successful")
                //homeSugue
                //updateSegue
                self.performSegue(withIdentifier: "updateSegue", sender: nil)
                //Go to Home screen
                
            } else {
                
                print("Error signing in. \(error!)")
                
                if let currentError = error as NSError? {
                    
                    if let errorMessage = currentError.userInfo["error"] as? String {
                        
                        self.errorLabel.text = errorMessage
                        self.errorLabel.isHidden = false
                        
                    }
                }
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current() != nil {
            self.performSegue(withIdentifier: "updateSegue", sender: nil)
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
        //should check username and password before continuing
        
        let user = PFUser()
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        
        user.signUpInBackground { (success, error) in
            if success {
                
                print("Sign up successful")
                self.performSegue(withIdentifier: "updateSegue", sender: nil)
                //Go to Update User Profile Settings
                
            } else {
                
                print("Error registering user")
                
                if let currentError = error as NSError? {
                    
                    if let errorMessage = currentError.userInfo["error"] as? String {
                        
                        self.errorLabel.text = errorMessage
                        self.errorLabel.isHidden = false
                        
                    }
                }
            }
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
