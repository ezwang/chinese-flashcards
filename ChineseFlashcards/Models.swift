//
//  Models.swift
//  ChineseFlashcards
//
//  Created by Eric Wang on 4/17/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation

struct Card {
    var character : String
    var meaning : String
    var pinyin : String
}

struct Deck {
    var id : String
    var name : String
    var description : String
    var cards : [Card]
}

enum CardType: String, CaseIterable {
    case meaning = "Meaning"
    case character = "Character"
    case pinyin = "Pinyin"
}