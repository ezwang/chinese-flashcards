//
//  DeckDetailViewController.swift
//  ChineseFlashcards
//
//  Created by Eric Wang on 4/17/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit
import FirebaseFirestore

class DeckDetailViewController: UIViewController, EditDeckDelegate {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDescription: UITextView!
    @IBOutlet weak var segmentQuizFrom: UISegmentedControl!
    @IBOutlet weak var segmentQuizTo: UISegmentedControl!
    @IBOutlet weak var segmentQuizMethod: UISegmentedControl!
    
    var deck : Deck?
    var cardController : CardViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        updateDeckDisplay()
        
        // style description box
        labelDescription.layer.borderWidth = 1
        labelDescription.layer.borderColor = UIColor.lightGray.cgColor
        labelDescription.layer.cornerRadius = 5
        
        segmentQuizFrom.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "quizFromValue")
        segmentQuizTo.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "quizToValue")
        segmentQuizMethod.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "quizMethodValue")
    }
    
    func updateDeckDisplay() {
        labelName.text = deck?.name
        labelDescription.text = deck?.description
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
        
        UserDefaults.standard.set(segmentQuizFrom.selectedSegmentIndex, forKey: "quizFromValue")
    }
    
    @IBAction func onToValueChange(_ sender: Any) {
        UserDefaults.standard.set(segmentQuizTo.selectedSegmentIndex, forKey: "quizToValue")
    }
    
    @IBAction func onMethodChange(_ sender: Any) {
        UserDefaults.standard.set(segmentQuizMethod.selectedSegmentIndex, forKey: "quizMethodValue")
    }
    
    func onEdit(id: String) {
        Firestore.firestore().collection("decks").document(id).getDocument {
            document, error in
            if let document = document {
                self.deck = Deck.fromFirebase(document)
                DispatchQueue.main.async {
                    self.updateDeckDisplay()
                    self.cardController?.setCards(self.deck?.cards ?? [])
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "card" {
            if let controller = segue.destination as? CardViewController {
                if let realDeck = deck {
                    cardController = controller
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
                        controller.quizType = QuizType.init(rawValue: segmentQuizMethod.selectedSegmentIndex) ?? .random
                    }
                }
            }
        }
        else if segue.identifier == "edit" {
            if let controller = segue.destination as? EditDeckViewController {
                if let realDeck = deck {
                    controller.deck = realDeck
                    controller.delegate = self
                }
            }
        }
    }
}
