//
//  GameViewController.swift
//  Crossword
//
//  Created by Tyler Stickler on 10/20/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import Firebase
import FirebaseDatabase

class GameViewController: UIViewController, GADInterstitialDelegate, UIScrollViewDelegate {
    // Contraints that will be modified during runtime to fit device
    @IBOutlet var topMidKeySep: NSLayoutConstraint!
    @IBOutlet var bottomMidKeySep: NSLayoutConstraint!
    @IBOutlet var helpButtonsStack: UIStackView!
    @IBOutlet var nextPhraseWidth: NSLayoutConstraint!
    @IBOutlet var backPhraseWidth: NSLayoutConstraint!
    @IBOutlet var topBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet var middleRowLeading: NSLayoutConstraint!
    @IBOutlet var middleRowTrailing: NSLayoutConstraint!
    @IBOutlet var theBoard: UIStackView!
    @IBOutlet var theBoardHeight: NSLayoutConstraint!
    @IBOutlet var theBoardWidth: NSLayoutConstraint!
    @IBOutlet var theBoardTrailing: NSLayoutConstraint!
    @IBOutlet var theBoardLeading: NSLayoutConstraint!
    @IBOutlet var scroller: UIScrollView!
    @IBOutlet var boardTrailing: NSLayoutConstraint!
    @IBOutlet var boardLeading: NSLayoutConstraint!
    @IBOutlet var boardTop: NSLayoutConstraint!
    @IBOutlet var boardBottom: NSLayoutConstraint!
    @IBOutlet var hintEnabledHeight: NSLayoutConstraint!
    
    // Allows us to animate fall of boardspaces at the end of the level
    var animator: UIDynamicAnimator!

    // Containers for button properties
    var buttonLetterArray: [Character]!
    var buttonTitleArray: [String]!
    var buttonAcrossArray: [String]!
    var buttonDownArray: [String]!
    var buttonLockedForCorrect: [Bool]!
    var buttonHintAcrossEnabled: [Bool]!
    var buttonHintDownEnabled: [Bool]!
    var buttonRevealedByHelper: [Bool]!
    
    // Allows us to save board state for user to come back to
    let defaults = UserDefaults.standard
    
    // Used to determine which phone the user has
    let screenSize = UIScreen.main.bounds
    
    override var prefersStatusBarHidden: Bool {
        // No status bar allows for more board room
        
        if screenSize.height == 812 {
            // Only show status bar if the user has an iphone X
            return false
        }
        
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        // If the status bar is shown, we want white text
        return .lightContent
    }

    var selectedBoardSpaces = [Int]()
    var across = true
    var indexOfButton: Int!
    var acrossNumbers = [Int]()
    var downNumbers = [Int]()
    var acrossClues = [(Num: String, Clue: String, Hint: String, WordCt: String)]()
    var downClues = [(Num: String, Clue: String, Hint: String, WordCt: String)]()
    
    // UI colors
    let blueColor = UIColor.init(red: 96/255, green: 199/255, blue: 255/255, alpha: 1)
    let blueColorCG = UIColor.init(red: 96/255, green: 199/255, blue: 255/255, alpha: 1).cgColor
    let redColorCG = UIColor.init(red: 255/255, green: 150/255, blue: 176/255, alpha: 1).cgColor
    let orangeColorCG = UIColor.init(red: 255/255, green: 197/255, blue: 126/255, alpha: 1).cgColor
    let yellowColorCG = UIColor.init(red: 249/255, green: 255/255, blue: 140/255, alpha: 1).cgColor
    let greenColorCG = UIColor.init(red: 73/255, green: 222/255, blue: 124/255, alpha: 1).cgColor
    
    // Cheat Buttons
    @IBOutlet var hintButton: UIButton!
    @IBOutlet var fillSquareButton: UIButton!
    @IBOutlet weak var cheatCountLabel: UILabel!
    @IBOutlet var hintEnabledButton: UIButton!
    @IBOutlet var iapButton: UIButton!
    
    // Iterator to prevent inifinte loop
    var checkAllDirectionFilledIterator = 0

    // Buttons for the keyboard and gameboard
    @IBOutlet var keys: [UIButton]!
    @IBOutlet var boardSpaces = [BoardButton]()
    
    // Keyboard area constraints to manage size on different devices
    @IBOutlet var topKeysHeight: NSLayoutConstraint!
    @IBOutlet var middleKeysHeight: NSLayoutConstraint!
    @IBOutlet var bottomKeysHeight: NSLayoutConstraint!
    @IBOutlet var keyboardBackHeight: NSLayoutConstraint!
    @IBOutlet var bottomRowLeading: NSLayoutConstraint!
    @IBOutlet var bottomRowTrailing: NSLayoutConstraint!
    
    // Clue area and top bar labels and buttons
    @IBOutlet var clueLabel: UILabel!
    @IBOutlet weak var emojiClue: UILabel!
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var backPhraseButton: UIButton!
    @IBOutlet var nextPhraseButton: UIButton!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var emojiClueConstraint: NSLayoutConstraint!
    @IBOutlet var clueHeightConstraint: NSLayoutConstraint!
    @IBOutlet var completeIndicator: UIImageView!
    
    // To know where the user last was
    var previousButton = 0
    
    // Timer
    @IBOutlet weak var timerStack: UIStackView!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    
    var gameTimer: Timer!
    var secondsCounter = 0
    var minutesCounter = 0
    var hoursCounter = 0
    let formatter = NumberFormatter()
    
    // Wrong view should only be shown once
    var wrongViewShown = false
    
    // Ad
    var interstitialAd: GADInterstitial!
    var shouldShowAdCounter = 0
    var showAdAfterNumCorrect = 3
    var inGame = false
    
    // Help labels, dimmers, and buttons
    var helpNum: Int!
    @IBOutlet var topBarDimmer: UIView!
    @IBOutlet var boardDimmer: UIView!
    @IBOutlet var clueDimmer: UIView!
    @IBOutlet var keysDimmer: UIView!
    @IBOutlet var bottomDimmer: UIView!
    @IBOutlet var menuDimmer: UIView!
    @IBOutlet var ipxDimmer: UIView!
    
    @IBOutlet var hintHelpArrow: UIImageView!
    @IBOutlet var boardHelpArrow: UIImageView!
    @IBOutlet var clueHelpArrow: UIImageView!
    @IBOutlet var menuHelpArrow: UIImageView!
    
    @IBOutlet var hintHelpLabel: UILabel!
    @IBOutlet var boardHelpLabel: UILabel!
    @IBOutlet var clueHelpLabel: UILabel!
    @IBOutlet var menuHelpLabel: UILabel!
    
    @IBOutlet var helpFinishedButton: UIButton!
    @IBOutlet var nextHelpButton: UIButton!
    
    @IBOutlet var helpNumIndicator: UIImageView!
    
    var ref: DatabaseReference!
    var levelIndex: Int!
    var puzzleSize: Int!
    
    var levels = [Dictionary<String, Dictionary<String, String>>]()
    @IBOutlet var clueTableButton: UIButton!
    @IBOutlet var clueTable: UITableView!
    var scrollingDisabled = false
    var correctClues = [String]()
    @IBOutlet var gemChangeTopConstraint: NSLayoutConstraint!
    @IBOutlet var gemChangeStack: UIStackView!
    @IBOutlet var gemChangeText: UILabel!
    
    /*****************************************
    *                                        *
    *                 UI SETUP               *
    *                                        *
    *****************************************/
    
    func setUpBoard(board: [String]) {
        // Proportion to their containing view
        let TOP_BAR_PROPORTION: CGFloat = 0.05
        let CLUE_PROPORTION: CGFloat = 0.10
        let KEYBOARD_PROPORTION: CGFloat = 0.25
        let KEYS_PROPORTION: CGFloat = 0.275
        let KEY_SEPERATION_PROPORTION: CGFloat = 0.04
        let CLUE_OFFSET: CGFloat = 0.20
        let FONT_PROPORTION: CGFloat = 0.60
        let MIDDLE_KEYS_TO_EDGE: CGFloat = 0.10
        let NEXT_BACK_PHRASE_WIDTH: CGFloat = 0.40
        
        // Top bar should take 5% of screen
        // If the 5 % is less than 35 points, then the top bar should be 35
        topBarHeightConstraint.constant = (screenSize.height * TOP_BAR_PROPORTION)
        if topBarHeightConstraint.constant < 35 {
            topBarHeightConstraint.constant = 35
        }
        
        // Clue area takes up 10% of screen
        clueHeightConstraint.constant = (screenSize.height * CLUE_PROPORTION)
        
        // Key background area takes up 25% of screen
        keyboardBackHeight.constant = (screenSize.height * KEYBOARD_PROPORTION)
        
        // Each row of keys takes up 27.5% of the keyboard area
        topKeysHeight.constant = keyboardBackHeight.constant * KEYS_PROPORTION
        middleKeysHeight.constant = keyboardBackHeight.constant * KEYS_PROPORTION
        
        if screenSize.height == 812 {
            bottomKeysHeight.constant = keyboardBackHeight.constant * 0.25
        } else {
            bottomKeysHeight.constant = keyboardBackHeight.constant * KEYS_PROPORTION
        }
        // Seperation of the keys should be 4% of the key background area
        topMidKeySep.constant = keyboardBackHeight.constant * KEY_SEPERATION_PROPORTION
        bottomMidKeySep.constant = keyboardBackHeight.constant * KEY_SEPERATION_PROPORTION
        
        // Leading and trailing of the bottom row are 4% of the key background area
        bottomRowLeading.constant = keyboardBackHeight.constant * KEY_SEPERATION_PROPORTION
        bottomRowTrailing.constant = keyboardBackHeight.constant * KEY_SEPERATION_PROPORTION
        
        // Offset for clue is 20% of clue area height
        emojiClueConstraint.constant = clueHeightConstraint.constant * CLUE_OFFSET
        
        // Font size of the clue is 60% of the clue area height
        emojiClue.font = clueLabel.font.withSize(clueHeightConstraint.constant * FONT_PROPORTION)
        
        // Middle row should have 10% blank on each side
        middleRowLeading.constant = keyboardBackHeight.constant * MIDDLE_KEYS_TO_EDGE
        middleRowTrailing.constant = keyboardBackHeight.constant * MIDDLE_KEYS_TO_EDGE
        
        // Jump phrase buttons should be 40% as wide as clue height
        nextPhraseWidth.constant = clueHeightConstraint.constant * NEXT_BACK_PHRASE_WIDTH
        backPhraseWidth.constant = clueHeightConstraint.constant * NEXT_BACK_PHRASE_WIDTH
        
        clueTable.layer.cornerRadius = 5
        clueTable.layer.borderColor = UIColor.init(red: 85/255, green: 85/255, blue: 85/255, alpha: 1.0).cgColor
        clueTable.layer.borderWidth = 3
        
        // Gives buttons a nice rounded corner
        for button in keys {
            if button.tag != 0 {
                // Add button actions for the keys
                // Only the letter keys, not backspace or menu
                button.addTarget(self, action: #selector(GameViewController.buttonDown), for: .touchDown)
                button.addTarget(self, action: #selector(GameViewController.removeView), for: .touchDragExit)
            }
            
            button.layer.cornerRadius = keyboardBackHeight.constant * 0.05
            if UIDevice.current.model == "iPad" {
                button.titleLabel?.font = button.titleLabel?.font.withSize(33.0)
            }
        }
        
        // Create the board buttons to be used for the puzzle
        createBoardButtons()
        
        // Gives each space on the board specific properties depending on how the board is arranged
        giveBoardSpacesProperties(board: board)

        // Any space that should be inactive is hidden
        for i in 0...puzzleSize * puzzleSize - 1 {
            // Grabs the letter in the string
            let letter = buttonLetterArray[i]

            if letter == "-" {
                // Make the spaces inactive
                boardSpaces[i].isEnabled = false
                boardSpaces[i].alpha = 0
                continue
            }
        }
        
        if Settings.cheatCount < 5 {
            fillSquareButton.setImage(UIImage(named: "one_reveal_disabled.png"), for: .normal)
        }
        
        if Settings.cheatCount < 10 {
            hintButton.setImage(UIImage(named: "hint_disabled.png"), for: .normal)
        }
    }
    
    func createBoardButtons() {
        for i in 0...puzzleSize - 1 {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.alignment = .fill
            stack.distribution = .fillEqually
            stack.spacing = 3
            stack.backgroundColor = .green
            theBoard.addArrangedSubview(stack)

            for j in 0...puzzleSize - 1 {
                let button = BoardButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                
                button.titleLabel?.font = button.titleLabel?.font.withSize(18.0)
            
                // Button letters should be black
                button.setTitleColor(.black, for: .normal)
                
                // Give buttons a nice rounded corner
                button.layer.cornerRadius = 3
                if screenSize.height > 812 {
                    button.layer.cornerRadius = 4
                }
                
                // Set button tag so when tapped we know where it is
                button.tag = (i * puzzleSize) + j
                button.backgroundColor = .white
                button.addTarget(self, action: #selector(boardButtonTapped), for: .touchUpInside)
                
                boardSpaces.append(button)
                stack.addArrangedSubview(button)
            }
            
        }
    }
    
    func clueAreaSetup() {
        // Set border width, shape, and color for the clue label, advancement buttons, timer and clue buttons
        clueLabel.layer.masksToBounds = true
        clueLabel.layer.borderWidth = 5
        clueLabel.layer.cornerRadius = 10
        
        nextPhraseButton.layer.borderWidth = 1
        nextPhraseButton.layer.cornerRadius = 4
        nextPhraseButton.layer.borderColor = UIColor.white.cgColor
        nextPhraseButton.setTitleColor(blueColor, for: .normal)
        
        backPhraseButton.layer.borderWidth = 1
        backPhraseButton.layer.cornerRadius = 4
        backPhraseButton.layer.borderColor = UIColor.white.cgColor
        backPhraseButton.setTitleColor(blueColor, for: .normal)
        
        hintButton.layer.cornerRadius = 1
        iapButton.layer.cornerRadius = 4
        iapButton.layer.borderWidth = 1
        iapButton.layer.borderColor = UIColor.white.cgColor
        
        hintButton.titleLabel!.numberOfLines = 1
        hintButton.titleLabel?.minimumScaleFactor = 0.5
        hintButton.titleLabel!.adjustsFontSizeToFitWidth = true
        hintButton.titleLabel!.baselineAdjustment = .alignCenters
        cheatCountLabel.sizeToFit()
        fillSquareButton.layer.cornerRadius = 1
        
        hintEnabledButton.layer.cornerRadius = 14
        if UIDevice.current.model == "iPad" {
            hintEnabledHeight.constant = 42
            hintEnabledButton.layer.cornerRadius = 21
            directionLabel.font = directionLabel.font.withSize(24)
        }
        hintEnabledButton.layer.borderColor = UIColor.black.cgColor
        hintEnabledButton.layer.borderWidth = 0

        cheatCountLabel.text = String(Settings.cheatCount)

        if Settings.userLevel! >= 1000 {
            levelLabel.text = "Daily"
        } else {
            levelLabel.text = "Level \(Settings.userLevel!)"
        }
        
        if !Settings.showTimer {
            timerStack.isHidden = true
        } else {
            timerStack.isHidden = false
        }
        
        let secs = formatter.string(for: secondsCounter)
        let mins = formatter.string(for: minutesCounter)
        
        secondsLabel.text = ":\(secs!)"
        minutesLabel.text = ":\(mins!)"
        hoursLabel.text = "\(hoursCounter)"
        
        // Indicates to the user that the level they're on has already been
        // completed
        for level in Settings.completedLevels {
            if level == Settings.userLevel! {
                completeIndicator.isHidden = false
            } 
        }
        
        // Indicates to the user that the daily they're on has already been
        // completed
        if Settings.highestDailyComplete == Settings.today && Settings.userLevel! >= 1000 {
            completeIndicator.isHidden = false
        }
    }
    
    func giveBoardSpacesProperties(board: [String]) {
        buttonTitleArray = Array(repeating: "", count: puzzleSize * puzzleSize)
        buttonAcrossArray = Array(repeating: "", count: puzzleSize * puzzleSize)
        buttonDownArray = Array(repeating: "", count: puzzleSize * puzzleSize)
        buttonLockedForCorrect = Array(repeating: false, count: puzzleSize * puzzleSize)
        buttonHintAcrossEnabled = Array(repeating: false, count: puzzleSize * puzzleSize)
        buttonHintDownEnabled = Array(repeating: false, count: puzzleSize * puzzleSize)
        buttonRevealedByHelper = Array(repeating: false, count: puzzleSize * puzzleSize)
        
        // Board[0] contains the letter of each square. If square should be blank, letter is "-"
        let gameBoardLetters = board[0]
        buttonLetterArray = Array(gameBoardLetters)
        
        // Board[1] contains the number of squares to indicate they are a phrase
        let gameBoardNums = board[1]
        
        // Board[2] contains down and across information for each square
        let gameBoardDA = board[2]
        
        // Each string above has different lengths so iteration jumps are different between
        // the strings
        var letterIterator = 0
        var numbersIterator = 0
        var DAIterator = 0
        
        // Containers for object at specific index
        var number: Character
        var daString: String
        
        // Go through all the buttons and assign each one their needed information
        for i in 0...puzzleSize * puzzleSize - 1 {
            
            // Grab the number in the string
            number = gameBoardNums[gameBoardNums.index(gameBoardNums.startIndex, offsetBy: numbersIterator)]
            
            // If the number is a "-" then there should be no number in the top corner so set the label to an empty string
            // Otherwise, set the label on the square to the corresponing number grabbed
            if number == "-"  {
                boardSpaces[i].superscriptLabel.text?.append("")
            } else if number == "," {
                boardSpaces[i].superscriptLabel.text?.append("")
            } else {
                boardSpaces[i].setSuperScriptLabel(number: String(number))
                
                // If the next character is a number as well, append it to the space label (so we can represent 2 digit numbers)
                if gameBoardNums[gameBoardNums.index(gameBoardNums.startIndex, offsetBy: numbersIterator + 1)] != "-" &&
                    numbersIterator > puzzleSize && boardSpaces[i].superscriptLabel.text == "1" && puzzleSize == 13 {
                    boardSpaces[i].superscriptLabel.text?.append(gameBoardNums[gameBoardNums.index(gameBoardNums.startIndex, offsetBy: numbersIterator + 1)])
                    
                    // Need serperate iterator because sometimes we need to take 2 from the string
                    numbersIterator += 1
                }
                
                if puzzleSize > 13 {
                    if gameBoardNums[gameBoardNums.index(gameBoardNums.startIndex, offsetBy: numbersIterator + 1)] != "-" {
                        if gameBoardNums[gameBoardNums.index(gameBoardNums.startIndex, offsetBy: numbersIterator + 1)] != "," {
                            boardSpaces[i].superscriptLabel.text?.append(gameBoardNums[gameBoardNums.index(gameBoardNums.startIndex, offsetBy: numbersIterator + 1)])
                            numbersIterator += 1
                        }
                    }
                    numbersIterator += 1
                }
            }
            
            // The gameBoardDA is set up differently than the other two. Each space contains 6 characters in this format:
            // 00a00d
            // The first two numbers tell what number across it is apart of
            // The a indicates across
            // The second group of numbers tell what number down it is apart of
            // The d indicates down
            // The string looks like 00a00d00a00d01a01d etc.
            // Every button is assigned a down/across string (disabled buttons assigned 00a00d)
            
            // Grabs a string of 6 characters
            let startIndex = gameBoardDA.index(gameBoardDA.startIndex, offsetBy: DAIterator)
            let endIndex = gameBoardDA.index(gameBoardDA.startIndex, offsetBy: DAIterator+5)
            daString = String(gameBoardDA[startIndex...endIndex])
            
            // Splits in half, button's across property assigned first half and down property assigned second half
            let midIndex = daString.index(daString.startIndex, offsetBy: 3)
            buttonAcrossArray[i] = String(daString[..<midIndex])
            buttonDownArray[i] = String(daString[midIndex..<daString.endIndex])
            
            // Increase the iterators. DA iterator increases 6 since it has a greater length than the other strings
            numbersIterator += 1
            letterIterator += 1
            DAIterator += 6
        }
    }
    
    func scrollToSpot(_ sender: BoardButton) {
        var f = CGRect(x: 0, y: 0, width: 0, height: 0)
        f = (boardSpaces[indexOfButton].superview?.convert(sender.frame, to: scroller))!
        
        let buttonX = f.origin.x
        let buttonY = f.origin.y
        
        if !scrollingDisabled && Settings.autoscroll {
            UIView.animate(withDuration: 0.4, animations: {
                self.scroller.scrollRectToVisible(CGRect(x: buttonX - self.scroller.frame.width / 2 - 38,
                                                         y: buttonY - self.scroller.frame.height / 2 - 38,
                                                         width: self.scroller.frame.width,
                                                         height: self.scroller.frame.height), animated: false)
            })
            
        }
    }
    
     /*****************************************
     *                                        *
     *             Action Handling            *
     *                                        *
     *****************************************/
    
    @objc func boardButtonTapped(_ sender: BoardButton) {
        // Use row and column to determine where in the outlet array the
        // selected button is
        indexOfButton = sender.tag
        
        scrollToSpot(sender)
        
        // Determines which buttons are selected and should be highlighted
        rowAndColumnDetermination(indexOfButton: indexOfButton)
        
        // Set the label for the clueLabel
        emojiClue.text = getSpotInfo(indexOfButton: indexOfButton, info: "Clue")
        
        // Set the label for the direction
        determineDirectionText(indexOfButton: indexOfButton)
        
        // Determine if hint buttons should be shown for selected squares
        if (across && buttonHintAcrossEnabled[indexOfButton]) ||
            (!across && buttonHintDownEnabled[indexOfButton]) {
            hintEnabledButton.isHidden = false
            hintEnabledButton.isEnabled = true
            
            hintButton.setImage(UIImage(named: "hint_disabled.png"), for: .normal)
            hintButton.isEnabled = false
        } else {
            hintEnabledButton.isHidden = true
            hintEnabledButton.isEnabled = false
            
            hintButton.setImage(UIImage(named: "hint_button.png"), for: .normal)
            hintButton.isEnabled = true
        }
        
        if buttonRevealedByHelper[indexOfButton] {
            fillSquareButton.isEnabled = false
            fillSquareButton.setImage(UIImage(named: "one_reveal_disabled.png"), for: .normal)
        } else {
            fillSquareButton.setImage(UIImage(named: "one_reveal.png"), for: .normal)
            fillSquareButton.isEnabled = true
        }
        
        if Settings.cheatCount < 5 {
            fillSquareButton.setImage(UIImage(named: "one_reveal_disabled.png"), for: .normal)
        }
        
        if Settings.cheatCount < 10 {
            hintButton.setImage(UIImage(named: "hint_disabled.png"), for: .normal)
        }
        
        if (correctAnswerEntered() && Settings.correctAnim) {
            clueLabel.layer.borderColor = greenColorCG
        } else {
            clueLabel.layer.borderColor = blueColorCG
        }
        
        // Allows us to look back one to see what the last press was
        previousButton = indexOfButton
        
        if clueTableRotated {
            clueTableButton.sendActions(for: .touchUpInside)
        }
    }

    var erasing = false
    @IBAction func eraseButtonTapped(_ sender: Any) {
        // Play an erasing sound
        if Settings.soundEffects {
            MusicPlayer.playSoundEffect(of: "erase", ext: "wav")
        }
        
        // Get current square
        let currentSquareTitle = boardSpaces[indexOfButton].title(for: .normal)
        
        // If the square has text, erase it and stay there
        if currentSquareTitle != nil && (buttonLockedForCorrect[indexOfButton] == false || !Settings.lockCorrect) && !buttonRevealedByHelper[indexOfButton] {
            boardSpaces[indexOfButton].setTitleWithOutAnimation(title: nil)
            buttonTitleArray[indexOfButton] = ""
            defaults.set(buttonTitleArray, forKey: "\(Settings.userLevel!)_buttonTitles")
            
            // Erasing a correct answer should make it uncorrect again
            if buttonLockedForCorrect[indexOfButton] {
                buttonLockedForCorrect[indexOfButton] = false
                defaults.set(buttonLockedForCorrect, forKey: "\(Settings.userLevel!)_lockedCorrect")
            }
        } else {
            // Otherwise, if the square is empty see if we're at the beginning of
            // the selected phrase
            if indexOfButton == selectedBoardSpaces.min() {
                // If we're at the beginning, we are going to go back a phrase
                // when the erase button is pressed. We also need to allow erasing
                // since skip filled squares will affect our jump back a phrase. If
                // we don't, the selector will stay at the same square.
                erasing = true
                backPhraseButton.sendActions(for: .touchUpInside)
                erasing = false
                
                // And the selected square should be the last one of the phrase
                indexOfButton = selectedBoardSpaces.max()!
                
                // Then simulate a tap there
                boardButtonTapped(boardSpaces[indexOfButton])
                
            } else {
                // If we aren't at the beginning of a phrase, just move a square
                // back if across or puzzleSize back if down
                if across {
                    boardButtonTapped(boardSpaces[indexOfButton - 1])
                } else {
                    boardButtonTapped(boardSpaces[indexOfButton - puzzleSize])
                }
            }
            
            // Erase the selected square
            if (buttonLockedForCorrect[indexOfButton] == false || !Settings.lockCorrect) && !buttonRevealedByHelper[indexOfButton] {
                boardSpaces[indexOfButton].setTitleWithOutAnimation(title: nil)
                buttonTitleArray[indexOfButton] = ""
                defaults.set(buttonTitleArray, forKey: "\(Settings.userLevel!)_buttonTitles")

                // If it was locked, we need to unlock it since it is being erased
                if buttonLockedForCorrect[indexOfButton] == true {
                    buttonLockedForCorrect[indexOfButton] = false
                    defaults.set(buttonLockedForCorrect, forKey: "\(Settings.userLevel!)_lockedCorrect")
                }
            }
        }
    }
    
    var checkedAcross = false
    var checkedDown = false
    @IBAction func nextPhraseButtonTapped(_ sender: Any) {
        // Container for candidates that are available to move to
        var moveCandidates = [Int]()
        
        if checkedAcross && checkedDown {
            checkedAcross = false
            checkedDown = false
            
            return
        }
        
        if across {
            // Generate possible candidates for move
            // Looks at the current square to get its across number
            let acrossString = String(buttonAcrossArray[indexOfButton].dropLast())
            let num = Int(acrossString)!
            
            // Candidate for forward movement are any number in across numbers that
            // is greater than the current across value.
            for potentialCandidate in acrossNumbers {
                if potentialCandidate > num {
                    moveCandidates.append(potentialCandidate)
                }
            }
            
            // TEST CANDIDATE
            if !moveCandidates.isEmpty {
                // Start looking at the minimum candidate (first number after current square)
                let candidate = moveCandidates.min()!
                
                // If our candidate is < 10, we need to 0 in the front for comparing,
                // otherwise there is no leading 0.
                var stringToLook = ""
                if candidate < 10 {
                    stringToLook = "0\(candidate)a"
                } else {
                    stringToLook = "\(candidate)a"
                }
                
                // Evaluate the current candidate
                test: for i in 0...puzzleSize * puzzleSize - 1 {
                    // Found the candidate
                    if buttonAcrossArray[i] == stringToLook {
                        // Move to candidate
                        boardButtonTapped(boardSpaces[i])
                        
                        // Sometimes, stop when we hit the first candidate
                        // This occurs when the first letter is not filled, the user
                        // has turned off skip filled squares, or when all squares
                        // have been filled (but aren't all correct)
                        if boardSpaces[i].currentTitle == nil || !Settings.skipFilledSquares || allSquaresFilled() {
                            break
                        }
                        
                        // Move foward through the selected phrase until an empty spot is found
                        for x in selectedBoardSpaces.min()!...selectedBoardSpaces.max()! {
                            if(boardSpaces[x].currentTitle == nil) {
                                boardButtonTapped(boardSpaces[x])
                                return
                                
                            }
                        }
                        
                        // If our candidate was unsuccessful (all squares filled), start over
                        nextPhraseButton.sendActions(for: .touchUpInside)
                        return
                    }
                }
            } else {
                // If our across candidates were empty, switch to down
                across = false
                checkedAcross = true
                
                // Find a blank landing spot (00a00d) so we can evaluate
                // all possibilites
                indexOfButton = 0
                while boardSpaces[indexOfButton].isEnabled {
                    indexOfButton! += 1
                }
                
                // Start over checking down this time
                nextPhraseButton.sendActions(for: .touchUpInside)
                return
            }
        } else if !across {
            // Generate possible candidates for move
            // Looks at the current square to get its down number
            let downString = String(buttonDownArray[indexOfButton].dropLast())
            let num = Int(downString)!
            
            // Candidate for forward movement are any number in down numbers that
            // is greater than the current down value.
            for i in downNumbers {
                if i > num {
                    moveCandidates.append(i)
                }
            }

            // TEST CANDIDATE
            if !moveCandidates.isEmpty {
                // Start looking at the minimum candidate (first number after current square)
                let candidate = moveCandidates.min()!
                
                // If our candidate is < 10, we need to 0 in the front for comparing,
                // otherwise there is no leading 0.
                var stringToLook = ""
                if candidate < 10 {
                    stringToLook = "0\(candidate)d"
                } else {
                    stringToLook = "\(candidate)d"
                }
                
                // Evaluate the current candidate
                test: for i in 0...puzzleSize * puzzleSize - 1 {
                    // Found the candidate
                    if buttonDownArray[i] == stringToLook {
                        boardButtonTapped(boardSpaces[i])
                        
                        // Sometimes, stop when we hit the first candidate
                        // This occurs when the first letter is not filled, the user
                        // has turned off skip filled squares, or when all squares
                        // have been filled (but aren't all correct)
                        if boardSpaces[i].currentTitle == nil || !Settings.skipFilledSquares || allSquaresFilled() {
                            break
                        }
                        
                        // Move foward through the selected phrase until an empty spot is found
                        // Uses stride to allow iterating by puzzleSize each loop
                        for x in stride(from: selectedBoardSpaces.min()!, to: selectedBoardSpaces.max()! + 1, by: puzzleSize) {
                            if(boardSpaces[x].currentTitle == nil) {
                                boardButtonTapped(boardSpaces[x])
                                return
                            }
                        }
                        
                        // If our candidate was unsuccessful (all squares filled), start over
                        nextPhraseButton.sendActions(for: .touchUpInside)
                        return
                    }
                }
            } else {
                // If our down candidates were empty, switch to across
                across = true
                checkedDown = true
                
                // Find a blank landing spot (00a00d) so we can evaluate
                // all possibilites
                indexOfButton = 0
                while boardSpaces[indexOfButton].isEnabled {
                    indexOfButton! += 1
                }
                
                // Start over checking across this time
                nextPhraseButton.sendActions(for: .touchUpInside)
                return
            }
        }
    }
    
    @IBAction func backPhraseButtonTapped(_ sender: Any) {
        // Container for candidates that are available to move to
        var moveCandidates = [Int]()
        
        if across {
            // Generate possible candidates for move
            // Looks at the current square to get its across number
            let acrossString = String(buttonAcrossArray[indexOfButton].dropLast())
            var num = Int(acrossString)!
            
            // If we're starting from a blank landing spot, all values should be candidates
            if num == 0 {
                num = acrossNumbers.max()! + 1
            }
            
            // Candidate for backward movement are any number in across numbers that
            // is smaller than the current across value.
            for potentialCandidate in acrossNumbers {
                if potentialCandidate < num {
                    moveCandidates.append(potentialCandidate)
                }
            }
            
            
            // TEST CANDIDATE
            if !moveCandidates.isEmpty {
                // Start looking at the maximum candidate (first number before current square)
                let candidate = moveCandidates.max()!
                
                // If our candidate is < 10, we need to 0 in the front for comparing,
                // otherwise there is no leading 0.
                var stringToLook = ""
                if candidate < 10 {
                    stringToLook = "0\(candidate)a"
                } else {
                    stringToLook = "\(candidate)a"
                }
                
                // Evaluate our current candidate
                test: for i in 0...puzzleSize * puzzleSize - 1 {
                    // Foud the candidate
                    if buttonAcrossArray[i] == stringToLook {
                        // Move to candidate
                        boardButtonTapped(boardSpaces[i])
                        
                        // Sometimes, stop when we hit the first candidate
                        // This occurs when the first letter is not filled, the user
                        // has turned off skip filled squares, when all squares
                        // have been filled (but aren't all correct), or when
                        // we are erasing
                        if boardSpaces[i].currentTitle == nil || !Settings.skipFilledSquares || allSquaresFilled() || erasing {
                            break
                        }
                        
                        // Move foward through the selected phrase until an empty spot is found
                        for x in selectedBoardSpaces.min()!...selectedBoardSpaces.max()! {
                            print(x)
                            print(boardSpaces[x].titleLabel?.text)
                            if(boardSpaces[x].titleLabel?.text == nil && !buttonLockedForCorrect[x]) {
                                boardButtonTapped(boardSpaces[x])
                                return
                            }
                        }
                        
                        // If our candidate was unsuccessful (all squares filled), start over
                        backPhraseButton.sendActions(for: .touchUpInside)
                        return
                    }
                }
            } else {
                // If our across candidates were empty, switch to down
                across = false
                
                // Find a blank landing spot (00a00d) so we can evaluate
                // all possibilites
                indexOfButton = 0
                while boardSpaces[indexOfButton].isEnabled {
                    indexOfButton! += 1
                }
                
                // Start over checking down this time
                backPhraseButton.sendActions(for: .touchUpInside)
                return
            }
        } else if !across {
            // Generate possible candidates for move
            // Looks at the current square to get its across number
            let downString = String(buttonDownArray[indexOfButton].dropLast())
            var num = Int(downString)!
            
            // If we're starting from a blank landing spot, all values should be candidates
            if num == 0 {
                num = downNumbers.max()! + 1
            }
            
            // Candidate for backward movement is any number in down numbers that
            // is smaller than the current down value.
            for potentialCandidate in downNumbers {
                if potentialCandidate < num {
                    moveCandidates.append(potentialCandidate)
                }
            }
            
            // TEST CANDIDATE
            if !moveCandidates.isEmpty {
                // Start looking at the maximum candidate (first number before current square)
                let candidate = moveCandidates.max()!
                
                // If our candidate is < 10, we need to 0 in the front for comparing,
                // otherwise there is no leading 0.
                var stringToLook = ""
                if candidate < 10 {
                    stringToLook = "0\(candidate)d"
                } else {
                    stringToLook = "\(candidate)d"
                }
                
                // Evaluate our current candidate
                for i in 0...puzzleSize * puzzleSize - 1 {
                    if buttonDownArray[i] == stringToLook {
                        // Move to candidate
                        boardButtonTapped(boardSpaces[i])
                        
                        // Sometimes, stop when we hit the first candidate
                        // This occurs when the first letter is not filled, the user
                        // has turned off skip filled squares, when all squares
                        // have been filled (but aren't all correct), or when
                        // we are erasing
                        if boardSpaces[i].currentTitle == nil || !Settings.skipFilledSquares || allSquaresFilled() || erasing {
                            break
                        }
                        
                        // Move foward through the selected phrase until an empty spot is found
                        test: for x in stride(from: selectedBoardSpaces.min()!, to: selectedBoardSpaces.max()! + 1, by: puzzleSize) {
                            if(boardSpaces[x].currentTitle == nil && !buttonLockedForCorrect[x]) {
                                boardButtonTapped(boardSpaces[x])
                                return
                            }
                        }
                        
                        // If our candidate was unsuccessful (all squares filled), start over
                        backPhraseButton.sendActions(for: .touchUpInside)
                        return
                    }
                }
            } else {
                // If our down candidates were empty, switch to across
                across = true
                
                // Find a blank landing spot (00a00d) so we can evaluate
                // all possibilites
                indexOfButton = 0
                while boardSpaces[indexOfButton].isEnabled {
                    indexOfButton! += 1
                }
                
                // Start over checking across this time
                backPhraseButton.sendActions(for: .touchUpInside)
                return
            }
        }
    }

    @IBAction func hintButtonTapped(_ sender: Any) {
        // If the user is out of cheats, don't do anything
        if Settings.cheatCount < 10 {
            showIAPView()
            return
        }
        
        // Show the hint view
        performSegue(withIdentifier: "hintSegue", sender: self)
        
        // Indicate on the buttons which have hints enabled
        for index in selectedBoardSpaces {
            if across {
                buttonHintAcrossEnabled[index] = true
                defaults.set(buttonHintAcrossEnabled, forKey: "\(Settings.userLevel!)_hintAcross")
                boardSpaces[index].showHintLabel()
            } else {
                buttonHintDownEnabled[index] = true
                defaults.set(buttonHintDownEnabled, forKey: "\(Settings.userLevel!)_hintDown")
                boardSpaces[index].showHintLabel()
            }
        }
        
        // Display the button on the clue area to allow the user to reopen the hint view
        hintEnabledButton.isEnabled = true
        hintEnabledButton.isHidden = false
        hintButton.setImage(UIImage(named: "hint_disabled.png"), for: .normal)
        
        // Remove a cheat and save to defaults
        Settings.cheatCount -= 10
        defaults.set(Settings.cheatCount, forKey: "cheatCount")
        
        // If the user is out of cheats, gray out the buttons
        if Settings.cheatCount < 5 {
            fillSquareButton.setImage(UIImage(named: "one_reveal_disabled.png"), for: .normal)
        }
        
        if Settings.cheatCount < 10 {
            hintButton.setImage(UIImage(named: "hint_disabled.png"), for: .normal)
        }
        
        // Update the cheatlabel
        cheatCountLabel.text = String(Settings.cheatCount)
        view.layoutIfNeeded()
        
        // Don't allow hitting the button again without moving
        hintButton.isEnabled = false
        
        animateGemChange(10, false)
    }
    
    @IBAction func fillSquareButtonTapped(_ sender: Any) {
        // If the user is out of cheats, don't do anything
        if Settings.cheatCount < 5 {
            showIAPView()
            return
        }
        
        // Play a keyboard click sound
        if Settings.soundEffects {
            MusicPlayer.playSoundEffect(of: "click", ext: "wav")
        }
        
        // A square revealed by a cheat should never be able to be erased or changed
        buttonRevealedByHelper[indexOfButton] = true
        buttonLockedForCorrect[indexOfButton] = true
        defaults.set(buttonRevealedByHelper, forKey: "\(Settings.userLevel!)_revealed")
        defaults.set(buttonLockedForCorrect, forKey: "\(Settings.userLevel!)_lockedCorrect")
        
        // Set the title equal to the correct answer
        // Set the background to indicate a cheat was used at that square
        boardSpaces[indexOfButton].setTitleWithOutAnimation(title: String(buttonLetterArray[indexOfButton]).uppercased())
        buttonTitleArray[indexOfButton] = String(buttonLetterArray[indexOfButton]).uppercased()
        defaults.set(buttonTitleArray, forKey: "\(Settings.userLevel!)_buttonTitles")

        boardSpaces[indexOfButton].backgroundColor = UIColor.init(cgColor: orangeColorCG)
        
        // Remove a cheat and save to defaults
        Settings.cheatCount -= 5
        defaults.set(Settings.cheatCount, forKey: "cheatCount")
        
        if Settings.cheatCount < 5 {
            fillSquareButton.setImage(UIImage(named: "one_reveal_disabled.png"), for: .normal)
        }
        
        if Settings.cheatCount < 10 {
            hintButton.setImage(UIImage(named: "hint_disabled.png"), for: .normal)
        }
        
        // Update the cheatlabel
        cheatCountLabel.text = String(Settings.cheatCount)

        // Check if cheat completed a word and animate if it is correct
        if correctAnswerEntered() {
            if Settings.correctAnim {
                highlightCorrectAnswer(withDuration: 0.45)
                
                // Should only play correct sound effect if 3 conditions are met
                // 1. All squares are not filled
                // 2. Sound effects are enabled
                // 3. Correct animations are enabled (If user has turned off the animation,
                //    they most likely don't want confirmation at all of any right answers)
                if !allSquaresFilled() && Settings.soundEffects {
                    MusicPlayer.start(musicTitle: "correct", ext: "mp3")
                }
            }
            
            checkAdProgress()
        }
        
        // We also need to check if correct answer was entered at an intersection.
        // This occurs when one letter of across is left and one letter of down is left.
        // If the correct answer is entered, then we need to highlight both the across
        // and down spaces.
        // So send a press for the current button to flip orientation, then check if
        // that was is correct and highlight if it is.
        if ((across && buttonDownArray[indexOfButton] != "00d") ||
            (!across && buttonAcrossArray[indexOfButton] != "00a")) && Settings.correctAnim {
            boardSpaces[indexOfButton].sendActions(for: .touchUpInside)
            if correctAnswerEntered() {
                highlightCorrectAnswer(withDuration: 0.45)
                
                // Should only play correct sound effect if 3 conditions are met
                // 1. All squares are not filled
                // 2. Sound effects are enabled
                // 3. Correct animations are enabled (If user has turned off the animation,
                //    they most likely don't want confirmation at all of any right answers)
                if !allSquaresFilled() && Settings.soundEffects {
                    MusicPlayer.start(musicTitle: "correct", ext: "mp3")
                }
                
                checkAdProgress()
            }
            
            // Then we'll flip back to our original orientation
            boardSpaces[indexOfButton].sendActions(for: .touchUpInside)
        }
        
        if allSquaresFilled() {
            // See if the user has entered all the right answers
            if gameOver() {
                
                // Disable buttons to prevent messing up animation
                // or the next view being presented
                fillSquareButton.isEnabled = false
                hintButton.isEnabled = false
                for key in keys {
                    key.isEnabled = false
                }
                
                // If they do, perform game over actions
                if Settings.userLevel! < Settings.maxNumOfLevels {
                    defaults.set(Settings.userLevel! + 1, forKey: "userLevel")
                } else {
                    defaults.set(1, forKey: "userLevel")
                }
                
                // Fade out the game music
                MusicPlayer.gameMusicPlayer.setVolume(0, fadeDuration: 2.0)
                
                // Stop the timer
                gameTimer.invalidate()
                
                // Prepare for the next game
                if Settings.userLevel! < 1000 {
                    resetDefaults(Settings.userLevel!)
                }
                
                // Perform game over animation
                animateGameOver()
            
                return
            } else {
                // If the user isn't right, don't finish game
                // Show them view displaying how many they got incorrect
                if !wrongViewShown {
                    // Play error sound
                    if Settings.soundEffects {
                        MusicPlayer.start(musicTitle: "errors", ext: "mp3")
                    }
                    showGameOverView()
                    wrongViewShown = true
                }
            }
        }
        
        // Move after cheat use
        if across {
            moveToNextAcross()
        } else {
            moveToNextDown()
        }
        
        animateGemChange(5, false)
    }
    
    @objc func removeView() {
        // Get rid of other views if they are still in the view
        popUpToRemove?.removeFromSuperview()
        keyBlockerToRemove?.removeFromSuperview()
        tappedButton?.setTitleColor(.white, for: .normal)
    }
    
    @IBAction func iapButtonTapped(_ sender: Any) {
        showIAPView()
    }
    
    @IBOutlet var topKeysStack: UIStackView!
    @IBOutlet var midKeysStack: UIStackView!
    @IBOutlet var bottomKeysStack: UIStackView!
    var popUpToRemove: UIView?
    var keyBlockerToRemove: UIView?
    var tappedButton: UIButton?
    @objc func buttonDown(_ sender: UIButton) {
        removeView()
        tappedButton = sender

        // Gathers button location relative to the entire view
        var f = CGRect(x: 0, y: 0, width: 0, height: 0)
        switch sender.tag {
        case 1...10:
            f = topKeysStack.convert(sender.frame, to: self.view)
        case 11...19:
            f = midKeysStack.convert(sender.frame, to: self.view)
        case 20...26:
            f = bottomKeysStack.convert(sender.frame, to: self.view)
        default:
            return
        }

        let buttonX = f.origin.x
        let buttonY = f.origin.y

        // Create a pop up over the tapped button
        let popUp = UIView(frame: CGRect(x: buttonX - 7.5, y: buttonY - f.height - 10, width: f.width + 15, height: f.height + 30))
        popUp.layer.cornerRadius = sender.layer.cornerRadius
        popUp.backgroundColor = .black
        popUp.layer.shadowColor = UIColor.black.cgColor
        popUp.layer.shadowOpacity = 0.75
        popUp.layer.shadowOffset = CGSize.zero
        popUp.layer.shadowRadius = sender.layer.cornerRadius
        popUp.layer.shadowPath = UIBezierPath(rect: popUp.bounds).cgPath
        view.addSubview(popUp)

        // Add letter to the view equal to the button pressed
        let popUpTitle = UILabel(frame: CGRect(x: 0, y: -5, width: popUp.frame.width, height: popUp.frame.height))
        popUpTitle.textAlignment = .center
        popUpTitle.textColor = .white
        popUpTitle.font  = popUpTitle.font.withSize(sender.titleLabel!.font.pointSize * 1.5)
        popUpTitle.text = sender.title(for: .normal)
        popUp.addSubview(popUpTitle)
        sender.setTitleColor(.black, for: .normal)

        // Invisible view to block the user from tapping multiple buttons in the keyboard area
        // Will be removed on touchUpInside or touchDragExit
        let keyBlocker = UIView(frame: CGRect(x: 0, y: (screenSize.height - (screenSize.height * 0.25)), width: screenSize.width, height: screenSize.height * 0.25))
        keyBlocker.backgroundColor = .clear
        view.addSubview(keyBlocker)

        keyBlockerToRemove = keyBlocker
        popUpToRemove = popUp
    }
    
    @IBAction func keyboardButtonPressed(_ sender: UIButton) {
        // Play a click sound when the keys are tapped
        if Settings.soundEffects {
            MusicPlayer.playSoundEffect(of: "click", ext: "wav")
        }
        
        removeView()
        
        // Each key of the keyboard has a tag from 1-26. The tag tells which key was pressed.
        // Keyboard is standard qwerty and tags start at Q(1) and end at M(26)
        var letter: Character!
        
        switch sender.tag {
        case 1:
            letter = "q"
        case 2:
            letter = "w"
        case 3:
            letter = "e"
        case 4:
            letter = "r"
        case 5:
            letter = "t"
        case 6:
            letter = "y"
        case 7:
            letter = "u"
        case 8:
            letter = "i"
        case 9:
            letter = "o"
        case 10:
            letter = "p"
        case 11:
            letter = "a"
        case 12:
            letter = "s"
        case 13:
            letter = "d"
        case 14:
            letter = "f"
        case 15:
            letter = "g"
        case 16:
            letter = "h"
        case 17:
            letter = "j"
        case 18:
            letter = "k"
        case 19:
            letter = "l"
        case 20:
            letter = "z"
        case 21:
            letter = "x"
        case 22:
            letter = "c"
        case 23:
            letter = "v"
        case 24:
            letter = "b"
        case 25:
            letter = "n"
        case 26:
            letter = "m"
        default:
            letter = nil
        }
                // Sets the board space to display the uppercase letter if the space isn't locked
        if (!buttonLockedForCorrect[indexOfButton] || !Settings.lockCorrect) && !buttonRevealedByHelper[indexOfButton]{
            // If the space was a correct answer but was changed, indicate that square is wrong
            if buttonLockedForCorrect[indexOfButton] &&
                letter != buttonLetterArray[indexOfButton] {
                buttonLockedForCorrect[indexOfButton] = false
                defaults.set(buttonLockedForCorrect, forKey: "\(Settings.userLevel!)_lockedCorrect")
            }
            boardSpaces[indexOfButton].setTitleWithOutAnimation(title: String(letter).uppercased())
            buttonTitleArray[indexOfButton] = String(letter).uppercased()
            defaults.set(buttonTitleArray, forKey: "\(Settings.userLevel!)_buttonTitles")
        } else {
            // If the space is locked, lets just move to the next square
            if across {
                moveToNextAcross()
            } else {
                moveToNextDown()
            }
            return
        }
        
        // After each key press we should check if there is a correct answer. If there is,
        // check if the user has entered all the right answers. If they have, end the game.
        // Otherwise, skip to the next square.
        if correctAnswerEntered() {
            if Settings.correctAnim {
                highlightCorrectAnswer(withDuration: 0.45)
                
                // Should only play correct sound effect if 3 conditions are met
                // 1. All squares are not filled
                // 2. Sound effects are enabled
                // 3. Correct animations are enabled (If user has turned off the animation,
                //    they most likely don't want confirmation at all of any right answers)
                if !allSquaresFilled() && Settings.soundEffects {
                    MusicPlayer.start(musicTitle: "correct", ext: "mp3")
                }

                // We also need to check if correct answer was entered at an intersection.
                // This occurs when one letter of across is left and one letter of down is left.
                // If the correct answer is entered, then we need to highlight both the across
                // and down spaces.
                // So send a press for the current button to flip orientation, then check if
                // that was is correct and highlight if it is.
                if (across && buttonDownArray[indexOfButton] != "00d") ||
                    (!across && buttonAcrossArray[indexOfButton] != "00a") {
                    boardSpaces[indexOfButton].sendActions(for: .touchUpInside)
                    if correctAnswerEntered() {
                        // Should only play correct sound effect if 3 conditions are met
                        // 1. All squares are not filled
                        // 2. Sound effects are enabled
                        // 3. Correct animations are enabled (If user has turned off the animation,
                        //    they most likely don't want confirmation at all of any right answers)
                        if !allSquaresFilled() && Settings.soundEffects {
                            MusicPlayer.start(musicTitle: "correct", ext: "mp3")
                        }
                        
                        highlightCorrectAnswer(withDuration: 0.45)
                    }
                    
                    // Then we'll flip back to our original orientation
                    boardSpaces[indexOfButton].sendActions(for: .touchUpInside)
                }
            }
            
            // See if all the squares have been filled
            if allSquaresFilled() {
                // If all squares are filled, see if the user is right
                if gameOver(){
                    
                    // Stop the timer
                    gameTimer.invalidate()
                    
                    // Disable buttons to prevent messing up animation
                    // or game over view presentation
                    hintButton.isEnabled = false
                    fillSquareButton.isEnabled = false
                    for key in keys {
                        key.isEnabled = false
                    }
                    
                    // Increase the user level
                    if Settings.userLevel! < Settings.maxNumOfLevels {
                        defaults.set(Settings.userLevel! + 1, forKey: "userLevel")
                    } else {
                        defaults.set(1, forKey: "userLevel")
                    }

                    // Turn off game music
                    MusicPlayer.gameMusicPlayer.setVolume(0, fadeDuration: 2.0)
                    
                    // Prepare for next level
                    if Settings.userLevel! < 1000 {
                        resetDefaults(Settings.userLevel!)
                    }

                    // Perform the game over animation
                    animateGameOver()
                    
                    return
                } else {
                    // If the user isn't right, don't finish game
                    // Show them view displaying how many they got incorrect
                    if !wrongViewShown {
                        // Play a error sound
                        if Settings.soundEffects {
                            MusicPlayer.start(musicTitle: "errors", ext: "mp3")
                        }
                        showGameOverView()
                        wrongViewShown = true
                    }
                    
                    // Move accordingly
                    nextPhraseButton.sendActions(for: .touchUpInside)
                }
            } else {
                checkAdProgress()
                
                nextPhraseButton.sendActions(for: .touchUpInside)
            }
            // Return so we go to the first spot in the next phrase and not the second
            return
        } else if allSquaresFilled() {
            if !wrongViewShown {
                // Play an error sound
                if Settings.soundEffects {
                    MusicPlayer.start(musicTitle: "errors", ext: "mp3")
                }
                showGameOverView()
                wrongViewShown = true
            }
            
        } else {
            // This checks the other direction at an intersection but the original
            // direction is not completely correct.
            // Useful when user has all but one letter and is going
            // through at a different direction and fills the last correct
            // space.
            
            // Flip the direction
            boardSpaces[indexOfButton].sendActions(for: .touchUpInside)
            
            // See if that direction is correct and highlight if it is
            if correctAnswerEntered() && Settings.correctAnim {
                highlightCorrectAnswer(withDuration: 0.45)
                
                // Should only play correct sound effect if 3 conditions are met
                // 1. All squares are not filled
                // 2. Sound effects are enabled
                // 3. Correct animations are enabled (If user has turned off the animation,
                //    they most likely don't want confirmation at all of any right answers)
                if !allSquaresFilled() && Settings.soundEffects {
                    MusicPlayer.start(musicTitle: "correct", ext: "mp3")
                }
            }
            
            // Go back to the original direction
            boardSpaces[indexOfButton].sendActions(for: .touchUpInside)
        }
        
        // If there was no correct answer, then move to the next spot in current orientation
        if across {
            moveToNextAcross()
        } else {
            moveToNextDown()
        }
    }
    
    func gameOver() -> Bool {
        for i in 0...puzzleSize * puzzleSize - 1 {
            // Each inactive space is assigned a "-" as their letter.
            // Check if all the buttons that can be tapped have non-nil values.
            // If there is still a nil value, there is an open board space, which
            // means the game is not over.
            if boardSpaces[i].title(for: .normal) == nil && buttonLetterArray[i] != "-" {
                return false
            } else {
                if var spaceTitle = boardSpaces[i].title(for: .normal) {
                    // Letters are stored lowercase while titles are displayed as uppercase.
                    // Lowercase the title so we can compare it with the stored letter.
                    spaceTitle = spaceTitle.lowercased()
                    
                    // Nothing needs to happen if the letters match or we're at a inactive square.
                    // Just continue the loop
                    if Character(spaceTitle) == buttonLetterArray[i] || buttonLetterArray[i] == "-" {
                        /* nothing needs to happen */
                    } else {
                        // If the user entered a wrong answer, then the game is not over
                        return false
                    }
                }

            }
        }
        
        // If we made it all the way through the board spaces without returning false
        // then the user has finished the game.
        return true
    }
    
    func determineAllCorrect() {
        var counter = 0
        if across {
            while across && counter < 100 {
                _ = correctAnswerEntered()
                nextPhraseButton.sendActions(for: .touchUpInside)
                counter += 1
            }
            
            counter = 0
            while !across && counter < 100 {
                _ = correctAnswerEntered()
                nextPhraseButton.sendActions(for: .touchUpInside)
                counter += 1
            }
        } else {
            while !across && counter < 100 {
                _ = correctAnswerEntered()
                nextPhraseButton.sendActions(for: .touchUpInside)
                counter += 1
            }
            
            counter = 0
            while across && counter < 100 {
                _ = correctAnswerEntered()
                nextPhraseButton.sendActions(for: .touchUpInside)
                counter += 1
            }
        }
        
        nextPhraseButton.sendActions(for: .touchUpInside)
    }
    
    func correctAnswerEntered() -> Bool {
        // Checks the selected spaces with their assigned letters, if it determines that
        // they are all correct returns true, otherwise returns false.
        for space in selectedBoardSpaces {
            if let userEntry = boardSpaces[space].title(for: .normal)?.lowercased() {
                let entryToChar = Character(userEntry.lowercased())
                if entryToChar == buttonLetterArray[space] {
                    /* nothing needs to happen */
                } else {
                    return false
                }
            } else {
                return false
            }
        }
        
        // Disallow changing of letters after correct answer entered
        if (!gameOver()) {
            for space in selectedBoardSpaces {
                buttonLockedForCorrect[space] = true
                defaults.set(buttonLockedForCorrect, forKey: "\(Settings.userLevel!)_lockedCorrect")
            }
        }
    
        if !selectedBoardSpaces.isEmpty && !correctClues.contains(getSpotInfo(indexOfButton: selectedBoardSpaces[0], info: "Clue")) {
            correctClues.append(getSpotInfo(indexOfButton: selectedBoardSpaces[0], info: "Clue"))
        }
        return true
    }
    
    func moveToNextAcross() {
        // Checks bounds before movement
        if indexOfButton < puzzleSize * puzzleSize - 1 {
            boardSpaces[indexOfButton + 1].sendActions(for: .touchUpInside)
        } else {
            across = false
            nextPhraseButton.sendActions(for: .touchUpInside)
            return
        }
        
        // If we hit a disabled square or a square not part of an across go to next across phrase
        if !boardSpaces[indexOfButton].isEnabled || buttonAcrossArray[indexOfButton] == "00a" {
            boardSpaces[indexOfButton - 1].sendActions(for: .touchUpInside)
            nextPhraseButton.sendActions(for: .touchUpInside)
        }
        
        // Skip filled squares
        if boardSpaces[indexOfButton].currentTitle != nil && Settings.skipFilledSquares {
            // We need to check and make sure all the across squares aren't filled
            // If they are, and we try to move to the next across, we get an infinite loop
            // Use of an iterator to see if we've gone through every single button helps
            // us decide if we've evaluated all possible across squares to move to. If we
            // have checked every square we need to go to the next available down. We also
            // check all squares filled as well because even if the iterator has checked
            // to see if we can't do anymore across, it'll just oscilate between across
            // and down checking.
            if gameOver() || allSquaresFilled() {
                return
            }
            
            // Do the iterator checking
            checkAllDirectionFilledIterator += 1
            if checkAllDirectionFilledIterator > puzzleSize * puzzleSize - 1 {
                indexOfButton = 0
                checkAllDirectionFilledIterator = 0
                across = false
                moveToNextDown()
                return
            }
            
            moveToNextAcross()
        }
        
        // Reset the iterator if we've made a successful move
        checkAllDirectionFilledIterator = 0
    }
    
    func moveToNextDown() {
        // Bounds check
        var outOfBounds = false
        if indexOfButton + puzzleSize > puzzleSize * puzzleSize - 1 {
            outOfBounds = true
        }
        
        if !outOfBounds {
            boardSpaces[indexOfButton + puzzleSize].sendActions(for: .touchUpInside)
            across = false
        }
        
        // Loop through our array containing all down number. Since the array is sorted,
        // once we hit a number greater than the current one that's where we'll jump.
        // If we ever hit a spot where we loop through the whole down array, we're going
        // to flip the orientation to across and go to the first across.
        if outOfBounds || !boardSpaces[indexOfButton].isEnabled || buttonDownArray[indexOfButton] == "00d" {
            boardSpaces[indexOfButton - puzzleSize].sendActions(for: .touchUpInside)
            nextPhraseButton.sendActions(for: .touchUpInside)
        }
        
        // Skip filled squares
        if boardSpaces[indexOfButton].currentTitle != nil && Settings.skipFilledSquares {
            // We need to check and make sure all the down squares aren't filled
            // If they are, and we try to move to the next down, we get an infinite loop
            // Use of an iterator to see if we've gone through every single button helps
            // us decide if we've evaluated all possible across squares to move to. If we
            // have checked every square we need to go to the next available across. We also
            // check all squares filled as well because even if the iterator has checked
            // to see if we can't do anymore across, it'll just oscilate between across
            // and down checking.
            if gameOver() || allSquaresFilled() {
                return
            }
            
            // Do the iterator checking
            checkAllDirectionFilledIterator += 1
            if checkAllDirectionFilledIterator > puzzleSize * puzzleSize - 1 {
                indexOfButton = 0
                checkAllDirectionFilledIterator = 0
                across = true
                moveToNextAcross()
                return
            }

            moveToNextDown()
        }
        
        // Reset the iterator if we've made a successful move
        checkAllDirectionFilledIterator = 0
    }
    
    func getSpotInfo(indexOfButton: Int, info: String) -> String {
        var i = 0
        // Grabs the clue related to the selected square
        // If we are currently looking for across, get the across clue associated with the square
        if across {
            // Grab across variable to determine where in the plist we should look
            // Remember, the across string is in the form 00a, with the numbers being
            // the related across
            let across = buttonAcrossArray[indexOfButton]
            
            // Toss out the a, and a leading 0 if it is there
            // The plist has the number with no leading 0
            var numAcross = String(across[across.startIndex..<across.index((across.startIndex), offsetBy: 2)])
            if numAcross[numAcross.startIndex] == "0" {
                numAcross = String(numAcross[numAcross.index(numAcross.startIndex, offsetBy: 1)])
            }
            
            // Go through the plist until we find the matching across
            while i < acrossClues.count {
                // If we find the across, set the clue label to the matching clue.
                // Since our plist is set up with Phrase/Clue/Hint/Across/Down all in the
                // same index, we can use the index where we found our across number to get
                // the corresponding clue
                if acrossClues[i].Num == numAcross {
                    switch info {
                        case "Clue":
                            return acrossClues[i].Clue
                        case "Hint":
                            return acrossClues[i].Hint
                        case "WordCt":
                            return acrossClues[i].WordCt
                        case "Num":
                            return acrossClues[i].Num
                        default:
                            return ""
                    }
                }
                i += 1
            }
        } else {
            // If we are currently looking for down, get the down clue associated with the square
            
            // Grab down variable to determine where in the plist we should look
            // Remember, the down string is in the form 00d, with the numbers being
            // the related down
            let down = buttonDownArray[indexOfButton]
            
            // Toss out the d, and a leading 0 if it is there
            // The plist has the number with no leading 0
            var numDown = String(down[down.startIndex..<down.index((down.startIndex), offsetBy: 2)])
            if numDown[numDown.startIndex] == "0" {
                numDown = String(numDown[numDown.index(numDown.startIndex, offsetBy: 1)])
            }
            
            // If we find the down, set the clue label to the matching clue.
            // Since our plist is set up with Phrase/Clue/Hint/Across/Down all in the
            // same index, we can use the index where we found our down number to get
            // the corresponding clue
            while i < downClues.count {
                if downClues[i].Num == numDown {
                    switch info {
                    case "Clue":
                        return downClues[i].Clue
                    case "Hint":
                        return downClues[i].Hint
                    case "WordCt":
                        return downClues[i].WordCt
                    case "Num":
                        return downClues[i].Num
                    default:
                        return ""
                    }
                }
                i += 1
            }
        }
        
        // Nothing found (shouldn't ever happen)
        return ""
    }
    
    // Checks if all the available spaces have been answered
    func allSquaresFilled() -> Bool {
        for button in boardSpaces {
            if !button.isEnabled || button.currentTitle != nil {
                /* Don't need to do anything, keep loop going */
            } else {
                // Found an empty square, board is not filled
                return false
            }
        }
        return true
    }
    
    // Count wrong answers and display where they are to the user
    var indexOfWrong = [Int]()
    func countWrong() -> Int {
        var numberWrongCounter = 0
        indexOfWrong.removeAll()
        
        // Loop through the board spaces and find how many errors the user made
        for i in 0...puzzleSize * puzzleSize - 1 {
            if var spaceTitle = boardSpaces[i].title(for: .normal) {
                // Letters are stored lowercase while titles are displayed as uppercase.
                // Lowercase the title so we can compare it with the stored letter.
                spaceTitle = spaceTitle.lowercased()
                    
                // Nothing needs to happen if the letters match or we're at a inactive square.
                // Just continue the loop
                if Character(spaceTitle) == buttonLetterArray[i] || buttonLetterArray[i] == "-" {
                    /* nothing needs to happen */
                } else {
                    // If the user entered a wrong answer, increase our counter
                    numberWrongCounter += 1
                    indexOfWrong.append(i)
                }
            }
        }
        
        return numberWrongCounter
    }
    
     /*****************************************
     *                                        *
     *             Help functions             *
     *                                        *
     *****************************************/
    
    @IBOutlet var nextHelpWidth: NSLayoutConstraint!
    func helpSetupAndDisplay() {
        if screenSize.height == 568 {
            hintHelpLabel.font = hintHelpLabel.font.withSize(15)
            boardHelpLabel.font = hintHelpLabel.font.withSize(15)
            clueHelpLabel.font = hintHelpLabel.font.withSize(15)
            menuHelpLabel.font = hintHelpLabel.font.withSize(15)
            nextHelpWidth.constant = 55
            nextHelpButton.titleLabel?.font = nextHelpButton.titleLabel?.font.withSize(55)
        } else if screenSize.height == 667 || screenSize.height == 812 {
            nextHelpWidth.constant = 60
            nextHelpButton.titleLabel?.font = nextHelpButton.titleLabel?.font.withSize(60)
        }
        
        // Start at the first help display
        helpNum = 1
        
        // Dimmers are UIViews on top of everything. They are black with opacity at 80%.
        // The gameboard and elements are slightly visible. These will be modified to emphasize
        // which elements on the board have help info being displayed.
        //
        // zPosition ensures that the help elements show above the pulsing, selected square
        topBarDimmer.isHidden = false
        topBarDimmer.layer.zPosition = 1001
        boardDimmer.isHidden = false
        boardDimmer.layer.zPosition = 1001
        clueDimmer.isHidden = false
        clueDimmer.layer.zPosition = 1001
        keysDimmer.isHidden = false
        keysDimmer.layer.zPosition = 1001
        bottomDimmer.isHidden = false
        bottomDimmer.layer.zPosition = 1001
        menuDimmer.isHidden = false
        menuDimmer.layer.zPosition = 1001
        
        // Arrows that point to undimmed element. Makes things look nice.
        hintHelpArrow.isHidden = true
        hintHelpArrow.layer.zPosition = 1001
        boardHelpArrow.isHidden = true
        boardHelpArrow.layer.zPosition = 1001
        clueHelpArrow.isHidden = true
        clueHelpArrow.layer.zPosition = 1001
        menuHelpArrow.isHidden = true
        menuHelpArrow.layer.zPosition = 1001
        
        // These labels explain the undimmed elements purpose and actions
        hintHelpLabel.isHidden = true
        hintHelpLabel.layer.zPosition = 1001
        boardHelpLabel.isHidden = true
        boardHelpLabel.layer.zPosition = 1001
        clueHelpLabel.isHidden = true
        clueHelpLabel.layer.zPosition = 1001
        menuHelpLabel.isHidden = true
        menuHelpLabel.layer.zPosition = 1001
        
        // Used to close the help views at the end
        helpFinishedButton.isHidden = true
        helpFinishedButton.layer.zPosition = 1001
        
        // Used to move to next help screen
        nextHelpButton.isHidden = false
        nextHelpButton.layer.zPosition = 1001
        
        // Image to display which of the 4 help pages we're on
        helpNumIndicator.isHidden = false
        helpNumIndicator.layer.zPosition = 1001
        helpNumIndicator.image = UIImage(named: "help1.png")
        
        // Makes the buttons look nice
        helpFinishedButton.layer.borderColor = blueColorCG
        helpFinishedButton.layer.borderWidth = 3
        helpFinishedButton.layer.cornerRadius = 10
        
        nextHelpButton.layer.borderColor = blueColorCG
        nextHelpButton.layer.borderWidth = 3
        nextHelpButton.layer.cornerRadius = 10
        
        // Pick which help should show
        helpScreenPicker()
    }
    
    func hideAllHelp() {
        // Hide all the elements involved in hints
        topBarDimmer.isHidden = true
        boardDimmer.isHidden = true
        clueDimmer.isHidden = true
        keysDimmer.isHidden = true
        bottomDimmer.isHidden = true
        menuDimmer.isHidden = true
        ipxDimmer.isHidden = true
        
        hintHelpArrow.isHidden = true
        boardHelpArrow.isHidden = true
        clueHelpArrow.isHidden = true
        menuHelpArrow.isHidden = true
        
        hintHelpLabel.isHidden = true
        boardHelpLabel.isHidden = true
        clueHelpLabel.isHidden = true
        menuHelpLabel.isHidden = true
        
        helpFinishedButton.isHidden = true
        nextHelpButton.isHidden = true
        helpNumIndicator.isHidden = true
        
        helpFinishedButton.isHidden = true
        nextHelpButton.isHidden = true
        helpNumIndicator.isHidden = true
    }
    
    func helpScreenPicker() {
        ipxDimmer.isHidden = false
        
        // Handles which element to highlight
        switch helpNum {
        case 1:
            topBarDimmer.isHidden = true
            hintHelpArrow.isHidden = false
            hintHelpArrow.alpha = 0
            hintHelpArrow.fadeIn(withDuration: 0.5)
            hintHelpLabel.isHidden = false
            hintHelpLabel.alpha = 0
            hintHelpLabel.fadeIn(withDuration: 0.5)
            
            boardDimmer.isHidden = false
            boardHelpArrow.isHidden = true
            boardHelpLabel.isHidden = true
            
            clueDimmer.isHidden = false
            clueHelpArrow.isHidden = true
            clueHelpLabel.isHidden = true
            
            menuDimmer.isHidden = false
            menuHelpArrow.isHidden = true
            menuHelpLabel.isHidden = true
            
            helpNumIndicator.image = UIImage(named: "help1.png")
            
            helpNum! += 1
        case 2:
            topBarDimmer.isHidden = false
            hintHelpArrow.isHidden = true
            hintHelpLabel.isHidden = true
            
            boardDimmer.isHidden = true
            boardHelpArrow.isHidden = false
            boardHelpArrow.alpha = 0
            boardHelpArrow.fadeIn(withDuration: 0.5)
            
            boardHelpLabel.isHidden = false
            boardHelpLabel.alpha = 0
            boardHelpLabel.fadeIn(withDuration: 0.5)
            
            
            clueDimmer.isHidden = false
            clueHelpArrow.isHidden = true
            clueHelpLabel.isHidden = true
            
            menuDimmer.isHidden = false
            menuHelpArrow.isHidden = true
            menuHelpLabel.isHidden = true
            
            helpNumIndicator.image = UIImage(named: "help2.png")
            
            helpNum! += 1
        case 3:
            topBarDimmer.isHidden = false
            hintHelpArrow.isHidden = true
            hintHelpLabel.isHidden = true
            
            boardDimmer.isHidden = false
            boardHelpArrow.isHidden = true
            boardHelpLabel.isHidden = true
            
            clueDimmer.isHidden = true
            clueHelpArrow.isHidden = false
            clueHelpArrow.alpha = 0
            clueHelpArrow.fadeIn(withDuration: 0.5)
            clueHelpLabel.isHidden = false
            clueHelpLabel.alpha = 0
            clueHelpLabel.fadeIn(withDuration: 0.5)
            
            menuDimmer.isHidden = false
            menuHelpArrow.isHidden = true
            menuHelpLabel.isHidden = true
            
            helpNumIndicator.image = UIImage(named: "help3.png")
            
            helpNum! += 1
        case 4:
            topBarDimmer.isHidden = false
            hintHelpArrow.isHidden = true
            hintHelpLabel.isHidden = true
            
            boardDimmer.isHidden = false
            boardHelpArrow.isHidden = true
            boardHelpLabel.isHidden = true
            
            clueDimmer.isHidden = false
            clueHelpArrow.isHidden = true
            clueHelpLabel.isHidden = true
            
            menuDimmer.isHidden = true
            menuHelpArrow.isHidden = false
            menuHelpArrow.alpha = 0
            menuHelpArrow.fadeIn(withDuration: 0.5)
            
            menuHelpLabel.isHidden = false
            
            menuHelpLabel.alpha = 0
            menuHelpLabel.fadeIn(withDuration: 0.5)
            
            
            helpFinishedButton.isHidden = false
            helpFinishedButton.alpha = 0
            helpFinishedButton.fadeIn(withDuration: 1)
            
            nextHelpButton.isHidden = true
            
            helpNumIndicator.image = UIImage(named: "help4.png")
            helpNum = 1
        default:
            topBarDimmer.isHidden = true
            hintHelpArrow.isHidden = false
            hintHelpLabel.isHidden = false
            
            boardDimmer.isHidden = false
            boardHelpArrow.isHidden = true
            boardHelpLabel.isHidden = true
            
            clueDimmer.isHidden = false
            clueHelpArrow.isHidden = true
            clueHelpLabel.isHidden = true
            
            menuDimmer.isHidden = false
            menuHelpArrow.isHidden = true
            menuHelpLabel.isHidden = true
            
            helpNumIndicator.image = UIImage(named: "help1.png")
        }
    }
    
    @IBAction func helpFinishedTapped(_ sender: Any) {
        // Set default so we know that we've seen help before
        // Don't need to show user every time they play, just the first time
        defaults.set(true, forKey: "helpShownBefore")
        
        // Dimiss all the help elements
        hideAllHelp()
    }
    @IBAction func nextHelpTapped(_ sender: Any) {
        
        // Move to the next element in the help items
        helpScreenPicker()
    }
    
    var clueTableRotated = false
    @IBAction func toggleClueTable(_ sender: Any) {
        if clueTable.alpha < 1 {
            clueTable.reloadData()
            UIView.animate(withDuration: 0.5) {
                self.clueTable.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.clueTable.alpha = 0
            }
        }
        
        if !clueTableRotated {
            UIView.animate(withDuration: 0.25) {
                self.clueTableButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
            clueTableRotated = true
        } else {
            UIView.animate(withDuration: 0.25) {
                self.clueTableButton.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
            }
            clueTableRotated = false
        }
    }
    
    
     /*****************************************
     *                                        *
     *               Highlighting             *
     *                                        *
     *****************************************/
    func highlight(selectedSpaces: [Int], atSquare: Int, prevSquare: Int) {
        // Sets the border for the spaces
        for i in selectedSpaces {
            // CAShapeLayer allows us to put the border outside of the button, giving the button more space
            let border = CAShapeLayer()
            
            // Sets the properties of the border
            // Give the layer a name so we can remove it when it shouldn't be highlighted
            border.name = "BORDER"
            border.frame = boardSpaces[i].bounds
            border.lineWidth = 2.5
            if UIScreen.main.bounds.height > 812 {
                border.lineWidth = 3.5
            }
            border.path = UIBezierPath(roundedRect: border.bounds, cornerRadius:3).cgPath
            border.fillColor = UIColor.clear.cgColor
            border.strokeColor = blueColorCG
            self.boardSpaces[i].layer.addSublayer(border)
        }
        
        // Gives the selected button a pulsing animation
        if atSquare != prevSquare {
            let pulse = CABasicAnimation(keyPath: "transform.scale")
            pulse.duration = 1.3
            pulse.autoreverses = true
            pulse.repeatCount = .infinity
            pulse.fromValue = 1
            pulse.toValue = 1.25
            self.boardSpaces[atSquare].layer.add(pulse, forKey: "pulse")
            boardSpaces[atSquare].layer.zPosition = 1000
            
            // Make sure that the pulsing button always grows above the others
            for space in boardSpaces {
                if space != boardSpaces[atSquare] {
                    space.layer.zPosition = 0
                }
            }
        }
    }
    
    func highlightCorrectAnswer(withDuration amount: Double) {
        // Sets the border for the spaces
        for i in selectedBoardSpaces {
            // CAShapeLayer allows us to put the border outside of the button, giving the button more space
            let border = CAShapeLayer()
            
            // Sets the properties of the border
            border.frame = boardSpaces[i].bounds
            border.name = "correctBorder"

            // Width is 0 since we don't want a border left over after the animation
            border.lineWidth = 0
            border.path = UIBezierPath(roundedRect: border.bounds, cornerRadius:3).cgPath
            border.fillColor = UIColor.clear.cgColor
            border.strokeColor = UIColor.green.cgColor
            
            self.boardSpaces[i].layer.addSublayer(border)
            
            // Animation to be played on the border. Grows quickly then shrinks.
            let animation = CABasicAnimation(keyPath: "lineWidth")
            animation.duration = amount
            animation.fromValue = 0
            animation.toValue = 5
            animation.autoreverses = true
            border.add(animation, forKey: "correct")
            border.zPosition = 1000
            boardSpaces[i].rotate360Degrees(duration: amount)
        }
    }
    
    func highlightWrongAnswers() {
        // Sets the border for the spaces
        for i in indexOfWrong {
            // CAShapeLayer allows us to put the border outside of the button, giving the button more space
            let border = CAShapeLayer()
            
            // Sets the properties of the border
            border.frame = boardSpaces[i].bounds
            
            // Width is 0 since we don't want a border left over after the animation
            border.lineWidth = 0
            border.path = UIBezierPath(roundedRect: border.bounds, cornerRadius:3).cgPath
            border.fillColor = UIColor.clear.cgColor
            border.strokeColor = UIColor.red.cgColor
            
            self.boardSpaces[i].layer.addSublayer(border)
            
            // Animation to be played on the border. Grows quickly then shrinks.
            let animation = CABasicAnimation(keyPath: "lineWidth")
            animation.duration = 0.45
            animation.fromValue = 0
            animation.toValue = 5
            animation.autoreverses = true
            animation.repeatCount = 5
            border.add(animation, forKey: "")
            border.zPosition = 1000
            
            // MARK: maybe do this?
            // boardSpaces[i].backgroundColor = .red
        }
    }
    
    func determineDirectionText(indexOfButton: Int) {
        // This text is displayed in the clue bar. Extra indicator of where the user is and what
        // direction they are currently inputting text for.
        // ex: Displays "1↓" for one down
        
        var number: Int
        var direction: Character
        
        // Grabs information from the current square. Current orientation determines which info
        // should be grabbed.
        if across {
            let acrossString = buttonAcrossArray[indexOfButton]
            let acrossStringStart = acrossString.startIndex
            let acrossStringEnd = acrossString.endIndex
            
            number = Int(acrossString[acrossStringStart...acrossString.index(after: acrossStringStart)])!
            direction = acrossString[(acrossString.index(before: acrossStringEnd))]
        } else {
            let downString = buttonDownArray[indexOfButton]
            let downStart = downString.startIndex
            let downEnd = downString.endIndex
            
            number = Int(downString[downStart...downString.index(after: downStart)])!
            direction = downString[(downString.index(before: downEnd))]
        }
        
        // Start creating our label with the number of the across or down
        var directionLabelText = String(number)
        
        // Append the arrow to string we're going to set
        if direction == "a" {
            directionLabelText.append("→")
        } else {
            directionLabelText.append("↓")
        }
        
        // Set the label
        directionLabel.text = directionLabelText
    }
    
    func rowAndColumnDetermination(indexOfButton: Int) {
        var i = indexOfButton
        
        // Remove border from old selection
        for button in boardSpaces {
            for layer in button.layer.sublayers! {
                if layer.name == "BORDER" {
                    layer.removeFromSuperlayer()
                }
            }
        }
        
        // Empty array containing previous board spaces
        selectedBoardSpaces.removeAll(keepingCapacity: false)
        
        // Sets the initial highlight based on what path it is included in
        // If there is no down then automatically switch to across
        // If there is no across, automatically switch to down
        if buttonDownArray[indexOfButton] == "00d" {
            across = true
        } else if buttonAcrossArray[indexOfButton] == "00a" {
            across = false
        }
        
        // Double tapping on a button results in flipping its orietation as long as
        // the flip is valid and the button is part of both across and down
        if indexOfButton == previousButton && across && buttonDownArray[indexOfButton] != "00d"{
            across = false
        } else if indexOfButton == previousButton && !across && buttonAcrossArray[indexOfButton] != "00a"{
            across = true
        }
        
        // Here we determine which buttons should be included in highlighting
        // If our current orientation is across, then only highlight rows
        if across {
            // Used to check if we hit the end or beginning of a row
            var atBeginningOfRow: Bool
            var atEndOfRow: Bool
            
            // Since everything is layed out in an array with puzzleSize squares each,
            // the first square in the row will always equal 0 when modulo'd
            // with puzzleSize. This way we can see if we should stop picking squares
            // in the left direction
            if i % puzzleSize == 0 {
                atBeginningOfRow = true
            } else {
                atBeginningOfRow = false
            }
            
            // Likewise, each end of the row + 1 will be 0 when modulo'd with
            // puzzleSize. This way we can determine if we should stop picking squares
            // in the right direction
            if (i + 1) % puzzleSize == 0 {
                atEndOfRow = true
            } else {
                atEndOfRow = false
            }
            
            // Start at the selected square and work to the left to find other
            // squares that should be highlighted. Stops when we hit the beginning
            // of the row or a disabled button
            while !atBeginningOfRow && boardSpaces[i].isEnabled {
                selectedBoardSpaces.append(i)
                if i % puzzleSize == 0 {
                    atBeginningOfRow = true
                }
                i -= 1
            }
            
            // Start at the selected square and work to the right to find other
            // squares that should be highlighted. Stops when we hit the end
            // of the row or a disabled button
            i = indexOfButton
            while !atEndOfRow && boardSpaces[i].isEnabled {
                selectedBoardSpaces.append(i)
                if (i + 1) % puzzleSize == 0 {
                    atEndOfRow = true
                }
                i += 1
            }
        } else {
            // Used to check if we hit the top or bottom of a column
            var topOfColumn: Bool
            var bottomOfColumn: Bool
            
            // To determine if we hit the top, decrease our index by puzzleSize.
            // If it is negative, then there are no further squares to
            // continue going up.
            if (i - puzzleSize) < 0 {
                topOfColumn = true
            } else {
                topOfColumn = false
            }
            
            // To determine if we hit the bottom, increase our index by puzzleSize.
            // If it is over puzzleSize sqaured (total number of squares), then there are
            // no further squares to continue going down.
            if (i + puzzleSize) > puzzleSize * puzzleSize - 1 {
                bottomOfColumn = true
            } else {
                bottomOfColumn = false
            }
            
            // Start at the selected square and work to the top to find other
            // squares that should be highlighted. Stops when we hit the top
            // of the column or a disabled button
            while !topOfColumn && boardSpaces[i].isEnabled {
                selectedBoardSpaces.append(i)
                i -= puzzleSize
                if i < 0 {
                    topOfColumn = true
                }
            }
            
            // Start at the selected square and work to the bottom to find other
            // squares that should be highlighted. Stops when we hit the bottom
            // of the column or a disabled button
            i = indexOfButton
            while !bottomOfColumn && boardSpaces[i].isEnabled {
                selectedBoardSpaces.append(i)
                i += puzzleSize
                if i > puzzleSize * puzzleSize - 1 {
                    bottomOfColumn = true
                }
            }
        }
        
        // Highlight the row or column selected
        // previousButton is only < 0 during initial highlighting. This prevents
        // animation from being removed when we actually want it.
        if indexOfButton != previousButton && previousButton >= 0 {
            boardSpaces[previousButton].layer.removeAnimation(forKey: "pulse")
            boardSpaces[previousButton].layer.removeAnimation(forKey: "correct")
        }
        
        // Converts the board spaces to a set to make all entries unique, then back to an array
        selectedBoardSpaces = Array(Set(selectedBoardSpaces))
        
        // Handles highlighting the needed selected squares
        highlight(selectedSpaces: selectedBoardSpaces, atSquare: indexOfButton, prevSquare: previousButton)
    }
    
    func initialHighlight() {
        // Ensures that animation will always be active when coming back from background
        previousButton = -1

        if inGame {
            // inGame is set at the initial viewWillAppear, this allows us to jump
            // to the right spot and animate it after coming from background or
            // coming from an ad.
            boardSpaces[indexOfButton].sendActions(for: .touchUpInside)
            return
        }

        // Start the user on whatever 1 is available (prefers 1 across)
        for i in 0...puzzleSize * puzzleSize - 1 {
            // If there is no 1 across, start vertical
            if buttonAcrossArray[i] == "01a" || buttonDownArray[i] == "01d" {
                if buttonDownArray[i] == "01d" && buttonAcrossArray[i] != "01a" {
                    across = false
                }

                boardSpaces[i].sendActions(for: .touchUpInside)
                
                break
            }
        }
    }
    
    func animateGameOver() {
        // Play the game over music
        if Settings.soundEffects {
            MusicPlayer.start(musicTitle: "gameOver", ext: "mp3")
        }
        
        // Set all active buttons as our selected spaces so we can highlight them
        selectedBoardSpaces.removeAll()
        for i in 0...puzzleSize * puzzleSize - 1 {
            if boardSpaces[i].isEnabled {
                selectedBoardSpaces.append(i)
            }
        }
        
        // Highlight all active buttons
        highlightCorrectAnswer(withDuration: 1.5)
        
        // Perform the spin animation
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveLinear, animations: {
            () -> Void in
            for i in 0...self.puzzleSize * self.puzzleSize - 1 {
                // For every enabled button, if its enabled, make it spin
                if self.boardSpaces[i].isEnabled {
                    // Put z postion high to spin over the black squares
                    self.boardSpaces[i].layer.zPosition = 1000
                    
                    // Go 180 degrees
                    self.boardSpaces[i].transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                }
            }})
        
        // Perform second spin to get from 180 degrees back to original position
        UIView.animate(withDuration: 1.0, delay: 0.95, options: .curveLinear,animations: {
            () -> Void in
            for i in 0...self.puzzleSize * self.puzzleSize - 1 {
                if self.boardSpaces[i].isEnabled {
                    self.boardSpaces[i].layer.zPosition = 1000
                    self.boardSpaces[i].transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
                }
            }
        }, completion: {
            Void in
            
            // After completion of spin, let the board spaces fall off screen
            for i in 0...self.puzzleSize * self.puzzleSize - 1 {
                if self.boardSpaces[i].isEnabled {
                    // z position at -1 lets spaces go behind the keyboard
                    self.boardSpaces[i].layer.zPosition = -1
                    let push = UIPushBehavior(items: [self.boardSpaces[i]], mode: .continuous)
                    push.setAngle(.pi/2.0, magnitude: CGFloat(Double(arc4random_uniform(11)) + 20) / 100)
                    
                    // Begin animation
                    self.animator?.addBehavior(push)
                } else {
                    // z position lower than enabled buttons to be behind the falling pieces
                    self.boardSpaces[i].layer.zPosition = -2
                }
            }
            
            // Show the game over view
            self.showGameOverView()
        })
    }
    
    func animateGameStart() {
        for i in 0...puzzleSize * puzzleSize - 1 {
            // FLY IN ANIMATION
            let randomDirection = arc4random_uniform(4)
            let randomModifier = (CGFloat(arc4random_uniform(101)) / 50) - 1
            switch randomDirection {
                case 0:
                    boardSpaces[i].frame.origin.y -= view.frame.height
                    boardSpaces[i].frame.origin.x += view.frame.width * randomModifier
                case 1:
                    boardSpaces[i].frame.origin.x += view.frame.width
                    boardSpaces[i].frame.origin.y += view.frame.height * randomModifier
                case 2:
                    boardSpaces[i].frame.origin.y += view.frame.height
                    boardSpaces[i].frame.origin.x += view.frame.width * randomModifier
                case 3:
                    boardSpaces[i].frame.origin.x -= view.frame.width
                default:
                    print("Error")
            }

            // Generate a speed between 1.0 and 1.5 seconds
            let randomSpeed = Double(arc4random_uniform(200) + 51) / 100.0

            UIView.animate(withDuration: randomSpeed,
                           delay: 0,
                           usingSpringWithDamping: 0.95,
                           initialSpringVelocity: 0,
                           options: .curveEaseOut,
                           animations:  {
                switch randomDirection {
                case 0:
                    self.boardSpaces[i].frame.origin.y += self.view.frame.height
                    self.boardSpaces[i].frame.origin.x -= self.view.frame.width * randomModifier
                case 1:
                    self.boardSpaces[i].frame.origin.x -= self.view.frame.width
                    self.boardSpaces[i].frame.origin.y -= self.view.frame.height * randomModifier
                case 2:
                    self.boardSpaces[i].frame.origin.y -= self.view.frame.height
                    self.boardSpaces[i].frame.origin.x -= self.view.frame.width * randomModifier
                case 3:
                    self.boardSpaces[i].frame.origin.x += self.view.frame.width
                    self.boardSpaces[i].frame.origin.y -= self.view.frame.height * randomModifier
                default:
                    print("Error")
                }
            })
        }
    }
    
     /*****************************************
     *                                        *
     *               Level Set up             *
     *                                        *
     *****************************************/
    
    func fillAcrossDownArrays() {
        
        if Settings.userLevel! >= 1000 {
            let LEVEL_INDEX = levelIndex!
            // Grab across and down numbers and append them to the array
            for key in Settings.dailies[LEVEL_INDEX]["Across"]!.keys {
                acrossNumbers.append(Int(key)!)
            }
            
            for key in Settings.dailies[LEVEL_INDEX]["Down"]!.keys {
                downNumbers.append(Int(key)!)
            }
        } else {
            var levelIndex: Int!
            if Settings.userLevel < 200 {
                levelIndex = Settings.userLevel! - 1
            } else if Settings.userLevel >= 200 && Settings.userLevel < 400 {
                levelIndex = Settings.userLevel! - 201
            } else if Settings.userLevel >= 400 && Settings.userLevel < 600 {
                levelIndex = Settings.userLevel! - 401
            }
            // Grab across and down numbers and append them to the array
            for key in levels[levelIndex]["Across"]!.keys {
                acrossNumbers.append(Int(key)!)
            }
            
            for key in levels[levelIndex]["Down"]!.keys {
                downNumbers.append(Int(key)!)
            }
        }
        
        // Sort the arrays from lowest to highest
        acrossNumbers.sort()
        downNumbers.sort()
    }
    
    // Gets the important information from the level array created from JSON.
    func makeClueArrays() {

        // Master clues are used to easily manage hints and clues.
        // Any updates to hints or clues will apply to all phrases
        // without needing to modify each level
        var masterClues = Settings.master
        
        var ac: Dictionary<String, String>
        var dw: Dictionary<String, String>
        
        if Settings.userLevel! >= 1000 {
            let LEVEL_INDEX = levelIndex!

            ac = Settings.dailies[LEVEL_INDEX]["Across"]!
            dw = Settings.dailies[LEVEL_INDEX]["Down"]!
        } else {
            var levelIndex: Int!
            if Settings.userLevel < 200 {
                levelIndex = Settings.userLevel! - 1
            } else if Settings.userLevel >= 200 && Settings.userLevel < 400 {
                levelIndex = Settings.userLevel! - 201
            } else if Settings.userLevel >= 400 && Settings.userLevel < 600 {
                levelIndex = Settings.userLevel! - 401
            }

            ac = levels[levelIndex]["Across"]!
            dw = levels[levelIndex]["Down"]!
        }
        
        for (key, value) in ac {
            for j in 0..<masterClues.count {
                if value == masterClues[j]["Phrase"] {
                    acrossClues.append((String(Int(key)!),
                                        masterClues[j]["Clue"]!,
                                        masterClues[j]["Hint"]!,
                                        masterClues[j]["Num of words"]!))
                }
            }
        }
        
        for (key, value) in dw {
            for j in 0..<masterClues.count {
                if value == masterClues[j]["Phrase"] {
                    downClues.append((String(Int(key)!),
                                        masterClues[j]["Clue"]!,
                                        masterClues[j]["Hint"]!,
                                        masterClues[j]["Num of words"]!))
                }
            }
        }
        
        acrossClues.sort(by: {Int($0.Num)! < Int($1.Num)!})
        downClues.sort(by: {Int($0.Num)! < Int($1.Num)!})
    }
    
    
     /*****************************************
     *                                        *
     *             Utility functions          *
     *                                        *
     *****************************************/
    
    func startTimer() {
        // Start counting how long the user has been on the level
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimerLabel), userInfo: nil, repeats: true)
        
        RunLoop.main.add(gameTimer, forMode: RunLoopMode.commonModes)
    }
    
    @objc func updateTimerLabel() {
        if Settings.highestDailyComplete != Settings.today ||
            Settings.userLevel! < 1000 {
            // Increase the seconds counter every tick
            // At 60, increase the minutes counter
            secondsCounter += 1
            if secondsCounter == 60 {
                secondsCounter = 0
                minutesCounter += 1
            }
            
            // At 60, increase the hours counter
            if minutesCounter == 60 {
                minutesCounter = 0
                hoursCounter += 1
            }
            
            // Display the timer
            let secs = formatter.string(for: secondsCounter)
            let mins = formatter.string(for: minutesCounter)
            
            secondsLabel.text = ":\(secs!)"
            minutesLabel.text = ":\(mins!)"
            hoursLabel.text = "\(hoursCounter)"
            
            if Settings.cheatCount > Int(cheatCountLabel.text!)! {
                let amountChanged = Settings.cheatCount - Int(cheatCountLabel.text!)!
                animateGemChange(amountChanged, true)
                cheatCountLabel.text = "\(Settings.cheatCount)"
            }
            
            // Save the timer every time through
            defaults.set(secondsCounter, forKey: "\(Settings.userLevel!)_seconds")
            defaults.set(minutesCounter, forKey: "\(Settings.userLevel!)_minutes")
            defaults.set(hoursCounter, forKey: "\(Settings.userLevel!)_hours")
        }
    }
    
    var isAnimatingGems = false
    func animateGemChange(_ count: Int, _ increase: Bool) {
        view.layoutIfNeeded()
        gemChangeStack.alpha = 1.0
        let originalTopSpace = gemChangeTopConstraint.constant
        
        if increase {
            gemChangeText.textColor = .green
            gemChangeText.text = "+\(count)"
        } else {
            gemChangeText.textColor = .red
            gemChangeText.text = "-\(count)"
        }
        
        self.gemChangeTopConstraint.constant -= originalTopSpace
        if !isAnimatingGems {
            isAnimatingGems = true
            UIView.animate(withDuration: 1.5, animations: {
                self.view.layoutIfNeeded()
            }) {
                (Void) in
                UIView.animate(withDuration: 0.3, animations: {
                    self.gemChangeStack.alpha = 0
                }) {
                    (Void) in
                    self.isAnimatingGems = false
                    self.gemChangeTopConstraint.constant = originalTopSpace
                }
            }
        }
    }
    
    func readFromDefaults() {
        // If there are saved answers, then we want to display those
        if let savedAnswers = defaults.array(forKey: "\(Settings.userLevel!)_buttonTitles") {
            buttonTitleArray = (savedAnswers as? [String])!
            for i in 0...puzzleSize * puzzleSize - 1 {
                if buttonTitleArray[i] != "" {
                    boardSpaces[i].setTitleWithOutAnimation(title: buttonTitleArray[i])
                }
            }
        } else {
            // Otherwise, start new
            buttonTitleArray = Array(repeating: "", count: puzzleSize * puzzleSize)
        }
        
        // If there are locked answers, then we want to set those
        if let locked = defaults.array(forKey: "\(Settings.userLevel!)_lockedCorrect") {
            buttonLockedForCorrect = (locked as? [Bool])!
        } else {
            // Otherwise, start new
            buttonLockedForCorrect = Array(repeating: false, count: puzzleSize * puzzleSize)
        }
        
        // If there are squares with hints, then we want to display those
        if let acrossHint = defaults.array(forKey: "\(Settings.userLevel!)_hintAcross") {
            buttonHintAcrossEnabled = (acrossHint as? [Bool])!
            for i in 0...puzzleSize * puzzleSize - 1 {
                if buttonHintAcrossEnabled[i] == true {
                    boardSpaces[i].showHintLabel()
                }
            }
        } else {
            // Otherwise, start new
            buttonHintAcrossEnabled = Array(repeating: false, count: puzzleSize * puzzleSize)
        }
        
        // If there are squares with hints, then we want to display those
        if let downHint = defaults.array(forKey: "\(Settings.userLevel!)_hintDown") {
            buttonHintDownEnabled = (downHint as? [Bool])!
            for i in 0...puzzleSize * puzzleSize - 1 {
                if buttonHintDownEnabled[i] == true {
                    boardSpaces[i].showHintLabel()
                }
            }
        } else {
            // Otherwise, start new
            buttonHintDownEnabled = Array(repeating: false, count: puzzleSize * puzzleSize)
        }
        
        // If there are squares revealed, then we want to display those
        if let revealed = defaults.array(forKey: "\(Settings.userLevel!)_revealed") {
            buttonRevealedByHelper = (revealed as? [Bool])!
            for i in 0...puzzleSize * puzzleSize - 1 {
                if buttonRevealedByHelper[i] == true {
                    // Set the background to indicate a cheat was used at that square
                    boardSpaces[i].backgroundColor = UIColor.init(cgColor: orangeColorCG)
                    if buttonTitleArray[i] == "" {
                        // Set the title equal to the correct answer
                        boardSpaces[i].setTitleWithOutAnimation(title: String(buttonLetterArray[i]).uppercased())
                        buttonTitleArray[i] = String(buttonLetterArray[i]).uppercased()
                        
                        // Lock the correct
                        buttonLockedForCorrect[i] = true
                        
                        // Save it into the arrays
                        defaults.set(buttonLockedForCorrect, forKey: "\(Settings.userLevel!)_lockedCorrect")
                        defaults.set(buttonTitleArray, forKey: "\(Settings.userLevel!)_buttonTitles")
                    }
                }
            }
        } else {
            // Otherwise, start new
            buttonRevealedByHelper = Array(repeating: false, count: puzzleSize * puzzleSize)
        }
        
        // Set the timing counters, they are 0 if there is no corresponding key
        secondsCounter = defaults.integer(forKey: "\(Settings.userLevel!)_seconds")
        minutesCounter = defaults.integer(forKey: "\(Settings.userLevel!)_minutes")
        hoursCounter = defaults.integer(forKey: "\(Settings.userLevel!)_hours")
        
        if Settings.highestDailyComplete == Settings.today && Settings.userLevel! >= 1000 {
            for i in 0...puzzleSize * puzzleSize - 1 {
                buttonRevealedByHelper[i] = true
            }
        }

    }
    
    func resetDefaults(_ forLevel: Int) {
        // Set level specific board states back to initial board
        defaults.set(Array(repeating: "", count: puzzleSize * puzzleSize), forKey: "\(forLevel)_buttonTitles")
        defaults.set(Array(repeating: false, count: puzzleSize * puzzleSize), forKey: "\(forLevel)_lockedCorrect")
        
        if forLevel >= 1000 {
            defaults.set(Array(repeating: false, count: puzzleSize * puzzleSize), forKey: "\(forLevel)_hintAcross")
            defaults.set(Array(repeating: false, count: puzzleSize * puzzleSize), forKey: "\(forLevel)_hintDown")
            defaults.set(Array(repeating: false, count: puzzleSize * puzzleSize), forKey: "\(forLevel)_revealed")
        }
        
        defaults.set(0, forKey: "\(forLevel)_seconds")
        defaults.set(0, forKey: "\(forLevel)_minutes")
        defaults.set(0, forKey: "\(forLevel)_hours")
    }
    

    
     /*****************************************
     *                                        *
     *                 Segues                 *
     *                                        *
     *****************************************/
    
    func showGameOverView() {
        // Gave over view has to be presented programmatically because there is no specific
        // button to trigger its segue
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let GOVC = storyboard.instantiateViewController(withIdentifier: "GOVC")
        GOVC.modalTransitionStyle = .crossDissolve
        GOVC.modalPresentationStyle = .overCurrentContext
        self.present(GOVC, animated: true, completion: nil)
    }
    
    func showIAPView() {
        // InAppPurchase view is shown through the user hitting one of the cheat buttons
        // when the user is out of cheats or from the menu.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let IAP = storyboard.instantiateViewController(withIdentifier: "IAP")
        IAP.modalTransitionStyle = .crossDissolve
        IAP.modalPresentationStyle = .overCurrentContext
        self.present(IAP, animated: true, completion: nil)
    }

    var startNewGame = false
    func newLevel() {
        // When the interstitial ad is closed, the next level will display
        startNewGame = true
    
        // Present an ad when going to a new level
        if false && interstitialAd.isReady && !Settings.adsDisabled {
            interstitialAd.present(fromRootViewController: self)
        } else {
            // Will only occur if the ads are disabled
            if startNewGame {
                // Remove the falling animation
                animator.removeAllBehaviors()
                
                // Creates a new board and pushes it onto the navigation stack
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
                vc.levels = self.levels
                
                // Gives a nice animation to the next view
                let transition = CATransition()
                transition.duration = 0.5
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                transition.type = kCATransitionFade
                self.navigationController?.view.layer.add(transition, forKey: nil)
                self.navigationController?.pushViewController(vc, animated: false)
                self.navigationController?.viewControllers.remove(at: (navigationController?.viewControllers.count)! - 2)

                startNewGame = false
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // When the setting button is clicked, give the view information needed
        // to set the switches to their initial positions which can then be modified
        // by the user.
        if segue.identifier == "hintSegue" {
            if let hintVC = segue.destination as? HintViewController {
                hintVC.emoji = getSpotInfo(indexOfButton: indexOfButton, info: "Clue")
                hintVC.wordCount = getSpotInfo(indexOfButton: indexOfButton, info: "WordCt")
                hintVC.hint = getSpotInfo(indexOfButton: indexOfButton, info: "Hint")
                hintVC.clueNumber = directionLabel.text!
                hintVC.screenSize = screenSize
                hintVC.letterCount = String(selectedBoardSpaces.count)
            }
        }
    }
    
    
     /*****************************************
     *                                        *
     *             Load functions             *
     *                                        *
     *****************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interstitialAd = createAndLoadInterstitial()
        ref = Database.database().reference()
        scroller.delegate = self
        clueTable.delegate = self
        clueTable.dataSource = self
        
        // This is the board that needs to be set up
        // board[0] contains the letters in their locations
        // board[1] contains numbers superscripts for across/down
        // board[2] contains across/down information for each individual square
        var board = [String]()
        
        if Settings.userLevel! >= 1000 {
            levelIndex = Settings.userLevel! - 1000

            board = [Settings.dailies[levelIndex]["Board"]!["Letters"]!,
                     Settings.dailies[levelIndex]["Board"]!["Numbers"]!,
                     Settings.dailies[levelIndex]["Board"]!["Properties"]!]
            
            let firstStartIndex = Settings.today.startIndex
            let firstEndIndex = Settings.today.index(firstStartIndex, offsetBy: 4)
            let firstRange = firstStartIndex..<firstEndIndex
            
            let secondStartIndex = Settings.today.index(firstEndIndex, offsetBy: 1)
            let secondEndIndex = Settings.today.index(secondStartIndex, offsetBy: 2)
            let secondRange = secondStartIndex..<secondEndIndex
            
            let thirdStartIndex = Settings.today.index(secondEndIndex, offsetBy: 1)
            let thirdEndIndex = Settings.today.index(thirdStartIndex, offsetBy: 2)
            let thirdRange = thirdStartIndex..<thirdEndIndex
            
            Settings.userLevel = Int("\(Settings.today[firstRange])\(Settings.today[secondRange])\(Settings.today[thirdRange])")
        } else {
            var levelIndex: Int!
            if Settings.userLevel < 200 {
                levelIndex = Settings.userLevel! - 1
            } else if Settings.userLevel >= 200 && Settings.userLevel < 400 {
                levelIndex = Settings.userLevel! - 201
            } else if Settings.userLevel >= 400 && Settings.userLevel < 600 {
                levelIndex = Settings.userLevel! - 401
            }

            board = [levels[levelIndex]["Board"]!["Letters"]!,
                    levels[levelIndex]["Board"]!["Numbers"]!,
                    levels[levelIndex]["Board"]!["Properties"]!]
        }
        
        puzzleSize = Int(sqrt(Double(board[0].count)))
        
        // Set everything up
        formatter.minimumIntegerDigits = 2
        setUpBoard(board: board)

        fillAcrossDownArrays()
        makeClueArrays()
        startTimer()
        
        // Start playing game music
        // Select a random track between 1 and 24
        let random = arc4random_uniform(24) + 1
        MusicPlayer.start(musicTitle: "game_\(random)", ext: "mp3")
        if !Settings.musicEnabled {
            MusicPlayer.gameMusicPlayer.volume = 0
        }
        
        animator = UIDynamicAnimator(referenceView: self.view)
        
        // Initialize from defaults
        readFromDefaults()
        clueAreaSetup()
        
        if defaults.bool(forKey: "helpShownBefore") {
            animateGameStart()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Begins animation when coming from background
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.gameViewController = self
        
        // Help screen should show first time the user plays
        // If they want to display it again, its available in the menu
        if !defaults.bool(forKey: "helpShownBefore") {
            helpSetupAndDisplay()
        }
        
        if !inGame {
            // Our initial tap
            initialHighlight()
            determineAllCorrect()
            inGame = true
        }
    }
    
    var gameStarted = false
    var counter = 0
    var boardFillsScrollView = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !gameStarted {
            theBoardHeight.constant = CGFloat(38 * puzzleSize)
            theBoardWidth.constant = CGFloat(38 * puzzleSize)
            let height = theBoardHeight.constant
            let width = theBoardWidth.constant
            
            if scroller.frame.height > height {
                boardFillsScrollView = true
                theBoardHeight.constant = scroller.frame.height - 20
                theBoardWidth.constant = scroller.frame.height - 20
                scrollingDisabled = true
            }

            scroller.minimumZoomScale = min((scroller.frame.height / height), (scroller.frame.width / width)) - 0.019
            scroller.maximumZoomScale = 2
            gameStarted = true

        }
        
        if boardFillsScrollView {
            scroller.panGestureRecognizer.isEnabled = false
            scroller.pinchGestureRecognizer?.isEnabled = false
        } else {
            scroller.panGestureRecognizer.isEnabled = true
            scroller.pinchGestureRecognizer?.isEnabled = true
        }

        //Keeps highlighted word border from breaking
        if counter < 2 {
            boardSpaces[indexOfButton].sendActions(for: .touchUpInside)
            boardSpaces[indexOfButton].sendActions(for: .touchUpInside)
            counter += 1
            
            var offset: CGFloat = 0.0
            if scroller.zoomScale - 0.05 < scroller.minimumZoomScale {
                offset = 5.0
            }
            
            let offsetX = max((scroller.bounds.width - scroller.contentSize.width) * 0.5, 0) - offset
            let offsetY = max((scroller.bounds.height - scroller.contentSize.height) * 0.5, 0) - offset

            scroller.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
        }
    }
    
    /*****************************************
     *                                        *
     *              Ad functions              *
     *                                        *
     *****************************************/
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
            boardLeading.constant = 200
            boardTrailing.constant = 200
        } else {
            boardLeading.constant = 20
            boardTrailing.constant = 20

        }
    }
    
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitialAd = createAndLoadInterstitial()
        if across {
            if indexOfButton < puzzleSize * puzzleSize - 1 {
                boardSpaces[indexOfButton! + 1].sendActions(for: .touchUpInside)
                boardSpaces[indexOfButton! - 1].sendActions(for: .touchUpInside)
            } else {
                boardSpaces[indexOfButton! - 1].sendActions(for: .touchUpInside)
                boardSpaces[indexOfButton! + 1].sendActions(for: .touchUpInside)
            }

            across = true
        } else {
            if indexOfButton > puzzleSize - 1 &&
                boardSpaces[indexOfButton - puzzleSize].isEnabled {
                boardSpaces[indexOfButton! - puzzleSize].sendActions(for: .touchUpInside)
                boardSpaces[indexOfButton! + puzzleSize].sendActions(for: .touchUpInside)
            } else {
                boardSpaces[indexOfButton! + puzzleSize].sendActions(for: .touchUpInside)
                boardSpaces[indexOfButton! - puzzleSize].sendActions(for: .touchUpInside)
            }

            across = false
        }
        
        if startNewGame {
            // Remove the falling animation
            animator.removeAllBehaviors()
            
            // Creates a new board and pushes it onto the navigation stack
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
            
            // Gives a nice animation to the next view
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade
            self.navigationController?.view.layer.add(transition, forKey: nil)
            
            self.navigationController?.pushViewController(vc, animated: false)
            
            startNewGame = false
        }
        
        if Settings.musicEnabled {
            MusicPlayer.gameMusicPlayer.setVolume(0.2, fadeDuration: 0.3)
        }
    }
    
    func checkAdProgress() {
        // Ad shows if:
        // 1. Ready to show
        // 2. The ad counter has hit the number allowed before it should show
        // 3. The user hasn't filled all the squares (interferes with game over)
        // 4. The user has not purchased the removal of ads
        shouldShowAdCounter += 1
        if interstitialAd.isReady && shouldShowAdCounter % showAdAfterNumCorrect == 0
            && !allSquaresFilled() && !Settings.adsDisabled {
            if Settings.musicEnabled {
                GADMobileAds.sharedInstance().applicationVolume = 0.2
                GADMobileAds.sharedInstance().applicationMuted = false
            } else {
                GADMobileAds.sharedInstance().applicationVolume = 0.0
                GADMobileAds.sharedInstance().applicationMuted = true
            }
            interstitialAd.present(fromRootViewController: self)
            MusicPlayer.gameMusicPlayer.setVolume(0, fadeDuration: 0.3)
        }
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-1164601417724423/5546885166")
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "fed0f7a57321fadf217b2e53c6dac938", "845b935a0aad6fa7bbc613bea329c30a"]
        interstitial.delegate = self
        interstitial.load(request)
        return interstitial
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return theBoard
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView,
                                          with view: UIView?,
                                          atScale scale: CGFloat) {
        scrollView.contentSize = CGSize(width: scrollView.contentSize.width + (15 * scale), height: scrollView.contentSize.height + (15 * scale))
        
        if scrollView.zoomScale - 0.07 < scrollView.minimumZoomScale {
            scrollingDisabled = true
            scrollView.panGestureRecognizer.isEnabled = false
        } else {
            scrollingDisabled = false
            scrollView.panGestureRecognizer.isEnabled = true
        }

    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var offset: CGFloat = 0.0
        
        if scrollView.zoomScale - 0.05 < scrollView.minimumZoomScale {
            offset = 5.0
        }
        
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0) - offset
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0) - offset

        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}

extension UIControl {
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let inside = super.point(inside: point, with: event)
        if inside != isHighlighted && event?.type == .touches {
            isHighlighted = inside
        }
        return inside
    }
}

extension UIView {
    // Used to fade in a view
    // Used in help screens
    func fadeIn(withDuration duration: Double) {
        UIView.animate(withDuration: duration, animations: {
            () -> Void in
            
            self.alpha = 1
            
            })
    }
    
    // Spins the UI view
    func rotate360Degrees(duration: CFTimeInterval) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = 0
        self.layer.add(rotateAnimation, forKey: nil)
    }
    
    func grow(duration: CFTimeInterval) {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.duration = duration
        pulse.repeatCount = 0
        pulse.fromValue = 0
        pulse.toValue = 1
        self.layer.add(pulse, forKey: nil)
    }
}

extension GameViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return acrossClues.count
        } else {
            return downClues.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var clue: (Num: String, Clue: String, Hint: String, WordCt: String)

        if indexPath.section == 0 {
            clue = acrossClues[indexPath.row]
        } else {
            clue = downClues[indexPath.row]
        }
        

        let cell = tableView.dequeueReusableCell(withIdentifier: "ClueCell") as! ClueCell
        cell.setNumber(clue.Num)
        cell.setClue(clue.Clue)
        if correctClues.contains(clue.Clue) {
            cell.backgroundColor = UIColor.init(red: 73/255, green: 222/255, blue: 124/255, alpha: 1)
        } else {
            cell.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 241/255, alpha: 1)
        }
        cell.selectionStyle = .none
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Across"
        } else {
            return "Down"
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Geeza Pro Regular", size: 18.0)
        header.textLabel?.textAlignment = NSTextAlignment.center
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var spotToFind = ""
        var arr = [String]()
        
        if indexPath.section == 0 {
            let num = acrossClues[indexPath.row].Num
            if Int(num)! < 10 {
                spotToFind.append("0\(num)a")
            } else {
                spotToFind.append("\(num)a")
            }
            arr = buttonAcrossArray
        } else {
            let num = downClues[indexPath.row].Num
            if Int(num)! < 10 {
                spotToFind.append("0\(num)d")
            } else {
                spotToFind.append("\(num)d")
            }
            arr = buttonDownArray
        }
        
        for i in 0...arr.count - 1 {
            if spotToFind == arr[i] {
                boardSpaces[i].sendActions(for: .touchUpInside)
                break
            }
        }
        
        if indexPath.section == 0 {
            if !across {
                boardSpaces[indexOfButton].sendActions(for: .touchUpInside)
            }
        } else {
            if across {
                boardSpaces[indexOfButton].sendActions(for: .touchUpInside)
            }
        }
    }
}
