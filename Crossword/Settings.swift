//
//  Settings.swift
//  Crossword
//
//  Created by Tyler Stickler on 11/13/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class Settings {
    // Settings the user can modify to their preferences
    static var musicEnabled: Bool!
    static var soundEffects: Bool!
    static var showTimer: Bool!
    static var skipFilledSquares: Bool!
    static var lockCorrect: Bool!
    static var correctAnim: Bool!
    static var autoscroll: Bool!
    static var launchedBefore: Bool!
    static var cheatCount = 0
    static var adsDisabled: Bool!
    static var userLevel: Int!
    static var maxNumOfLevels: Int!
    static var completedLevels = [Int]()
    static var uncompletedLevels = [Int]()
    static var newLevels = [Int]()
    static var newLevels18 = [Int]()
    static var newLevels23 = [Int]()
    static var lockedLevels = [Int]()
    static var gatheredData: Bool!
    static var highestDailyComplete: String!
    static var today: String!
    static var dailiesCompleted: Int!
    static var uniqueID: String!
    static var ref: DatabaseReference!
    
    static var master = [Dictionary<String, String>]()
    static var levels = [Dictionary<String, Dictionary<String, String>>]()
    static var levels18 = [Dictionary<String, Dictionary<String, String>>]()
    static var levels23 = [Dictionary<String, Dictionary<String, String>>]()
    static var dailies = [Dictionary<String, Dictionary<String, String>>]()

}
