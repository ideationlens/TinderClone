//
//  CustomMatchCell.swift
//  Tinder
//
//  Created by Douglas Putnam on 8/4/18.
//  Copyright © 2018 Douglas Putnam. All rights reserved.
//

import UIKit

class CustomMatchCell: UITableViewCell {
    
    var mainImage : UIImage?
    var message : String?
    
    // Declare and define mainImageView
    var mainImageView : UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Declare and define messageView
    var messageView : UITextView = {
        var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        return textView
    }()
    
    // Initialize cell with image view and message view
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Add image and text views to custom cell
        self.addSubview(mainImageView)
        self.addSubview(messageView)
        
        // Anchor image view to the left side of the cell
        mainImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        mainImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        mainImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        mainImageView.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        // Set image view to aspect fill
        mainImageView.contentMode = .scaleAspectFit
        
        // Anchor messageView to the right side of the cell
        messageView.leftAnchor.constraint(equalTo: mainImageView.rightAnchor).isActive = true
        messageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        messageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        messageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        
    }
    
    // Populate cells with data
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let message = message {
            messageView.text = message
        }
        
        if let mainImage = mainImage {
            mainImageView.image = mainImage
        }
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
