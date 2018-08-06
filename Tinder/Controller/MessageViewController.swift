//
//  MessageViewController.swift
//  Tinder
//
//  Created by Douglas Putnam on 8/5/18.
//  Copyright © 2018 Douglas Putnam. All rights reserved.
//

import Parse
import UIKit

class MessageViewController: UIViewController, UINavigationControllerDelegate {

    var match = PFUser()
    var matchData = CustomMatchCell()
    
    @IBOutlet weak var navBar: UINavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func setupNavBar() {
        //add title - user profile picture and name
        let titleImageView = UIImageView(image: matchData.mainImage)
        let titleImageDimensions: CGFloat = 30
        titleImageView.frame = CGRect(x: 0, y: 0, width: titleImageDimensions, height: titleImageDimensions)
        titleImageView.heightAnchor.constraint(equalToConstant: titleImageDimensions).isActive = true
        titleImageView.widthAnchor.constraint(equalToConstant: titleImageDimensions).isActive = true
        titleImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImageView
        
        //add right nav bar button - flag user action
        let flagButton = UIButton(type: .system)
        let rightButtonDimensions: CGFloat = 25
        flagButton.setImage(#imageLiteral(resourceName: "red-flag-icon"), for: .normal)
        flagButton.frame = CGRect(x: 0, y: 0, width: rightButtonDimensions, height: rightButtonDimensions)
        flagButton.widthAnchor.constraint(equalToConstant: rightButtonDimensions).isActive = true
        flagButton.heightAnchor.constraint(equalToConstant: rightButtonDimensions).isActive = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: flagButton)
        
        //set background color to white
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
}
