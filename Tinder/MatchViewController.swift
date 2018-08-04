//
//  MatchViewController.swift
//  Tinder
//
//  Created by Douglas Putnam on 8/3/18.
//  Copyright © 2018 Douglas Putnam. All rights reserved.
//

import Parse
import UIKit

class MatchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var matchTableView: UITableView!
    

    
    var matchCount: Int = 1
    var matches = [PFUser]()
    var matchProfilePictures = [UIImage?]()
    
    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SETUP TABLE VIEW
        // Table View Delegate Declaration
        matchTableView.delegate = self
        // Table View Datasource Declaration
        matchTableView.dataSource = self
        // Table View Custom Cell Registration
        matchTableView.register(UINib(nibName: "MatchThreadTableViewCell", bundle: nil), forCellReuseIdentifier: "MatchThreadTableViewCell")
        // Table View Configuration
        configureTableView()
        
        // LOAD MATCHES FOR TABLE VIEW
        loadUserMatches()
        
        // Do any additional setup after loading the view.
    }

    

    // MARK: - TABLE VIEW METHODS
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Returning value \(matchCount) as the number of rows to load")
        return matchCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("Working on cell \(indexPath.row)")
        
        // Set cell equal to customer cell - Match Thread Table View Cell
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MatchThreadTableViewCell",
            for: indexPath
            ) as! MatchThreadTableViewCell
        
        // Confirm that matches were found before trying to populate table view cells
        if matches.count > indexPath.row {
            // Set cell's image view equal to match's profile picture
            if matchProfilePictures.count > indexPath.row {
                if let userProfilePicture = matchProfilePictures[indexPath.row] {
                    cell.matchImageView.image = userProfilePicture
                    cell.matchImageView.contentMode = .scaleAspectFill
                    cell.matchImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 80)
                    cell.matchImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 80)
                }
            }
            // Set cell's label equal to match's profile name
            if let profileName = matches[indexPath.row]["profileName"] as? String {
                cell.matchLabel.text = profileName
                print("Message from \(profileName)")
            } else {
                print("Name not found")
            }
        } else {
            // Set cell's label to default
            cell.matchLabel.text = "No matches found."
        }
        
        print("Done working on cell")
        
        return cell
    }
    
    // Configure Table View
    func configureTableView() {
        //matchTableView.rowHeight = UITableViewAutomaticDimension
        //matchTableView.estimatedRowHeight = 80.0
        matchTableView.separatorStyle = .singleLine
    }
    
    
    // MARK: - PARSE METHODS
    
    func loadUserMatches() {
        
        // Get match count by querying parse
        guard let query = PFUser.query() else {fatalError("Can not initiate a user query")}
        
        // Filter for users that have been accepted by user
        if let acceptedUsers = PFUser.current()?["acceptedCandidates"] as? [String] {
            print("Current user has swiped right \(acceptedUsers.count) times")
            query.whereKey("objectId", containedIn: acceptedUsers)
        }
        
        // Filter for users interested in current user
        if let userId = PFUser.current()?.objectId {
            query.whereKey("acceptedCandidates", contains: userId)
        }
        
        // Load last message date between current user and matches for sorting by recency
        
        //Fetch query results and append results to local variable (matchCandidates)
        query.findObjectsInBackground { (queryResults, error) in
            if let objects = queryResults {
                
                print("\(objects.count) matches found!")
                
                for object in objects {
                    guard let match = object as? PFUser else {fatalError("Query result could not be cast as PFUser")}
                    self.matches.append(match)
                    self.getProfilePicture(forUser: match)
                    print("Candidate \(object.objectId!) identified")
                }
                
                self.matchCount = self.matches.count
                self.matchTableView.reloadData()
            }
        }
        
    }
    
    // Load Profile Images
    func getProfilePicture(forUser user: PFUser) {
        
        print("Working on loading profile picture for user \(user.objectId ?? "")")
        
        if let photo = user["profilePicture1"] as? PFFile {
            photo.getDataInBackground { (data, error) in
                if let imageData = data {
                    // Get UIImage
                    guard let image = UIImage(data: imageData) else {fatalError("Could not format image data")}
                    // Resize image
                    let resizedImage = self.resizeImage(image: image, targetSize: CGSize(width: 70.0, height: 70.0))
                    // Store image in locally
                    self.matchProfilePictures.append(resizedImage)
                    print("Finished loading picture")
                    self.matchTableView.reloadData()
                } else {
                    self.matchProfilePictures.append(nil)
                    print("Failed to load picture. Image data was nil")
                }
            }
        } else {
            print("Failed to load picture. Could not locate an image file")
            self.matchProfilePictures.append(nil)
        }
    }
    
    // MARK: - IMAGE METHODS
    // Resize an image
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    // MARK: - NAVIGATION
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        //loadUserMatches()
    }
    
    @IBAction func feedButtonPressed(_ sender: Any) {
        matchTableView.reloadData()
    }
    
    
}
