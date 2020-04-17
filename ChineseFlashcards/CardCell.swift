//
//  CardCell.swift
//  ChineseFlashcards
//
//  Created by Eric Wang on 4/17/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit

class CardCell : UITableViewCell {
    @IBOutlet weak var labelCharacter: UILabel!
    @IBOutlet weak var labelPinyin: UILabel!
    @IBOutlet weak var labelMeaning: UILabel!
    @IBOutlet weak var constraintCharacter: NSLayoutConstraint!
    
    func setCard(card: Card) {
        self.labelCharacter.text = card.character
        self.labelPinyin.text = formatPinyin(card.pinyin)
        self.labelMeaning.text = card.meaning
        
        // resize character label to be number of characters
        let numChars = self.labelCharacter.text?.count ?? 0
        self.constraintCharacter.constant = CGFloat(min(numChars, 6) * 35)
    }
}
