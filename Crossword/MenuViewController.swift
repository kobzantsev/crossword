//
//  MenuViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 10/25/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit
import AVFoundation

class MenuViewController: UIViewController, UIGestureRecognizerDelegate {
    // Allows saving the user preferences on the device
    let defaults = UserDefaults.standard

    // Frame to display the settings
    @IBOutlet var menuBackground: UIView!
    
    // Navigation buttons. Back goes to the game, home goes to homescreen
    // buy hints goes to IAP view, help button shows help display
    @IBOutlet var backButton: UIButton!
    @IBOutlet var homeButton: UIButton!
    @IBOutlet var buyHintsButton: UIButton!
    @IBOutlet var helpButton: UIButton!
    
    // Switches to adjust preferences
    @IBOutlet var musicSwitch: UISwitch!
    @IBOutlet var soundEffectsSwitch: UISwitch!
    @IBOutlet var timerSwitch: UISwitch!
    @IBOutlet var skipFilledSwitch: UISwitch!
    @IBOutlet var lockCorrectSwitch: UISwitch!
    @IBOutlet var correctAnimationSwitch: UISwitch!
    @IBOutlet var autoscrollSwitch: UISwitch!
    
    // Should always end up being 1 but this is safer
    var indexOfPresenter: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Should be 1 (the top view on the navigation stack)
        indexOfPresenter = (self.presentingViewController?.childViewControllers.count)! - 1
        
        // Set up UI for user to interact with
        setUpMenuUI()
        
        // Switches are set to positions based on the settings
        setSwitches()
    }
    
    @IBAction func homeButtonTapped(_ sender: Any) {
        // Invalidate the game timer
        if let parentVC = self.presentingViewController?.childViewControllers[indexOfPresenter] as? GameViewController {
            parentVC.gameTimer.invalidate()
        }
        
        // Play the home music
        MusicPlayer.gameMusicPlayer.setVolume(0, fadeDuration: 1.0)
        if Settings.musicEnabled {
            MusicPlayer.homeMusicPlayer.setVolume(0.2, fadeDuration: 1.0)
        }
        
        // Uses an unwind segue to go back to the home screen
        performSegue(withIdentifier: "unwindSegue", sender: self)
    }
    
    @IBAction func buyHintsTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
        // Show the IAP menu
        if let parentVC = self.presentingViewController?.childViewControllers[indexOfPresenter] as? GameViewController {
            parentVC.showIAPView()
        }
    }
    
    // Close the view and return back to the game
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func helpButtonTapped(_ sender: Any) {
        // Begin showing help displays
        if let parentVC = self.presentingViewController?.childViewControllers[indexOfPresenter] as? GameViewController {
            parentVC.helpSetupAndDisplay()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // Sets initial state of switches on display
    // Switches are set based on the Settings class variables
    func setSwitches() {
        musicSwitch.setOn(Settings.musicEnabled, animated: false)
        soundEffectsSwitch.setOn(Settings.soundEffects, animated: false)
        timerSwitch.setOn(Settings.showTimer, animated: false)
        skipFilledSwitch.setOn(Settings.skipFilledSquares, animated: false)
        lockCorrectSwitch.setOn(Settings.lockCorrect, animated: false)
        correctAnimationSwitch.setOn(Settings.correctAnim, animated: false)
        autoscrollSwitch.setOn(Settings.autoscroll, animated: false)
    }
    
    // Switch toggling
    @IBAction func musicSwitchToggled(_ sender: Any) {
        // Flipping the switch should immediately start or stop the music
        if musicSwitch.isOn == true {
            Settings.musicEnabled = true
            MusicPlayer.gameMusicPlayer.setVolume(0.2, fadeDuration: 0.3)
        } else {
            Settings.musicEnabled = false
            MusicPlayer.gameMusicPlayer.setVolume(0, fadeDuration: 0.3)
        }
        
        // Save the state of the setting
        // Saving it when switch is toggled allows keeping the setting information
        // even if the app were to crash or the user closes it without exiting the
        // view.
        defaults.set(Settings.musicEnabled, forKey: "musicEnabled")
    }
    
    @IBAction func soundEffectsToggled(_ sender: Any) {
        if soundEffectsSwitch.isOn == true {
            Settings.soundEffects = true
        } else {
            Settings.soundEffects = false
        }
        
        // Save the state of the setting
        defaults.set(Settings.soundEffects, forKey: "soundEffects")
    }
    
    @IBAction func timerToggled(_ sender: Any) {
        if timerSwitch.isOn == true {
            Settings.showTimer = true
            
            // Immediately show the timer
            // The way that the navigation stack is handled, the game view controller will always be at
            // index 1.
            if let parentVC = self.presentingViewController?.childViewControllers[indexOfPresenter] as? GameViewController {
                parentVC.timerStack.isHidden = false
            }
        } else {
            Settings.showTimer = false
            
            // Immediately hide the timer
            // The way that the navigation stack is handled, the game view controller will always be at
            // index 1.
            if let parentVC = self.presentingViewController?.childViewControllers[indexOfPresenter] as? GameViewController {
                parentVC.timerStack.isHidden = true
            }
        }
        
        // Save the state of the setting
        defaults.set(Settings.showTimer, forKey: "showTimer")
    }
    
    @IBAction func skipFilledToggled(_ sender: Any) {
        if skipFilledSwitch.isOn == true {
            Settings.skipFilledSquares = true
        } else {
            Settings.skipFilledSquares = false
        }
        
        // Save the state of the setting
        defaults.set(Settings.skipFilledSquares, forKey: "skipFilledSquares")
    }
    
    @IBAction func lockCorrectToggled(_ sender: Any) {
        if lockCorrectSwitch.isOn == true {
            Settings.lockCorrect = true
        } else {
            Settings.lockCorrect = false
        }
        
        // Save the state of the setting
        defaults.set(Settings.lockCorrect, forKey: "lockCorrect")
    }
    
    @IBAction func correctAnimationToggled(_ sender: Any) {
        if correctAnimationSwitch.isOn == true {
            Settings.correctAnim = true
        } else {
            Settings.correctAnim = false
        }
        
        // Save the state of the setting
        defaults.set(Settings.correctAnim, forKey: "correctAnim")
    }
    
    @IBAction func autoscrollSwitchToggled(_ sender: Any) {
        if autoscrollSwitch.isOn == true {
            Settings.autoscroll = true
        } else {
            Settings.autoscroll = false
        }
        
        // Save the state of the setting
        defaults.set(Settings.autoscroll, forKey: "autoscroll")
    }
    
    // Gesture recognizer control
    @IBAction func backgroundTapped(_ sender: Any) {
        backButton.sendActions(for: .touchUpInside)
    }
    
    // Gives bounds the user can tap to close the menu. These bounds are only outside of the menu
    // background. Any taps inside the bounds won't close the menu.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if menuBackground.frame.contains(touch.location(in: view)) {
            return false
        }
        return true
    }
    
    // Make our UI elements look good
    func setUpMenuUI() {
        menuBackground.layer.cornerRadius = 15
        menuBackground.layer.borderWidth = 3
        menuBackground.layer.borderColor = UIColor.init(red: 96/255, green: 199/255, blue: 255/255, alpha: 1).cgColor
        
        backButton.layer.borderWidth = 1
        backButton.layer.cornerRadius = 3
        backButton.layer.borderColor = UIColor.init(red: 96/255, green: 199/255, blue: 255/255, alpha: 1).cgColor
        
        homeButton.layer.borderWidth = 1
        homeButton.layer.cornerRadius = 3
        homeButton.layer.borderColor = UIColor.init(red: 96/255, green: 199/255, blue: 255/255, alpha: 1).cgColor
        
        buyHintsButton.layer.borderWidth = 1
        buyHintsButton.layer.cornerRadius = 3
        buyHintsButton.layer.borderColor = UIColor.init(red: 96/255, green: 199/255, blue: 255/255, alpha: 1).cgColor
        
        helpButton.layer.borderWidth = 1
        helpButton.layer.cornerRadius = 3
        helpButton.layer.borderColor = UIColor.init(red: 96/255, green: 199/255, blue: 255/255, alpha: 1).cgColor
    }
}
