//
//  ViewController.swift
//  Tinder
//
//  Created by Douglas Putnam on 7/24/18.
//  Copyright © 2018 Douglas Putnam. All rights reserved.
//

import Parse
import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var matchView: UIView!
    @IBOutlet weak var matchButton: UIButton!
    @IBOutlet weak var matchButton1: UIButton!
    @IBOutlet weak var matchButton2: UIButton!
    
    var centerPoint = [CGPoint]()
    let centerPointOffset: CGFloat = 8
    let interestMargin: CGFloat = 70
    
    var matchCandidates = [PFUser]()
    var userIds = [String]()
    var candidateCount = 0
    var candidateCounter = 0
    var loadImageCounter = 0
    var nextImage = UIImage()
    
    var wasLastImageAtPosition2 = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Start looking for match candidates
        loadMatchCandidates()
        
        // Create matchButton gesture
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(movebuttonBasedOn(gestureRecognizer:)))
        
        // Assign gesture to matchButton
        matchButton.addGestureRecognizer(gestureRecognizer)
        
        // Determine points of reference for view
        // Center of matchButton 1, 2 and 3
        centerPoint.append(CGPoint(x: matchView.bounds.width/2 + CGFloat(19)
                                  ,y: matchView.bounds.height/2 + CGFloat(navigationController!.navigationBar.frame.height / 1.75)))
        centerPoint.append(CGPoint(x: centerPoint[0].x - centerPointOffset
                                  ,y: centerPoint[0].y - centerPointOffset))
        centerPoint.append(CGPoint(x: centerPoint[0].x - centerPointOffset * CGFloat(2)
                                  ,y: centerPoint[0].y - centerPointOffset * CGFloat(2)))
        centerPoint.append(CGPoint(x: centerPoint[0].x - centerPointOffset * CGFloat(3)
                                  ,y: centerPoint[0].y - centerPointOffset * CGFloat(3)))
        
        // Get users location so they can match with people in their area
        PFGeoPoint.geoPointForCurrentLocation { (geoPoint, error) in
            if error != nil {
                print("Error encountered while trying to get geoPoint")
                self.unwrapAndPrint(error: error)
            } else {
                if let location = geoPoint {
                    PFUser.current()?["location"] = location
                    PFUser.current()?.saveInBackground()
                }
            }
        }
        
        //Setup Nav Bar Items
        setupNavBar()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {

        //Initialize swipe button positions
        matchButton.center = centerPoint[0]
        matchButton1.center = centerPoint[1]
        matchButton2.center = centerPoint[2]
        
        // Set swipe buttons content mode
        matchButton.imageView?.contentMode = .scaleAspectFill
        matchButton1.imageView?.contentMode = .scaleAspectFill
        matchButton2.imageView?.contentMode = .scaleAspectFill
        
//        print("x: \(matchButton.center.x), y: \(matchButton.center.y)")
//        print("x: \(matchButton1.center.x), y: \(matchButton1.center.y)")
//        print("x: \(matchButton2.center.x), y: \(matchButton2.center.y)")
        
    }

    // MARK: - SWIPING METHODS
    //Animate button in resopnse to swipe gesture
    @objc func movebuttonBasedOn(gestureRecognizer: UIPanGestureRecognizer) {
        
        let changeInPosition = gestureRecognizer.translation(in: view)
        
        // Move button in response to gesture
        matchButton.center = CGPoint(x: centerPoint[0].x + changeInPosition.x, y: centerPoint[0].y + changeInPosition.y)
        
        // Check if button is within the interested/not-interested margin
        if (matchButton.center.x < interestMargin) {
            
            // Transform button as it moves further to the left
            let newAlphaValue = max(0.3,matchButton.center.x / 100 + (1 - interestMargin/100))
            transformMatchButton(newAlphaValue: newAlphaValue, rotationMultiple: -1)
            
        } else if (matchButton.center.x > view.bounds.width - interestMargin) {
            
            // Transform button as it moves further to the right
            let newAlphaValue = max(0.3,(centerPoint[0].x * 2 - matchButton.center.x) / 100.0 + (1 - interestMargin/100))
            transformMatchButton(newAlphaValue: newAlphaValue, rotationMultiple: 1)
            
        }

        // Check if user let go of image (if gesture ended)
        if (gestureRecognizer.state == UIGestureRecognizerState.ended) {
            
            //Check if button is within the interested/not-interested margin
            if (matchButton.center.x < interestMargin) {
                
                rejectMatchCandidate()
            
            } else if (matchButton.center.x > view.bounds.width - interestMargin) {
                
                acceptMatchCandidate()
                
            } else {
                
                //Move button back to original position (function invoked when gesture stops)
                UIView.animate(withDuration: 0.3) {
                    self.transformMatchButton(newAlphaValue: 1.0, rotationMultiple: 0)
                    self.matchButton.center = self.centerPoint[0]
                }
                print("back to center")
                print("x: \(matchButton.center.x), y: \(matchButton.center.y)")
            }
        }
    }
    
    // Method for rejecting match candidates
    func rejectMatchCandidate () {
        
        print("Rejecting candidate \(candidateCounter + 1)")
        
        // record user's swipe to the left
        if let userId = matchCandidates[candidateCounter].objectId {
            PFUser.current()?.addUniqueObject(userId, forKey: "rejectedCandidates")
            PFUser.current()?.saveInBackground(block: { (success, error) in
                if success {
                    print("Match Candidate \(self.candidateCounter + 1) rejected")
                } else {
                    //print("Error encountered while trying to save swipe to left.")
                    self.unwrapAndPrint(error: error)
                    fatalError("Error encountered while trying to save swipe to left.")
                }
            })
        } else {
            print("Error while trying to get candidate's objectId")
        }
        
        //transform button out of view to the left
        print("moving card off screen to left")
        UIView.animate(withDuration: 0.3, animations: {
            self.transformMatchButton(newAlphaValue: 0, rotationMultiple: -2)
            self.matchButton.center = CGPoint(x: -100,
                                              y: self.centerPoint[0].y - 100)
        }) { (success) in
            if success {
                //show user the next match candidate
                print("Continuing to next candidate")
                self.slideImagesForward()
            }
        }
        
    }
    
    // Method for accepting match candidates
    func acceptMatchCandidate () {
        
        print("Accepting candidate \(candidateCounter + 1)")
        // record user's swipe to the right
        if let userId = matchCandidates[candidateCounter].objectId {
            PFUser.current()?.addUniqueObject(userId, forKey: "acceptedCandidates")
            PFUser.current()?.saveInBackground(block: { (success, error) in
                if success {
                    print("Match Candidate \(self.candidateCounter + 1) accepted")
                } else {
                    //print("Error encountered while trying to save swipe to right.")
                    self.unwrapAndPrint(error: error)
                    fatalError("Error encountered while trying to save swipe to right action.")
                }
            })
        } else {
            print("Error while trying to get candidate's objectId")
        }
        
        //transform rejected button out of view to the right
        print("Moving candidate off screen to the right")
        UIView.animate(withDuration: 0.3, animations: {
            self.transformMatchButton(newAlphaValue: 0, rotationMultiple: 2)
            self.matchButton.center = CGPoint(x: self.centerPoint[0].x * 2 + 100,
                                              y: self.centerPoint[0].y - 100)
        }) { (success) in
            if success {
                // show user the next match candidate
                print("Continuing to next candidate")
                self.slideImagesForward()
            }
        }
        
    }
    
    //When a card is discarded, make it appear as if the deck is sliding forward into original position
    func slideImagesForward() {
        
        if candidateCount > candidateCounter + 1 {
            
            // track which candidate is at the top of the deck
            candidateCounter += 1
            print("Up next, candidate \(candidateCounter + 1)")
        
            //update top button's (matchButton0) image, position over matchButton1, then set alpha back to 1
            matchButton.setImage(matchButton1.imageView?.image, for: .normal)
            matchButton.center = centerPoint[1]
            transformMatchButton(newAlphaValue: 1, rotationMultiple: 0)
        
            //update middle button's (matchButton1) image then position over matchButton
            if matchButton2.alpha == 0 {
                print("Setting middle button image to nil")
                matchButton1.setImage(nil, for: .normal)
                matchButton1.alpha = 0
            } else {
                matchButton1.setImage(matchButton2.imageView?.image, for: .normal)
            }
            matchButton1.center = centerPoint[2]
        
            //update back button's alpha value to 0, image to new image, then position to centerPoint[3]
            matchButton2.alpha = 0
            matchButton2.center = centerPoint[3]
            if let image = nextMatchCandidateImage() as UIImage? {
                matchButton2.setImage(image, for: .normal)
            } else {
                matchButton2.setImage(nil, for: .normal )
            }
        
            //Animate buttons sliding forward
            UIView.animate(withDuration: 0.4, animations: {
                self.matchButton.center = self.centerPoint[0]
                self.matchButton1.center = self.centerPoint[1]
                self.matchButton2.center = self.centerPoint[2]
                if self.wasLastImageAtPosition2 {
                    print("keeping button2 alpha value set to 0")
                    self.matchButton2.alpha = 0
                } else {
                    self.matchButton2.alpha = 1
                }
                
            }, completion: nil)
        
            if candidateCount == loadImageCounter {
                wasLastImageAtPosition2 = true
            }
        } else {
            print("No new candidates")
            print("Alert the user that there are no more matches in the area. Try again later")
        }
        
    }
    
    //Method to transform button to mimick the motion of
    func transformMatchButton(newAlphaValue: CGFloat, rotationMultiple: CGFloat) {
        matchButton.alpha = newAlphaValue
        let angle =  CGFloat(1 - newAlphaValue) * CGFloat(Float.pi/16) * rotationMultiple
        let rotation = CGAffineTransform.init(rotationAngle: angle)
        let scale = CGFloat(0.7 + 0.3 * newAlphaValue)
        let rotationAndScale = rotation.scaledBy(x: scale, y: scale)
        matchButton.transform = rotationAndScale
    }
    
    // MARK: - PAARSE METHODS
    
    func unwrapAndPrint(error: Error?) {
        if let parseError = error as NSError? {
            if let errorMessage = parseError.userInfo["error"] as? String {
                print(errorMessage)
            }
        }
    }
    
    // MARK: - Load User's Match Candidates Methods
    
    func loadMatchCandidates() {
        
        print("Starting to load potential matches")
        guard let query = PFUser.query() else {fatalError("Can not initiate a user query")}
        
        //Filter for desired sex
        if let isInterestedInWomen = PFUser.current()?["isInterestedInWomen"] {
            query.whereKey("isFemale", equalTo: isInterestedInWomen)
        }
        
        //Filter out users that have already been accepted or rejected
        var ignoredUsers: [String] = []

        if let acceptedUsers = PFUser.current()?["acceptedCandidates"] as? [String] {
            ignoredUsers += acceptedUsers
        }

        if let rejectedUsers = PFUser.current()?["rejectedCandidates"] as? [String] {
            ignoredUsers += rejectedUsers
        }

        let reviewedCandidates = ignoredUsers.count
        print("Filtering out \(reviewedCandidates) users")
        query.whereKey("objectId", notContainedIn: ignoredUsers)
        
        
        //limit how many match candidates can be loaded at one time
        query.limit = 4
        
        //Fetch query results and append results to local matchCandidates variable
        query.findObjectsInBackground { (queryResults, error) in
            if let objects = queryResults {
                print("\(objects.count) matches found...")
                for object in objects {
                    guard let matchCandidate = object as? PFUser else {fatalError("Query result could not be cast as PFUser")}
                    self.matchCandidates.append(matchCandidate)
                    print("Candidate \(object.objectId!) identified")
                }
                
                self.candidateCount = self.matchCandidates.count
                self.initializeButtonImages()
                
            }
        }
        
    }
    
    func initializeButtonImages() {
        
        // Load top image
        if let image0 = nextMatchCandidateImage() {
            matchButton.setImage(image0, for: .normal)
        } else {
            matchButton.alpha = 0
            //Load message - there are no new matches in your area. Try again later
            print("Alert the user that there are no more matches in the area. Try again later")
        }
        
        // Load middle image
        if let image1 = nextMatchCandidateImage() {
            matchButton1.setImage(image1, for: .normal)
        } else {
            matchButton1.alpha = 0
        }
        
        // Load back image
        if let image2 = nextMatchCandidateImage() {
            matchButton2.setImage(image2, for: .normal)
        } else {
            matchButton2.alpha = 0
        }
        
    }
    
    // Method for loading a match candidates images from remote server
    func nextMatchCandidateImage() -> UIImage? {

        if candidateCount > loadImageCounter {
            loadImageCounter += 1
            print("Loading image for candidate \(loadImageCounter)")
            if let photo = matchCandidates[loadImageCounter - 1]["profilePicture1"] as? PFFile {
                guard let imageData = try? photo.getData() else {fatalError("Could not download image data")}
                guard let image = UIImage(data: imageData) else {fatalError("Could not format image data")}
                print("Image for candidate \(loadImageCounter) loaded successfully")
                return image
            } else {
                print("Candidate \(loadImageCounter) does not have a profile picture.")
                return UIImage(named: "profile")
            }
            
        } else {
            print("No more candidates available to load at this time")
            return nil
        }
        
    }
    
    
    // MARK: - Nav Bar Methods
    //left navbar button to account center
    @IBAction func accountButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "accountSegue", sender: nil)
    }
    
    //right navbar button to match center
    @IBAction func messageButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "matchSegue", sender: nil)
    }
    
    func setupNavBar() {
        //add title icon - tinder flame logo
        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "flame"))
        let titleImageDimensions: CGFloat = 30
        titleImageView.frame = CGRect(x: 0, y: 0, width: titleImageDimensions, height: titleImageDimensions)
        titleImageView.heightAnchor.constraint(equalToConstant: titleImageDimensions).isActive = true
        titleImageView.widthAnchor.constraint(equalToConstant: titleImageDimensions).isActive = true
        titleImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImageView
        
        //add left nav bar button - account page
//        let accountButton = UIButton(type: .system)
//        let leftButtonDimensions: CGFloat = 35
//        accountButton.setImage(#imageLiteral(resourceName: "profile"), for: .normal)
//        accountButton.frame = CGRect(x: 0, y: 0, width: leftButtonDimensions, height: leftButtonDimensions)
//        accountButton.widthAnchor.constraint(equalToConstant: leftButtonDimensions).isActive = true
//        accountButton.heightAnchor.constraint(equalToConstant: leftButtonDimensions).isActive = true
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: accountButton)
        
        //add right nav bar button - meesage page
//        let messageButton = UIButton(type: .system)
//        let rightButtonDimensions: CGFloat = 25
//        messageButton.setImage(#imageLiteral(resourceName: "message"), for: .normal)
//        messageButton.frame = CGRect(x: 0, y: 0, width: rightButtonDimensions, height: rightButtonDimensions)
//        messageButton.widthAnchor.constraint(equalToConstant: rightButtonDimensions).isActive = true
//        messageButton.heightAnchor.constraint(equalToConstant: rightButtonDimensions).isActive = true
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: messageButton)
        
        //set background color to white
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
}

