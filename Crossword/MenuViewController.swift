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
    @IBOutlet var menuBackground: UIView!
    
    var musicEnabled: Bool!
    var soundEffectsEnabled: Bool!
    var timerEnabled: Bool!
    var skipFilledEnabled: Bool!
    var lockCorrectEnabled: Bool!
    var correctAnimationEnabled: Bool!
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var homeButton: UIButton!
    
    @IBOutlet var musicSwitch: UISwitch!
    @IBOutlet var soundEffectsSwitch: UISwitch!
    @IBOutlet var timerSwitch: UISwitch!
    @IBOutlet var skipFilledSwitch: UISwitch!
    @IBOutlet var lockCorrectSwitch: UISwitch!
    @IBOutlet var correctAnimationSwitch: UISwitch!
    
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuBackground.layer.cornerRadius = 15
        menuBackground.layer.borderWidth = 3
        menuBackground.layer.borderColor = UIColor.init(red: 96/255, green: 199/255, blue: 255/255, alpha: 1).cgColor
        
        backButton.layer.borderWidth = 1
        backButton.layer.cornerRadius = 3
        backButton.layer.borderColor = UIColor.init(red: 96/255, green: 199/255, blue: 255/255, alpha: 1).cgColor
        
        homeButton.layer.borderWidth = 1
        homeButton.layer.cornerRadius = 3
        homeButton.layer.borderColor = UIColor.init(red: 96/255, green: 199/255, blue: 255/255, alpha: 1).cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSwitches()
    }

    // Returns selected information back to parent view
    @IBAction func backButtonTapped(_ sender: Any) {
        if let parentGame = presentingViewController as? GameViewController {
            parentGame.musicEnabled = musicEnabled
            parentGame.soundEffectsEnabled = soundEffectsEnabled
            parentGame.timerEnabled = timerEnabled
            parentGame.skipFilledSquares = skipFilledEnabled
            parentGame.lockCorrectAnswers = lockCorrectEnabled
            parentGame.correctAnimationEnabled = correctAnimationEnabled
            parentGame.audioPlayer = audioPlayer
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Save switches into home view controller
        if segue.identifier == "homeSegue" {
            if let homeVC = segue.destination as? HomeViewController {
                homeVC.musicEnabled = musicEnabled
                homeVC.soundEffectsEnabled = soundEffectsEnabled
                homeVC.timerEnabled = timerEnabled
                homeVC.skipFilledEnabled = skipFilledEnabled
                homeVC.lockCorrectEnabled = lockCorrectEnabled
                homeVC.correctAnimationEnabled = correctAnimationEnabled
                
                audioPlayer.setVolume(0, fadeDuration: 1.0)
            }
        }
    }
    
    // Sets initial state of switches on loading
    func setSwitches() {
        musicSwitch.setOn(musicEnabled, animated: false)
        soundEffectsSwitch.setOn(soundEffectsEnabled, animated: false)
        timerSwitch.setOn(timerEnabled, animated: false)
        skipFilledSwitch.setOn(skipFilledEnabled, animated: false)
        lockCorrectSwitch.setOn(lockCorrectEnabled, animated: false)
        correctAnimationSwitch.setOn(correctAnimationEnabled, animated: false)
    }
    
    // Switch toggling
    @IBAction func musicSwitchToggled(_ sender: Any) {
        if musicSwitch.isOn == true {
            musicEnabled = true
            audioPlayer.setVolume(0.5, fadeDuration: 1.0)
        } else {
            musicEnabled = false
            audioPlayer.setVolume(0, fadeDuration: 1.0)
        }
    }
    @IBAction func soundEffectsToggled(_ sender: Any) {
        if soundEffectsSwitch.isOn == true {
            soundEffectsEnabled = true
        } else {
            soundEffectsEnabled = false
        }
    }
    @IBAction func timerToggled(_ sender: Any) {
        if timerSwitch.isOn == true {
            timerEnabled = true
            if let parentVC = presentingViewController as? GameViewController {
                parentVC.timerStack.isHidden = false
                
            }
        } else {
            timerEnabled = false
            if let parentVC = presentingViewController as? GameViewController {
                parentVC.timerStack.isHidden = true
            }
        }
    }
    @IBAction func skipFilledToggled(_ sender: Any) {
        if skipFilledSwitch.isOn == true {
            skipFilledEnabled = true
        } else {
            skipFilledEnabled = false
        }
    }
    @IBAction func lockCorrectToggled(_ sender: Any) {
        if lockCorrectSwitch.isOn == true {
            lockCorrectEnabled = true
        } else {
            lockCorrectEnabled = false
        }
    }
    @IBAction func correctAnimationToggled(_ sender: Any) {
        if correctAnimationSwitch.isOn == true {
            correctAnimationEnabled = true
        } else {
            correctAnimationEnabled = false
        }
    }
    
    // Gesture recognizers
    @IBAction func backgroundTapped(_ sender: Any) {
        backButton.sendActions(for: .touchUpInside)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if menuBackground.frame.contains(touch.location(in: view)) {
            return false
        }
        return true
    }
}
