//
//  CustomMessageCell.swift
//  Tinder
//
//  Created by Douglas Putnam on 8/5/18.
//  Copyright © 2018 Douglas Putnam. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {

    var message = Message()
    
    // Declare and define messageView
    var messageView : UITextView = {
        var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.font = UIFont(name: "Arial", size: 19)
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 10.0;
        return textView
    }()
    
    // Initialize cell with message view
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        print("One New Message Cell Coming Up!")
        // Add text views to custom cell
        self.addSubview(messageView)
        
        // Anchor messageView to the right side of the cell

        messageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        messageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        messageView.widthAnchor.constraint(lessThanOrEqualToConstant: self.frame.width * 0.75).isActive = true
        
    }
    
    // Populate cells with data
    override func layoutSubviews() {
        super.layoutSubviews()
        print("Working on layout")
        messageView.text = message.message
        
    }
    
    // Change appearance to "Sent Message"
    func appearAsSentMessage () {
        // Sent Message Appearance (white text, blue background)
        messageView.textColor = UIColor.white
        messageView.backgroundColor = UIColor.blue
        messageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
    }
    
    
    // Change appearance to "Received Message"
    func appearAsReceivedMessage() {
        // Received Message Appearance (black text, gray background)
        messageView.textColor = UIColor.black
        messageView.backgroundColor = UIColor.lightGray
        messageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("View Cell has not been implemented")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
