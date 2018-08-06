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
    
    //var matchCount: Int = 1
    var matches = [PFUser]()
    var data = [CustomMatchCell]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SETUP TABLE VIEW
        
        // Table View Delegate Declaration
        matchTableView.delegate = self
        
        // Table View Datasource Declaration
        matchTableView.dataSource = self

        // Table View Configuration
        configureTableView()
        
        // Add tap gesture to match table view
//        let matchTableViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(matchTableViewTapped))
//        matchTableView.addGestureRecognizer(matchTableViewTapGesture)
        
        // LOAD MATCHES FOR TABLE VIEW
        loadUserMatches()
        
        // Do any additional setup after loading the view.
    }

    

    // MARK: - TABLE VIEW METHODS
    
    // GO TO MESSAGE VIEW CONTROLLER WHEN USER SELECTS A MESSAGE
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row selected = \(indexPath.row)")
        print("Next stop: MessageViewController")
        
        performSegue(withIdentifier: "messageSugue", sender: nil)
    }
    
    // TABLE VIEW DATA SOURCE - NUMBER OF ROWS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Returning value \(data.count) as the number of rows to load")
        return data.count
    }
    
    // TABLE VIEW DATA SOURCE - CELL FOR ROW
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("Working on cell \(indexPath.row)")
        
        // Set cell equal to custome cell - Match Thread Table View Cell
        let cell = data[indexPath.row]
        
        // Display data
        cell.layoutSubviews()
        
        print("Done working on cell")
        
        return cell
    }
    
    // Configure Table View
    func configureTableView() {
        matchTableView.rowHeight = UITableViewAutomaticDimension
        matchTableView.estimatedRowHeight = 80.0
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
        
        //Fetch query results and append results to local variable (matchCandidates, data)
        query.findObjectsInBackground { (queryResults, error) in
            if let objects = queryResults {
                
                print("\(objects.count) matches found!")
                var cellDataIndex = 0
                for object in objects {
                    
                    // Make sure that query result object is a user
                    guard let match = object as? PFUser else {fatalError("Query result could not be cast as PFUser")}
                    
                    // Save user to local variable
                    self.matches.append(match)
                    
                    // Extract user data: name, userId and profile picture
                    let cellData = CustomMatchCell()
                    if let name = match["profileName"] as? String {
                        cellData.message = name
                    } else if let username = match.username {
                        cellData.message = username
                    } else {
                        cellData.message = "User name unavailable"
                    }
                    
                    // Extract user data: userId
                    cellData.userId = match.objectId
                    
                    // Append user data to local variable - data
                    self.data.append(cellData)
                    
                    // Extract and save user data: profile picture
                    self.getProfilePicture(forUser: match, withIndex: cellDataIndex)
                    
                    print("Candidate \(object.objectId!) identified")
                    cellDataIndex += 1
                }
                
                self.matchTableView.reloadData()
            }
        }
        
    }
    
    // Load Profile Images
    func getProfilePicture(forUser user: PFUser, withIndex index: Int) {
        
        print("Working on loading profile picture for user \(index)")
        
        if let photo = user["profilePicture1"] as? PFFile {
            photo.getDataInBackground { (data, error) in
                if let imageData = data {
                    
                    // Get UIImage
                    guard let image = UIImage(data: imageData) else {fatalError("Could not format image data")}
                    
                    // Resize image
                    let resizedImage = self.resizeImage(image: image, targetSize: CGSize(width: 80.0, height: 80.0))
                    
                    // Store image in local variable - data
                    self.data[index].mainImage = resizedImage
                    
                    print("Finished loading picture \(index)")
                    self.matchTableView.reloadData()
                    
                } else {
                    print("Failed to load picture \(index). Image data was nil")
                }
            }
        } else {
            print("Failed to load picture. Could not locate image file")
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = matchTableView.indexPathForSelectedRow {
            let userSelection = indexPath.row
            print("The selected row is \(userSelection)")
            let destinationVC = segue.destination as! MessageViewController
            //data[userSelection].mainImage = resizeImage(image: data[userSelection].mainImage!, targetSize: CGSize(width: 30.0, height: 30.0))
            destinationVC.match = matches[userSelection]
            destinationVC.matchData = data[userSelection]
        }
        
        
    }
    
    
    
    
    
    
}
