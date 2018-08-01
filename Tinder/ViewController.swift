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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Create matchButton gesture
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(movebuttonBasedOn(gestureRecognizer:)))
        
        //Assign gesture to matchButton
        matchButton.addGestureRecognizer(gestureRecognizer)
        
        //Determine points of reference for view
        //center of matchButton 1, 2 and 3
        centerPoint.append(CGPoint(x: matchView.bounds.width/2 + CGFloat(19)
                                  ,y: matchView.bounds.height/2 + CGFloat(navigationController!.navigationBar.frame.height / 1.75)))
        centerPoint.append(CGPoint(x: centerPoint[0].x - centerPointOffset
                                  ,y: centerPoint[0].y - centerPointOffset))
        centerPoint.append(CGPoint(x: centerPoint[0].x - centerPointOffset * CGFloat(2)
                                  ,y: centerPoint[0].y - centerPointOffset * CGFloat(2)))
        centerPoint.append(CGPoint(x: centerPoint[0].x - centerPointOffset * CGFloat(3)
                                  ,y: centerPoint[0].y - centerPointOffset * CGFloat(3)))
        
        //Setup Nav Bar Items
        setupNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {

        //Initialize swipe button positions
        matchButton.center = centerPoint[0]
        matchButton1.center = centerPoint[1]
        matchButton2.center = centerPoint[2]
        
        print("x: \(matchButton.center.x), y: \(matchButton.center.y)")
//        print("x: \(matchButton1.center.x), y: \(matchButton1.center.y)")
//        print("x: \(matchButton2.center.x), y: \(matchButton2.center.y)")
        
    }

    //Animate button in Resopnse to Gesture
    @objc func movebuttonBasedOn(gestureRecognizer: UIPanGestureRecognizer) {
        
        let changeInPosition = gestureRecognizer.translation(in: view)
        
        //Move button in response to gesture
        matchButton.center = CGPoint(x: centerPoint[0].x + changeInPosition.x, y: centerPoint[0].y + changeInPosition.y)
        
        //Check if button is within the interested/not-interested margin
        if (matchButton.center.x < interestMargin) {
            
            //transform button as it moves further to the left
            let newAlphaValue = max(0.3,matchButton.center.x / 100 + (1 - interestMargin/100))
            transformmatchButton(newAlphaValue: newAlphaValue, rotationMultiple: -1)
            
        } else if (matchButton.center.x > view.bounds.width - interestMargin) {
            
            //transform button as it moves further to the right
            let newAlphaValue = max(0.3,(centerPoint[0].x * 2 - matchButton.center.x) / 100.0 + (1 - interestMargin/100))
            transformmatchButton(newAlphaValue: newAlphaValue, rotationMultiple: 1)
            
        }

        //Check if gesture ended
        if (gestureRecognizer.state == UIGestureRecognizerState.ended) {
            
            //Check if button is within the interested/not-interested margin
            if (matchButton.center.x < interestMargin) {
                
                //transform button out of view to the left
                UIView.animate(withDuration: 0.3, animations: {
                    self.transformmatchButton(newAlphaValue: 0, rotationMultiple: -2)
                    self.matchButton.center = CGPoint(x: -100,
                                                     y: self.centerPoint[0].y - 100)
                }) { (success) in
                    self.loadNextImage()
                }
            
            } else if (matchButton.center.x > view.bounds.width - interestMargin) {
                
                //transform button out of view to the right
                UIView.animate(withDuration: 0.3, animations: {
                    self.transformmatchButton(newAlphaValue: 0, rotationMultiple: 2)
                    self.matchButton.center = CGPoint(x: self.centerPoint[0].x * 2 + 100,
                                                     y: self.centerPoint[0].y - 100)
                }) { (success) in
                    self.loadNextImage()
                }
                
            } else {
                
                //Move button back to original position (function invoked when gesture stops)
                UIView.animate(withDuration: 0.3) {
                    self.transformmatchButton(newAlphaValue: 1.0, rotationMultiple: 0)
                    self.matchButton.center = self.centerPoint[0]
                }
                print("back to center")
                print("x: \(matchButton.center.x), y: \(matchButton.center.y)")
            }
        }
    }

    
    func transformmatchButton(newAlphaValue: CGFloat, rotationMultiple: CGFloat) {
        matchButton.alpha = newAlphaValue
        let angle =  CGFloat(1 - newAlphaValue) * CGFloat(Float.pi/16) * rotationMultiple
        let rotation = CGAffineTransform.init(rotationAngle: angle)
        let scale = CGFloat(0.7 + 0.3 * newAlphaValue)
        let rotationAndScale = rotation.scaledBy(x: scale, y: scale)
        matchButton.transform = rotationAndScale
    }
    
    func loadNextImage() {

        //update top button's (matchButton0) image, position over matchButton1, then set alpha back to 1
        matchButton.backgroundColor = matchButton1.backgroundColor
        matchButton.center = centerPoint[1]
        transformmatchButton(newAlphaValue: 1, rotationMultiple: 0)
        
        //update middle button's (matchButton1) image then position over matchButton
        matchButton1.backgroundColor = matchButton2.backgroundColor
        matchButton1.center = centerPoint[2]
        
        //update back button's alpha value to 0, image to new image, then position to centerPoint[3]
        matchButton2.alpha = 0
        let randomRed = CGFloat(drand48())
        let randomGreen = CGFloat(drand48())
        let randomBlue = CGFloat(drand48())
        matchButton2.backgroundColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1)
        matchButton2.center = centerPoint[3]
        
        //Animate buttons sliding forward
        UIView.animate(withDuration: 0.4, animations: {
            self.matchButton.center = self.centerPoint[0]
            self.matchButton1.center = self.centerPoint[1]
            self.matchButton2.center = self.centerPoint[2]
            
            self.matchButton2.alpha = 1
        }, completion: nil)
        
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

