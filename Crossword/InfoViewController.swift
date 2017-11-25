//
//  InfoViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 11/18/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet var infoBackground: UIView!
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var mailButton: UIButton!
    @IBOutlet var twitterButton: UIButton!
    
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        twitterButton.isHidden = true
        mailButton.isHidden = true
        
        versionLabel.text = "Version \(version)"
        // Gives the background border a nice color/shape
        infoBackground.layer.cornerRadius = 15
        infoBackground.layer.borderWidth = 3
        infoBackground.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func restorePurchasesTapped(_ sender: Any) {
        // Pass view controller to allow UIAlert inidicating success of restore
        InAppPurchase.shared.restorePurchases(in: self)
    }
    
    // Gesture recognizer control
    @IBAction func backgroundTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if infoBackground.frame.contains(touch.location(in: view)) {
            return false
        }
        return true
    }
}
