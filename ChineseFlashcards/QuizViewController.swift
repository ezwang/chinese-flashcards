//
//  QuizViewController.swift
//  ChineseFlashcards
//
//  Created by Eric Wang on 4/17/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit

protocol ReviewAlgorithm {
    func onYes()
    func onNo()
    func addCards(cards: [Card])
    func getCard() -> Card?
    func getCardCount() -> Int
}

class RandomAlgorithm : ReviewAlgorithm {
    var cardQueue : [Card] = []
    var maxCardCount : Int = 0
    
    func onYes() {
        _ = cardQueue.popLast()
    }
    
    func onNo() {
        _ = cardQueue.popLast()
    }
    
    func addCards(cards: [Card]) {
        cardQueue.append(contentsOf: cards)
        maxCardCount += cards.count
        cardQueue.shuffle()
    }
    
    func getCard() -> Card? {
        return cardQueue.last
    }
    
    func getCardCount() -> Int {
        return maxCardCount
    }
}

class AppendAlgorithm : ReviewAlgorithm {
    var cardQueue : [Card] = []
    var maxCardCount : Int = 0
    
    func onYes() {
        _ = cardQueue.popLast()
    }
    
    func onNo() {
        if let card = cardQueue.popLast() {
            cardQueue.insert(card, at: 0)
            maxCardCount += 1
        }
    }
    
    func addCards(cards: [Card]) {
        cardQueue.append(contentsOf: cards)
        maxCardCount += cards.count
        cardQueue.shuffle()
    }
    
    func getCard() -> Card? {
        return cardQueue.last
    }
    
    func getCardCount() -> Int {
        return maxCardCount
    }
}

class WaterfallAlgorithm : ReviewAlgorithm {
    var piles : [[Card]] = [[]]
    var currentPile : Int = 0
    var currentIterator : Int = 0
    var maxCardCount : Int = 0
    
    func onYes() {
        nextCard()
    }
    
    func onNo() {
        let card = piles[currentPile][currentIterator]
        if piles.count <= currentPile + 1 {
            piles.append([])
            maxCardCount += piles[currentPile].count
        }
        piles[currentPile + 1].append(card)
        maxCardCount += 1
        nextCard()
    }
    
    func nextCard() {
        currentIterator += 1
        if currentIterator >= piles[currentPile].count {
            currentIterator = 0
            if piles.count <= currentPile + 1 {
                currentPile -= 1
                _ = piles.popLast()
            }
            else {
                currentPile += 1
            }
        }
    }
    
    func addCards(cards: [Card]) {
        piles[0].append(contentsOf: cards)
        piles[0].shuffle()
        maxCardCount += cards.count
    }
    
    func getCard() -> Card? {
        if (currentPile < 0) {
            return nil
        }
        return piles[currentPile][currentIterator]
    }
    
    func getCardCount() -> Int {
        return maxCardCount
    }
}

class QuizViewController: UIViewController {
    var deck : Deck?
    var maxCount : Int = 1
    var answerShown : Bool = false
    var fromType : CardType = .character
    var toType : CardType = .pinyin
    
    var successCount : Int = 0
    var failureCount : Int = 0
    var numOriginal : Int = 0
    
    var quizType : QuizType = .random
    var algorithm : ReviewAlgorithm?
    
    @IBOutlet weak var labelProgress: UILabel!
    @IBOutlet weak var barProgress: UIProgressView!
    @IBOutlet weak var labelAnswer: UIButton!
    @IBOutlet weak var labelQuestion: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        switch quizType {
        case .waterfall:
            algorithm = WaterfallAlgorithm()
        case .append:
            algorithm = AppendAlgorithm()
        default:
            algorithm = RandomAlgorithm()
        }
        
        if let realDeck = deck {
            algorithm?.addCards(cards: realDeck.cards)
            maxCount = algorithm?.getCardCount() ?? 1
            numOriginal = realDeck.cards.count
        }
        
        labelQuestion.adjustsFontSizeToFitWidth = true
        labelAnswer.titleLabel?.adjustsFontSizeToFitWidth = true
        
        successCount = 0
        failureCount = 0
        
        updateProgress()
    }
    
    func updateProgress() {
        maxCount = algorithm?.getCardCount() ?? 1
        labelProgress.text = "\(successCount + failureCount)/\(maxCount) Cards Reviewed"
        barProgress.setProgress(Float(successCount + failureCount) / Float(maxCount), animated: true)
        
        if let card = algorithm?.getCard() {
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
    
    @IBAction func onShow(_ sender: Any) {
        if let card = algorithm?.getCard() {
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
        if (answerShown || !UserDefaults.standard.bool(forKey: "useShowAnswer")) {
            failureCount += 1
            algorithm?.onNo()

            updateProgress()
        }
        else {
            // show the answer otherwise
            onShow(sender)
        }
    }
    
    @IBAction func onYes(_ sender: Any) {
        successCount += 1
        algorithm?.onYes()
        updateProgress()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "done" {
            if let controller = segue.destination as? QuizFinishViewController {
                controller.results = QuizResults(numCards: maxCount, numSuccess: successCount, numTries: numOriginal + failureCount, numOriginalCards: numOriginal)
            }
        }
    }
}
