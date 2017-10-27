//
//  BoardButton.swift
//  Crossword
//
//  Created by Tyler Stickler on 10/26/17.
//  Copyright © 2017 tstick. All rights reserved.
//

import UIKit

class BoardButton: UIButton {
    var phrase: String?
    var clue: String?
    var hint: String?
    var letter: Character?
    var across: String!
    var down: String!
    var superscriptLabel = UILabel()
    
    var cons = [NSLayoutConstraint]()
    
    
    func setSuperScriptLabel(number: String) {

        self.addSubview(superscriptLabel)
        superscriptLabel.translatesAutoresizingMaskIntoConstraints = false
        superscriptLabel.text = number
        superscriptLabel.font = superscriptLabel.font.withSize(7)
        
        cons.append(NSLayoutConstraint(item: self.superscriptLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 1))

        cons.append(NSLayoutConstraint(item: self.superscriptLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 1))

        NSLayoutConstraint.activate(cons)
    }
}
