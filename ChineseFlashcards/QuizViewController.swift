//
//  QuizViewController.swift
//  ChineseFlashcards
//
//  Created by Eric Wang on 4/17/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {
    var deck : Deck?
    var cardQueue : [Card] = []
    var maxCount : Int = 1
    var answerShown : Bool = false
    var fromType : CardType = .character
    var toType : CardType = .pinyin
    
    var successCount : Int = 0
    var failureCount : Int = 0
    
    @IBOutlet weak var labelProgress: UILabel!
    @IBOutlet weak var barProgress: UIProgressView!
    @IBOutlet weak var labelAnswer: UIButton!
    @IBOutlet weak var labelQuestion: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        if let realDeck = deck {
            cardQueue = realDeck.cards
            cardQueue.shuffle()
            maxCount = cardQueue.count
        }
        
        labelQuestion.adjustsFontSizeToFitWidth = true
        labelAnswer.titleLabel?.adjustsFontSizeToFitWidth = true
        
        successCount = 0
        failureCount = 0
        
        updateProgress()
    }
    
    func updateProgress() {
        labelProgress.text = "\(maxCount - cardQueue.count)/\(maxCount) Cards Reviewed"
        barProgress.setProgress(1 - Float(cardQueue.count) / Float(maxCount), animated: true)
        
        if let card = getCard() {
            switch fromType {
            case .character:
                labelQuestion.text = card.character
            case .meaning:
                labelQuestion.text = card.meaning
            case .pinyin:
                labelQuestion.text = formatPinyin(card.pinyin)
            }
            labelAnswer.setTitle("Show Answer", for: .normal)
            labelAnswer.backgroundColor = UIColor.systemIndigo
            labelAnswer.setTitleColor(UIColor.systemBackground, for: .normal)
            answerShown = false
        }
        else {
            performSegue(withIdentifier: "done", sender: nil)
        }
    }
    
    func getCard() -> Card? {
        return cardQueue.last
    }
    
    @IBAction func onShow(_ sender: Any) {
        if let card = getCard() {
            switch toType {
            case .character:
                labelAnswer.setTitle(card.character, for: .normal)
            case .meaning:
                labelAnswer.setTitle(card.meaning, for: .normal)
            case .pinyin:
                labelAnswer.setTitle(formatPinyin(card.pinyin), for: .normal)
            }
            labelAnswer.backgroundColor = UIColor.systemBackground
            labelAnswer.setTitleColor(UIColor.label, for: .normal)
            answerShown = true
        }
    }
    
    @IBAction func onNo(_ sender: Any) {
        // if the answer is shown, continue and mark as no
        if (answerShown) {
            failureCount += 1
            _ = cardQueue.popLast()
            updateProgress()
        }
        else {
            // show the answer otherwise
            onShow(sender)
        }
    }
    
    @IBAction func onYes(_ sender: Any) {
        successCount += 1
        _ = cardQueue.popLast()
        updateProgress()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "done" {
            if let controller = segue.destination as? QuizFinishViewController {
                controller.results = QuizResults(numCards: maxCount, numSuccess: successCount, numTries: successCount + failureCount)
            }
        }
    }
}
