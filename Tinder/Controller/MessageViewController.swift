//
//  MessageViewController.swift
//  Tinder
//
//  Created by Douglas Putnam on 8/5/18.
//  Copyright © 2018 Douglas Putnam. All rights reserved.
//

import Parse
import UIKit

class MessageViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    // Variable Passed in from Match View Controller
    var match : PFUser? {
        didSet {
            print("PFUser Id = \(match!.objectId!)")
        }
    }
    // Variable Passed in from Match View Controller
    var matchData : CustomMatchCell? {
        didSet {
            setupNavBar()
            print("User accessing messages with \(matchData?.message ?? "another user")")
        }
    }
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var newMessageView: UITextView!
    
    var messages = [Message]() {
        didSet {
            print("We have \(messages.count) message/s")
            let cell = CustomMessageCell()
            cell.message = messages[messages.count - 1]
            cells.append(cell)
        }
    }
    var cells = [CustomMessageCell]() {
        didSet {
            print("Time to reload data")
            messageTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("The message view did load")
        // SETUP TABLE VIEW
        
        // Table View Delegate Declaration
        messageTableView.delegate = self
        
        // Table View Datasource Declaration
        messageTableView.dataSource = self
        
        // Table View Configuration
        configureTableView()
        
        // LOAD MESSAGES FOR TABLE VIEW
        loadMessages()
        
    }
    
    // MARK: TABLE VIEW METHODS
    
    // Return the count of messages in the thread
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Returning \(cells.count) cell/s to load")
        return cells.count
    }
    
    // Return each message
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = cells[indexPath.row]
        
        // Populate cell data
        cell.layoutSubviews()
        
        // Update layout and appearance based on who sent the message
        if cell.message.recipientId == matchData?.userId {
            cell.appearAsSentMessage()
        } else {
            cell.appearAsReceivedMessage()
        }
        return cell
    }
    
    // Configure Table View
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 80.0
        messageTableView.separatorStyle = .none
    }
    
    
    
    // MARK: - MESSAGING METHODS
    func loadMessages() {
        let m1 = Message()
        m1.message = "Hi Dicey! This is Douglas"
        m1.recipientId = "bzsofnV0xA"
        m1.senderId = "C0GEYXsGr1"
        messages.append(m1)
        
        let m2 = Message()
        m2.message = "Hi Douglas! What brings a fella like you to a place like this?!"
        m2.recipientId = "C0GEYXsGr1"
        m2.senderId = "bzsofnV0xA"
        messages.append(m2)
        
        let m3 = Message()
        m3.message = "Well, I could ask you the same thing but I assume your answer is the same as mine. I am just a hopeless romantic looking for love in all the wrong places. All in hopes of match with a lady like you!"
        m3.recipientId = "bzsofnV0xA"
        m3.senderId = "C0GEYXsGr1"
        messages.append(m3)
        
        let m4 = Message()
        m4.message = "Mister! Don't think you can swoon me that easily. I have been holding out for the right guy and I am not about to fall for cliche words and confidence."
        m4.recipientId = "C0GEYXsGr1"
        m4.senderId = "bzsofnV0xA"
        messages.append(m4)
        messageTableView.reloadData()
    }
    
    
    
    
    // MARK: - BUTTONS AND NAVIGATION METHODS
    
    // Send user's new message
    @IBAction func sendButtonPressed(_ sender: Any) {
    }
    
    // Return user to match view controller when top left back button pressed
    @objc @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    // Setup the Navigation Bar Items
    func setupNavBar() {
        
        // Add title - user profile picture and name
        if let image = matchData?.mainImage {
            print("Houston, we have an image")
            
            let titleImageView = UIImageView(image: image)
            let titleImageDimensions: CGFloat = 100
            titleImageView.frame = CGRect(x: 0, y: 0, width: titleImageDimensions, height: titleImageDimensions)
            titleImageView.heightAnchor.constraint(equalToConstant: titleImageDimensions).isActive = true
            titleImageView.widthAnchor.constraint(equalToConstant: titleImageDimensions).isActive = true
            titleImageView.contentMode = .scaleAspectFit
            navigationItem.titleView = titleImageView
        }
        
        //add left nav bar button - back
        let backButton = UIButton(type: .system)
        let leftButtonDimensions: CGFloat = 30
        backButton.setImage(#imageLiteral(resourceName: "back_btn_light"), for: .normal)
        backButton.frame = CGRect(x: 0, y: 0, width: leftButtonDimensions, height: leftButtonDimensions)
        backButton.widthAnchor.constraint(equalToConstant: leftButtonDimensions).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: leftButtonDimensions).isActive = true
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        //add right nav bar button - flag user action
        let flagButton = UIButton(type: .system)
        let rightButtonDimensions: CGFloat = 30
        flagButton.setImage(#imageLiteral(resourceName: "red-flag-icon").withRenderingMode(.alwaysOriginal), for: .normal)
        flagButton.frame = CGRect(x: 0, y: 0, width: rightButtonDimensions * 1.4, height: rightButtonDimensions)
        flagButton.widthAnchor.constraint(equalToConstant: rightButtonDimensions * 1.4).isActive = true
        flagButton.heightAnchor.constraint(equalToConstant: rightButtonDimensions).isActive = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: flagButton)
        
        //set background color to white
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        navigationController?.navigationBar.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
}
