//
//  ViewController.swift
//  Tinder
//
//  Created by Douglas Putnam on 7/24/18.
//  Copyright © 2018 Douglas Putnam. All rights reserved.
//

import Parse
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var swipeLabel: UILabel!
    @IBOutlet weak var swipeLabel1: UILabel!
    @IBOutlet weak var swipeLabel2: UILabel!
    
    var centerPoint = [CGPoint]()
    let centerPointOffset: CGFloat = 10
    let interestMargin: CGFloat = 70
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Create swipeLabel gesture
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveLabelBasedOn(gestureRecognizer:)))
        
        //Assign gesture to swipeLabel
        swipeLabel.addGestureRecognizer(gestureRecognizer)
        
        //Determine points of reference for view
        //center of swipeLabel 1, 2 and 3
        centerPoint.append(CGPoint(x: view.bounds.width/2
                                  ,y: view.bounds.height/2))
        centerPoint.append(CGPoint(x: view.bounds.width/2 - centerPointOffset
                                  ,y: view.bounds.height/2 - centerPointOffset))
        centerPoint.append(CGPoint(x: view.bounds.width/2 - centerPointOffset * CGFloat(2)
                                  ,y: view.bounds.height/2 - centerPointOffset * CGFloat(2)))
        centerPoint.append(CGPoint(x: view.bounds.width/2 - centerPointOffset * CGFloat(3)
                                  ,y: view.bounds.height/2 - centerPointOffset * CGFloat(3)))
        
        //Setup Nav Bar Items
        setupNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {

        //Initialize swipe label positions
        swipeLabel.center = centerPoint[0]
        swipeLabel1.center = centerPoint[1]
        swipeLabel2.center = centerPoint[2]
        
//        print("x: \(swipeLabel.center.x), y: \(swipeLabel.center.y)")
//        print("x: \(swipeLabel1.center.x), y: \(swipeLabel1.center.y)")
//        print("x: \(swipeLabel2.center.x), y: \(swipeLabel2.center.y)")
        
    }

    //Animate Label in Resopnse to Gesture
    @objc func moveLabelBasedOn(gestureRecognizer: UIPanGestureRecognizer) {
        
        let changeInPosition = gestureRecognizer.translation(in: view)
        
        //Move label in response to gesture
        swipeLabel.center = CGPoint(x: view.bounds.width / 2 + changeInPosition.x, y: view.bounds.height / 2 + changeInPosition.y)
        
        //Check if label is within the interested/not-interested margin
        if (swipeLabel.center.x < interestMargin) {
            
            let newAlphaValue = max(0.3,swipeLabel.center.x / 100 + (1 - interestMargin/100))
            transformSwipeLabel(newAlphaValue: newAlphaValue, rotationMultiple: -1)
            
        } else if (swipeLabel.center.x > view.bounds.width - interestMargin) {
            
            let newAlphaValue = max(0.3,(view.bounds.width - swipeLabel.center.x) / 100.0 + (1 - interestMargin/100))
            transformSwipeLabel(newAlphaValue: newAlphaValue, rotationMultiple: 1)
            
        }

        //Check if gesture ended
        if (gestureRecognizer.state == UIGestureRecognizerState.ended) {
            
            if (swipeLabel.center.x < interestMargin) {
                
                UIView.animate(withDuration: 0.4, animations: {
                    self.transformSwipeLabel(newAlphaValue: 0, rotationMultiple: -2)
                    self.swipeLabel.center = CGPoint(x: -100,
                                                     y: self.view.bounds.height / 2 - 100)
                }) { (success) in
                    self.loadNextImage()
                }
            
            } else if (swipeLabel.center.x > view.bounds.width - interestMargin) {
                
                UIView.animate(withDuration: 0.4, animations: {
                    self.transformSwipeLabel(newAlphaValue: 0, rotationMultiple: 2)
                    self.swipeLabel.center = CGPoint(x: self.view.bounds.width + 100,
                                                     y: self.view.bounds.height / 2 - 100)
                }) { (success) in
                    self.loadNextImage()
                }
                
            } else {
                
                //Move label back to original position (function invoked when gesture stops)
                UIView.animate(withDuration: 0.3) {
                    self.transformSwipeLabel(newAlphaValue: 1.0, rotationMultiple: 0)
                    self.swipeLabel.center = self.centerPoint[0]
                }
                
            }
        }
    }

    
    func transformSwipeLabel(newAlphaValue: CGFloat, rotationMultiple: CGFloat) {
        swipeLabel.alpha = newAlphaValue
        let angle =  CGFloat(1 - newAlphaValue) * CGFloat(Float.pi/16) * rotationMultiple
        let rotation = CGAffineTransform.init(rotationAngle: angle)
        let scale = CGFloat(0.7 + 0.3 * newAlphaValue)
        let rotationAndScale = rotation.scaledBy(x: scale, y: scale)
        swipeLabel.transform = rotationAndScale
    }
    
    func loadNextImage() {

        //update top label's (swipeLabel0) image, position over swipeLabel1, then set alpha back to 1
        swipeLabel.backgroundColor = swipeLabel1.backgroundColor
        swipeLabel.center = centerPoint[1]
        transformSwipeLabel(newAlphaValue: 1, rotationMultiple: 0)
        
        //update middle label's (swipeLabel1) image then position over swipeLabel
        swipeLabel1.backgroundColor = swipeLabel2.backgroundColor
        swipeLabel1.center = centerPoint[2]
        
        //update back label's alpha value to 0, image to new image, then position to centerPoint[3]
        swipeLabel2.alpha = 0
        let randomRed = CGFloat(drand48())
        let randomGreen = CGFloat(drand48())
        let randomBlue = CGFloat(drand48())
        swipeLabel2.backgroundColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1)
        swipeLabel2.center = centerPoint[3]
        
        //Animate labels sliding forward
        UIView.animate(withDuration: 0.4, animations: {
            self.swipeLabel.center = self.centerPoint[0]
            self.swipeLabel1.center = self.centerPoint[1]
            self.swipeLabel2.center = self.centerPoint[2]
            
            self.swipeLabel2.alpha = 1
        }, completion: nil)
        
    }
    
    func setupNavBar() {
        //add title icon - tinder flame logo
        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "flame"))
        titleImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        titleImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImageView
        
        //add left nav bar button - account page
        let accountButton = UIButton(type: .system)
        accountButton.setImage(#imageLiteral(resourceName: "profile"), for: .normal)
        accountButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: accountButton)
        
        //add right nav bar button - meesage page
        let messageButton = UIButton(type: .system)
        messageButton.setImage(#imageLiteral(resourceName: "message"), for: .normal)
        messageButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: messageButton)
        
        //set background color to white
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
    }
    
}

