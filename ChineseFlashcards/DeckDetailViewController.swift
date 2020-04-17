//
//  DeckDetailViewController.swift
//  ChineseFlashcards
//
//  Created by Eric Wang on 4/17/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit
import FirebaseFirestore

class DeckDetailViewController: UIViewController {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDescription: UITextView!
    @IBOutlet weak var segmentQuizFrom: UISegmentedControl!
    @IBOutlet weak var segmentQuizTo: UISegmentedControl!
    
    var deck : Deck?
    
    override func viewWillAppear(_ animated: Bool) {
        labelName.text = deck?.name
        labelDescription.text = deck?.description
        
        // style description box
        labelDescription.layer.borderWidth = 1
        labelDescription.layer.borderColor = UIColor.lightGray.cgColor
        labelDescription.layer.cornerRadius = 5
    }
    
    @IBAction func onDelete(_ sender: Any) {
        let dialog = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this deck?", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .destructive, handler: { (action) -> Void in
            let db = Firestore.firestore()
            if let realDeck = self.deck {
                db.collection("decks").document(realDeck.id).delete()
            }
            self.dismiss(animated: true, completion: nil)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        dialog.addAction(ok)
        dialog.addAction(cancel)
        
        self.present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func onQuiz(_ sender: Any) {
        performSegue(withIdentifier: "quiz", sender: nil)
    }
    
    @IBAction func onFromValueChange(_ sender: Any) {
        let fromValue = segmentQuizFrom.titleForSegment(at: segmentQuizFrom.selectedSegmentIndex)
        switch fromValue {
        case "Character":
            segmentQuizTo.setTitle("Pinyin", forSegmentAt: 0)
            segmentQuizTo.setTitle("Meaning", forSegmentAt: 1)
        case "Pinyin":
            segmentQuizTo.setTitle("Character", forSegmentAt: 0)
            segmentQuizTo.setTitle("Meaning", forSegmentAt: 1)
        default:
            segmentQuizTo.setTitle("Character", forSegmentAt: 0)
            segmentQuizTo.setTitle("Pinyin", forSegmentAt: 1)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "card" {
            if let controller = segue.destination as? CardViewController {
                if let realDeck = deck {
                    controller.deckId = realDeck.id
                    controller.cards = realDeck.cards
                }
            }
        }
        else if segue.identifier == "quiz" {
            if let navigationController = segue.destination as? UINavigationController {
                if let controller = navigationController.topViewController as? QuizViewController {
                    if let realDeck = deck {
                        controller.deck = realDeck
                        controller.fromType = CardType.init(rawValue: segmentQuizFrom.titleForSegment(at: segmentQuizFrom.selectedSegmentIndex) ?? "Character") ?? .character
                        controller.toType = CardType.init(rawValue: segmentQuizTo.titleForSegment(at: segmentQuizTo.selectedSegmentIndex) ?? "Pinyin") ?? .pinyin
                    }
                }
            }
        }
    }
}
