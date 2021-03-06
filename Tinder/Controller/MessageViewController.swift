//
//  MessageViewController.swift
//  Tinder
//
//  Created by Douglas Putnam on 8/5/18.
//  Copyright © 2018 Douglas Putnam. All rights reserved.
//

import Parse
import UIKit

class MessageViewController: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var composeMessageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var composeMessageView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    // Variable Passed in from Match View Controller
    var match : PFUser? {
        didSet {
            print("PFUser Id = \(match!.objectId!)")
        }
    }
    // Variable Passed in from Match View Controller
    var matchData : CustomMatchCell? {
        didSet {
            
            print("User accessing messages with \(matchData?.message ?? "another user")")
        }
    }
    
    let refreshControl = UIRefreshControl()
    
  
    
    var localMessages = [Message]() {
        didSet {
            print("We have \(localMessages.count) message/s")
            let cell = CustomMessageCell()
            cell.message = localMessages[localMessages.count - 1]
            cells.append(cell)
        }
    }
    var cells = [CustomMessageCell]() {
        didSet {
            print("Time to reload data")
            //messageTableView.reloadData()
        }
    }
    
    // VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        print("The message view did load")
        
        // SETUP NAV BAR
        setupNavBar()
        
        // SETUP TABLE VIEW
        configureTableView()
        
        // SETUP MESSAGE TEXT VIEW
        configureMessageTextView()
        
    }
    
    // MARK: TABLE VIEW DELEGATE METHODS
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        messageTextView.endEditing(true)
        //messageTableView.deselectRow(at: indexPath, animated: false)
    }
    
    // Configure Table View
    func configureTableView() {
        
        // Declare Delegate
        messageTableView.delegate = self
        
        // Declare Datasource
        messageTableView.dataSource = self
        
        // Specify General Layout Specs
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 80.0
        messageTableView.separatorStyle = .none
        
        // Load Messages into Table View
        refreshMessages()
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(pullRefresh), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Arial", size: 12)]
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching new messages ...", attributes: attributes)
        
        // Add refresh feature to Table View so that user can refresh messages by pulling down
        if #available(iOS 10.0, *) {
            messageTableView.refreshControl = refreshControl
        } else {
            messageTableView.addSubview(refreshControl)
        }
        
        
    }
    
    @objc func pullRefresh () {
        refreshMessages()
        
    }
    
    
    
    // MARK: - MESSAGING METHODS
    
    func refreshMessages() {
        
        guard let userId = PFUser.current()?.objectId else {fatalError("Could not get current user's id to lead messages")}
        guard let matchId = matchData?.userId else {fatalError("Could not get match's id to lead messages")}
        
        // Create query for all messages between user and match that have not been downloaded to device
        let newMessageFromMatchQuery = PFQuery(className: "Message")
        let newMessageFromUserQuery = PFQuery(className: "Message")
        
        // Set search parameters to find messages only between user and match
        newMessageFromMatchQuery.whereKey("senderId", equalTo: matchId)
        newMessageFromMatchQuery.whereKey("recipientId", equalTo: userId)
        
        newMessageFromUserQuery.whereKey("senderId", equalTo: userId)
        newMessageFromUserQuery.whereKey("recipientId", equalTo: matchId)
        
        // Add time context so that we don't load duplicate messages
        if localMessages.count > 0 {
            let createdAt = localMessages[localMessages.count - 1].createdDate
            newMessageFromMatchQuery.whereKey("createdAt", greaterThan: createdAt)
            newMessageFromUserQuery.whereKey("createdAt", greaterThan: createdAt)
        }
        
        // Combine querries
        let mainQuery = PFQuery.orQuery(withSubqueries: [newMessageFromMatchQuery,newMessageFromUserQuery])
        
        // Set sorting preferences to ascending by date
        mainQuery.order(byAscending: "createdAt")
        
        // Run query and add results to local variable: localMessages
        mainQuery.findObjectsInBackground { (queryResults, error) in
            if let parseMessages = queryResults {
                
                print("\(parseMessages.count) new messages found!")
                
                // Loop through all parse messages
                for parseMessage in parseMessages {
                    
                    // Create staging area for new message
                    let newMessage = Message()
                    
                    // Transfer parseMessage data to newMessage
                    if let createdDate = parseMessage["createdAt"] as? Date {
                        newMessage.createdDate = createdDate
                    }
                    if let messageString = parseMessage["message"] as? String {
                        newMessage.message = messageString
                    }
                    if let recipientId = parseMessage["recipientId"] as? String {
                        newMessage.recipientId = recipientId
                    }
                    if let senderId = parseMessage["senderId"] as? String {
                        newMessage.senderId = senderId
                    }
                    
                    // Append newMessage to localMessages
                    self.localMessages.append(newMessage)
                    
                }
                
                // Reload messages on screen
                self.messageTableView.reloadData()
                
                // End any "in progress..." "refreshing..." animations
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                
                // Scroll to bottom of screen
                if self.localMessages.count > 0 {
                    let indexPath = IndexPath(row: self.localMessages.count-1, section: 0)
                    self.messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
                
                
                
            }
            
            
        }
    }
    
    func sendMessage() {
        
        // Check message before sending
        if messageTextView.text.count > 0 {
            
            // Disable UI while new message is being sent
            messageTextView.endEditing(true)
            messageTextView.isUserInteractionEnabled = false
            sendButton.isEnabled = false
            
            // Stage new message
            let newMessage = Message()
            if let messageString = messageTextView.text {
                newMessage.message = messageString
            } else {
                print("")
            }
            if let recipientId = matchData?.userId {
                newMessage.recipientId = recipientId
            }
            if let senderId = PFUser.current()?.objectId {
                newMessage.senderId = senderId
            }
            
            
            
            // Save new message to parse
            let parseMessage = PFObject(className: "Message")
            
            parseMessage["senderId"] = newMessage.senderId
            parseMessage["recipientId"] = newMessage.recipientId
            parseMessage["message"] = newMessage.message
            
            parseMessage.saveInBackground { (success, error) in
                if success {
                    
                    // Reset text message box - messageTextView
                    self.resetTextMessage()
                    
                    // Enable UI
                    self.messageTextView.endEditing(false)
                    self.messageTextView.isUserInteractionEnabled = true
                    self.sendButton.isEnabled = true
                    
                    self.refreshMessages()
                }
            }
            
        } else {
            print("Cannot send message")
            // Enable UI
            messageTextView.endEditing(false)
            messageTextView.isUserInteractionEnabled = true
            sendButton.isEnabled = true
        }
        
        
        
        
        
    }
    
    // MARK: - TEXT VIEW DELEGATE METHODS
    
    // CONFIGURE TEXT VIEW
    func configureMessageTextView() {
        messageTextView.delegate = self
        resetTextMessage()
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.isScrollEnabled = false
    }
    
    // TEXT VIEW BEGIN EDITING
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Toggle placeholder
        if messageTextView.textColor == UIColor.lightGray {
            messageTextView.text = nil
            messageTextView.textColor = UIColor.black
        }
        // Toggle layout for keyboard
        UIView.animate(withDuration: 0.3) {
            self.composeMessageViewHeightConstraint.constant += 263
            self.view.layoutIfNeeded()
        }
    }
    
    // TEXT VIEW DID CHANGE
    func textViewDidChange(_ textView: UITextView) {
        print("textViewDidChange")
        // Adjust row height
        let size = CGSize(width: messageTextView.frame.width, height: .infinity)
        let estimatedSize = messageTextView.sizeThatFits(size)
        messageTextViewHeightConstraint.constant = estimatedSize.height
        composeMessageViewHeightConstraint.constant = CGFloat(279) + estimatedSize.height
    }
    
    // TEXT VIEW END EDITING
    func textViewDidEndEditing(_ textView: UITextView) {
        if messageTextView.text.isEmpty {
            resetTextMessage()
        }
        // Toggle layout for keyboard
        UIView.animate(withDuration: 0.3) {
            print("Lowering ComposeMessageView")
            self.composeMessageViewHeightConstraint.constant = CGFloat(16) + self.messageTextViewHeightConstraint.constant
            self.view.layoutIfNeeded()
        }
    }
    
    // RESEST TEXT MESSAGE
    func resetTextMessage() {
        messageTextView.text = "Message"
        messageTextView.textColor = UIColor.lightGray
    }
    
    
    
    
    
    // MARK: - BUTTONS AND NAVIGATION METHODS
    
    // Send user's new message
    @IBAction func sendButtonPressed(_ sender: Any) {
        // Send message
        sendMessage()
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
            let titleImageDimensions: CGFloat = (navigationController?.navigationBar.frame.height ?? 36) * 0.8
            titleImageView.frame = CGRect(x: 0, y: 0, width: titleImageDimensions, height: titleImageDimensions)
            titleImageView.heightAnchor.constraint(equalToConstant: titleImageDimensions).isActive = true
            titleImageView.widthAnchor.constraint(equalToConstant: titleImageDimensions).isActive = true
            titleImageView.layer.cornerRadius = titleImageDimensions / 2
            titleImageView.clipsToBounds = true
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
