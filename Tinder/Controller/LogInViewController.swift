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
    
    override func viewDidAppear(_ animated: Bool) {
        continueAsCurrentUser()
    }

    // MARK: - AUTHENTICATION METHODS
    
    // MARK: AUTO LOGIN METHOD
    func continueAsCurrentUser() {
        if PFUser.current() != nil {
            segueIntoApp()
        }
    }
    
    // MARK: PARSE LOG IN METHOD
    @IBAction func logInButtonPressed(_ sender: Any) {
        
        let user = PFUser()
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        
        PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: passwordTextField.text!) { (user, error) in
            
            if error == nil {
                
                print("Sign in successful. Seguing into App next.")
                self.segueIntoApp()
                
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
    
    // MARK: PARSE REGISTRATION METHOD
    @IBAction func signUpButtonPressed(_ sender: Any) {
        
        //should check username and password before continuing
        
        let user = PFUser()
        user.username = usernameTextField.text
        user.password = passwordTextField.text
        
        user.signUpInBackground { (success, error) in
            if success {
                
                print("Sign up successful. Next stop: UpdateProfileViewController")
                self.segueIntoApp()
                
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
    
    // MARK: - NAVIGATION
    
    func segueIntoApp() {
        usernameTextField.text = ""
        passwordTextField.text = ""
        if PFUser.current()?["isFemale"] != nil && PFUser.current()?["isInterestedInWomen"] != nil {
            self.performSegue(withIdentifier: "homeSegue", sender: nil)
        } else {
            performSegue(withIdentifier: "updateSegue", sender: nil)
        }
    }
    
}
