//
//  LevelsViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 12/5/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit
import Firebase

class LevelsViewController: UIViewController {
    override var prefersStatusBarHidden: Bool {
        // No status bar allows for more board room
        return true
    }
    
    var selectedLevel: Int!
    
    @IBOutlet var levelButtons: [LevelButton]!
    @IBOutlet var backLevels: UIButton!
    @IBOutlet var nextLevels: UIButton!
        
    @IBOutlet var backHomeWidth: NSLayoutConstraint!
    @IBOutlet var firstStack: UIStackView!
    @IBOutlet var firstStackCenterX: NSLayoutConstraint!
    @IBOutlet var firstStackWidth: NSLayoutConstraint!

    // Banner ad
    @IBOutlet var bannerAd: GADBannerView!
    @IBOutlet var bannerHeightConstraint: NSLayoutConstraint!
    
    // Allows storing and reading from the disk
    let defaults = UserDefaults.standard
    
    // Falling objects
    var labels = [UILabel]()
    var emojisToChoose = [String]()
    var animators = [UIDynamicAnimator]()
    var timer: Timer!
    
    var pageNum: Int!
    var maxNumOfPages = 1
    
    @IBAction func levelButtonTapped(_ sender: UIButton) {
        selectedLevel = sender.tag
        for level in Settings.lockedLevels {
            if selectedLevel == level {
                performSegue(withIdentifier: "lockedSegue", sender: self)
                return
            }
        }
        
        // Go to the selected level
        Settings.userLevel = sender.tag
        performSegue(withIdentifier: "gameSegue", sender: self)
        
        // Fade out the home music
        MusicPlayer.homeMusicPlayer.setVolume(0, fadeDuration: 1.0)
    }
    
    @IBAction func nextLevelsTapped(_ sender: Any) {
        // Move the stacks left
        firstStackCenterX.constant += -view.frame.width
        
        // pageNum determines what arrows should be shown
        pageNum! += 1
        backLevels.isHidden = false
        if pageNum == maxNumOfPages {
            nextLevels.isHidden = true
        }
        
        // Animate the switch between level pages
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func previousLevelsTapped(_ sender: Any) {
        // Move the stacks right
        firstStackCenterX.constant += view.frame.width
        
        // pageNum determines what arrows should be shown
        pageNum! -= 1
        nextLevels.isHidden = false
        if pageNum == 1 {
            backLevels.isHidden = true
        }
        
        // Animate the switch between level pages
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func backHomeTapped(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set how big the level should display depending on the user device
        switch UIScreen.main.bounds.height {
        case 568:
            firstStackWidth.constant = 220
            backHomeWidth.constant = 70
        case 667:
            firstStackWidth.constant = 260
            backHomeWidth.constant = 75
        case 736:
            firstStackWidth.constant = 280
            backHomeWidth.constant = 80
        case 812:
            firstStackWidth.constant = 260
            backHomeWidth.constant = 80
        default:
            firstStackWidth.constant = 350
            backHomeWidth.constant = 100
        }
        
        // Page num is which level stack is displayed
        pageNum = 1
        backLevels.isHidden = true
        nextLevels.isHidden = true
        
        for i in 1..<Settings.maxNumOfLevels {
            if i % 12 == 0 {
                createNewLevelsStack(tagStart: i, numOfPages: CGFloat(maxNumOfPages))
                maxNumOfPages += 1
            }
        }
        
        if maxNumOfPages > 1 {
            nextLevels.isHidden = false
        }
        
        setUpLevelStatusArrays()
        
        // Set the images for each level button
        for i in 0...Settings.maxNumOfLevels - 1 {
            levelButtons[i].setBackgroundImage(UIImage(named: "num_\(i+1)"), for: .normal)
            levelButtons[i].layer.backgroundColor = UIColor.clear.cgColor
            levelButtons[i].setTitle(nil, for: .normal)
            levelButtons[i].alpha = 1.0
            levelButtons[i].isEnabled = true
        }
        
        for level in Settings.newLevels {
            levelButtons[level - 1].setNewIndicator("level")
        }

        // Possible emojis that will randomly fall from the top (160 to choose from)
        emojisToChoose = ["😄", "😇", "😂", "🤣", "🙂", "🙃", "😍", "😘", "😋", "😜",
                          "🤪", "🤩", "😎", "🤓", "😏", "😭", "😤", "😢", "😡", "🤬",
                          "🤯", "😱", "😓", "😰", "🤫", "🙄", "😬", "😴", "🤤", "🤮",
                          "🤕", "🤠", "😈", "💩", "👻", "👽", "💀", "👾", "😸", "😹",
                          "🎃", "🤖", "🙀", "🙌🏻", "✌🏻", "💪🏻", "👄", "💍", "👀", "🧔🏻",
                          "🎅🏻", "🧟‍♂️", "🧜🏻‍♀️", "🧞‍♂️", "🧚🏻‍♀️", "🙅🏼‍♀️", "🤷🏻‍♂️", "🧖🏼‍♀️", "👑", "🕶",
                          "🐶", "🐼", "🐸", "🐷", "🙈", "🙉", "🙊", "🦆", "🐥", "🐝",
                          "🦄", "🦋", "🐢", "🦖", "🦕", "🦑", "🐙", "🐠", "🐬", "🐳",
                          "🐊", "🦈", "🦓", "🦏", "🐘", "🦒", "🐄", "🐓", "🐉", "🎄",
                          "🍃", "🍀", "🌹", "🌸", "🌝", "🌙", "🌎", "☄️", "⚡️", "🌟",
                          "🌈", "🔥", "⛈", "☃️", "💧", "💦", "☔️", "🍎", "🍊", "🍌",
                          "🍉", "🍓", "🍒", "🍍", "🍆", "🌽", "🍔", "🥓", "🍕", "🍟",
                          "🌮", "🍬", "🍭", "🎂", "🍩", "⚽️", "🏀", "🏈", "⚾️", "🥇",
                          "🎨", "🎤", "🎷", "🎳", "🚗", "✈️", "🚀", "🗽", "🏝", "📱",
                          "📸", "☎️", "💡", "💵", "💎", "💣", "🔮", "🔑", "✉️", "❤️",
                          "💔", "💘", "⚠️", "🌀", "🃏", "🤞🏻", "👏🏼", "👌🏻", "👉🏼", "👍🏻"]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // When timer fires, will create a new label to be dropped from the view
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
        // Display ads if the user hasn't paid to turn them off
        if !Settings.adsDisabled {
            // Banner ad
            bannerAd.isHidden = false
            bannerHeightConstraint.constant = 50
            
            let request = GADRequest()
            request.testDevices = [kGADSimulatorID, "fed0f7a57321fadf217b2e53c6dac938", "845b935a0aad6fa7bbc613bea329c30a"]
            bannerAd.adSize = kGADAdSizeSmartBannerPortrait
            bannerAd.adUnitID = "ca-app-pub-1164601417724423/6884757223"
            bannerAd.rootViewController = self
            bannerAd.load(request)
        } else {
            // If the user has turned off ads through IAP, hide the banner
            // The banner height at 0 allows for the information button
            // to be in its proper location
            bannerAd.isHidden = true
            bannerHeightConstraint.constant = 0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove the labels
        for lab in labels {
            lab.text = nil
            lab.removeFromSuperview()
        }
        
        // Stop falling animation
        timer.invalidate()
        for anim in animators {
            anim.removeAllBehaviors()
        }
        
        // Stop the falling animation
        timer.invalidate()
        
        // Gives a nice animation to the next view
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        self.navigationController?.view.layer.add(transition, forKey: nil)
    }
    
    @objc func update() {
        // Create the emoji and add it to a label
        let emoji = emojisToChoose[Int(arc4random_uniform(160))]
        let label = UILabel()
        labels.append(label)
        
        let anim: UIDynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        animators.append(anim)
        
        // Choose a random location at the top of the screen for the emoji to fall
        var xLocation = CGFloat(arc4random_uniform(UInt32(UIScreen.main.bounds.width)))
        if xLocation + 50 > UIScreen.main.bounds.width {
            xLocation -= 40
        }
        label.frame = CGRect(x: xLocation, y: -50, width: 40, height: 50)
        label.text = emoji
        label.font = UIFont(name: "EmojiOne", size: 40)
        
        
        // Give labels a random rotation between -pi/4 and pi/4
        var rotation = Double(arc4random_uniform(77)) / 100
        let posNeg = arc4random_uniform(2)
        if posNeg == 0 {
            rotation = -rotation
        }
        label.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
        
        // Add the label to the behind the rest of the view
        view.addSubview(label)
        view.sendSubview(toBack: label)
        
        // Remove any labels that are out of screen range
        for lab in labels {
            if lab.center.y - 40 > UIScreen.main.bounds.height {
                lab.text = nil
                lab.removeFromSuperview()
            }
        }
        
        // Begin animation for the label
        animate(label: label, anim: anim)
        
        // Remove any labels that are out of screen range
        removeEmojis()
    }
    
    func animate(label: UILabel, anim: UIDynamicAnimator) {
        // Set the push animation
        // Choose a random magnitude between .15 and .35 to vary speeds
        let push = UIPushBehavior(items: [label], mode: .instantaneous)
        push.setAngle(.pi/2.0, magnitude: CGFloat(Double(arc4random_uniform(16)) + 25) / 100)
        
        // Begin animation
        anim.addBehavior(push)
    }
    
    func removeEmojis() {
        // Set the label text to nil and remove from super view
        for lab in labels {
            if lab.center.y - 40 > UIScreen.main.bounds.height {
                lab.text = nil
                lab.removeFromSuperview()
            }
        }
        
        // Remove animation from labels that have left the view
        let bounds = CGRect(x: 0.0,y: 0.0,width: view.bounds.width,height: view.bounds.height + 2000)
        for i in 0..<animators.count {
            if !animators[i].items(in: bounds).isEmpty && animators[i].items(in: bounds)[0].center.y - 40 > view.bounds.height {
                animators[i].removeAllBehaviors()
            }
        }
        
        // Keep our arrays a manageable size and remove emojis/animations that have left the screen
        // Therefore, our loops won't be giant if the user keeps app at the homescreen
        if animators.count > 100 {
            animators.removeSubrange(0...25)
            labels.removeSubrange(0...25)
        }
    }
    
    func createNewLevelsStack(tagStart: Int, numOfPages: CGFloat) {
        // Stack that will hold 4 button stacks
        let levelStack = UIStackView()
        levelStack.axis = .vertical
        levelStack.alignment = .fill
        levelStack.distribution = .fillEqually
        levelStack.spacing = 15.0
        
        var tag = tagStart + 1
        for _ in 0...3 {
            // Button stacks hold 3 buttons each
            let buttonStack = UIStackView()
            buttonStack.axis = .horizontal
            buttonStack.alignment = .fill
            buttonStack.distribution = .fillEqually
            buttonStack.spacing = 15.0
            
            // Each button should be hidden initially
            for _ in 0...2 {
                // Button creation and setup
                let levelButton = LevelButton()
                levelButton.backgroundColor = .clear
                levelButton.setTitle(nil, for: .normal)
                levelButton.alpha = 0
                levelButton.isEnabled = false
                levelButton.addTarget(self, action: #selector(levelButtonTapped), for: .touchUpInside)

                // Tags are used to determine what level to show
                // when a button is pressed.
                levelButton.tag = tag

                
                levelButtons.append(levelButton)
                tag += 1
                buttonStack.addArrangedSubview(levelButton)
            }

            levelStack.addArrangedSubview(buttonStack)
        }
        
        // Set constraints for the stack and add it to the view
        view.addSubview(levelStack)
        levelStack.translatesAutoresizingMaskIntoConstraints = false
        levelStack.leadingAnchor.constraint(equalTo: firstStack.leadingAnchor, constant: (view.frame.width * numOfPages)).isActive = true
        levelStack.topAnchor.constraint(equalTo: firstStack.topAnchor, constant: 0).isActive = true

        levelStack.widthAnchor.constraint(equalToConstant: firstStackWidth.constant).isActive = true
        levelStack.heightAnchor.constraint(equalTo: levelStack.widthAnchor, multiplier: 19.0/14.0).isActive = true
    }
    
    func setUpLevelStatusArrays() {
        // Set up completed levels
        // If there are none saved, start empty
        if let completeLevels = defaults.array(forKey: "completedLevels") {
            Settings.completedLevels = completeLevels as! [Int]
        } else {
            Settings.completedLevels = []
        }
        
        // Set up uncompleted levels
        // If there are none saved, start with 1-5
        if let uncompleteLevels = defaults.array(forKey: "uncompletedLevels") {
            Settings.uncompletedLevels = uncompleteLevels as! [Int]
        } else {
            // The initial levels
            Settings.uncompletedLevels = [1,2,3,4,5]
        }
        
        // Set up locked levels
        // If there are none saved, start empty and add new levels
        if let lockedLevels = defaults.array(forKey: "lockedLevels") {
            Settings.lockedLevels = lockedLevels as! [Int]
            
            for i in 1...Settings.maxNumOfLevels {
                if Settings.completedLevels.contains(i) || Settings.uncompletedLevels.contains(i) {
                    continue
                } else if !Settings.lockedLevels.contains(i){
                    Settings.lockedLevels.append(i)
                }
            }            
        } else {
            for i in 6...Settings.maxNumOfLevels {
                Settings.lockedLevels.append(i)
            }
        }
        
        // Fill the uncompleted levels from the locked levels if there are less than 5
        // uncompleted levels and the locked levels aren't empty
        let levelsAvailable = 5
        while Settings.uncompletedLevels.count < levelsAvailable && !Settings.lockedLevels.isEmpty {
            let num = Settings.lockedLevels[0]
            Settings.uncompletedLevels.append(num)
            Settings.lockedLevels.remove(at: 0)
        }
        
        // Set a lock image on locked levels
        for i in 0..<Settings.lockedLevels.count {
            levelButtons[Settings.lockedLevels[i] - 1].setLevelStatus("locked", "level")
        }
        
        // Set a check image on completed levels
        for i in 0..<Settings.completedLevels.count {
            levelButtons[Settings.completedLevels[i] - 1].setLevelStatus("complete", "level")
        }
        
        // Save the state of the level arrays
        defaults.set(Settings.completedLevels, forKey: "completedLevels")
        defaults.set(Settings.uncompletedLevels, forKey: "uncompletedLevels")
        defaults.set(Settings.lockedLevels, forKey: "lockedLevels")
    }
}
