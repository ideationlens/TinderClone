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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create gesture
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveLabelBasedOn(gestureRecognizer:)))
        
        //Assign gesture to UILabel
        swipeLabel.addGestureRecognizer(gestureRecognizer)
    
    }

    //Animate Label in Resopnse to Gesture
    @objc func moveLabelBasedOn(gestureRecognizer: UIPanGestureRecognizer) {
        
        let changeInPosition = gestureRecognizer.translation(in: view)
        
        //Move label in response to gesture
        swipeLabel.center = CGPoint(x: view.bounds.width / 2 + changeInPosition.x, y: view.bounds.height / 2 + changeInPosition.y)
        print("x: \(swipeLabel.center.x), y: \(swipeLabel.center.y)")
        //Check if label is in the no zone
        if (swipeLabel.center.x < 70) {
            let newAlphaValue = max(0.3,swipeLabel.center.x / 100 + 0.3)
            let rotationDirection: CGFloat = -1.0
            transformSwipeLabel(newAlphaValue: newAlphaValue, rotationMultiple: rotationDirection)
        } else if (swipeLabel.center.x > view.bounds.width - 70) {
            let newAlphaValue = max(0.3,(view.bounds.width - swipeLabel.center.x) / 100.0 + 0.3)
            let rotationDirection: CGFloat = 1.0
            transformSwipeLabel(newAlphaValue: newAlphaValue, rotationMultiple: rotationDirection)
        }
        
        
        
        
        
        //Check if gesture ended
        if (gestureRecognizer.state == UIGestureRecognizerState.ended) {
            
            if (swipeLabel.center.x < 70) {
                
                UIView.animate(withDuration: 0.4, animations: {
                    self.transformSwipeLabel(newAlphaValue: 0, rotationMultiple: -2)
                    self.swipeLabel.center = CGPoint(x: -100,
                                                     y: self.view.bounds.height / 2 - 100)
                }) { (success) in
                    self.transformSwipeLabel(newAlphaValue: 1, rotationMultiple: 0)
                    self.swipeLabel.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
                }
                
            } else if (swipeLabel.center.x > view.bounds.width - 70) {
                UIView.animate(withDuration: 0.4, animations: {
                    self.transformSwipeLabel(newAlphaValue: 0, rotationMultiple: 2)
                    self.swipeLabel.center = CGPoint(x: self.view.bounds.width + 100,
                                                     y: self.view.bounds.height / 2 - 100)
                }) { (success) in
                    self.transformSwipeLabel(newAlphaValue: 1, rotationMultiple: 0)
                    self.swipeLabel.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
                }
            } else {
                //Move label back to original position (function invoked when gesture stops)
                UIView.animate(withDuration: 0.3) {
                    self.transformSwipeLabel(newAlphaValue: 1.0, rotationMultiple: 0)
                    self.swipeLabel.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
                }
                
            }
            
//            if (swipeLabel.center.x != view.bounds.width/2) {
//                swipeLabel.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
//                transformSwipeLabel(newAlphaValue: 1, rotationMultiple: 0)
//            }
            
        }
    }

    
    func transformSwipeLabel(newAlphaValue: CGFloat, rotationMultiple: CGFloat) {
        swipeLabel.alpha = newAlphaValue
        let angle =  CGFloat(1 - newAlphaValue) * CGFloat(Float.pi/16) * rotationMultiple
        let rotation = CGAffineTransform.init(rotationAngle: angle)
        let scale = CGFloat(0.8 + 0.2 * newAlphaValue)
        let rotationAndScale = rotation.scaledBy(x: scale, y: scale)
        swipeLabel.transform = rotationAndScale
        
        
    }
}

