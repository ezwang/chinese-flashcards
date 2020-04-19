//
//  EditDeckViewController.swift
//  ChineseFlashcards
//
//  Created by Eric Wang on 4/17/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol EditDeckDelegate {
    func onEdit(id: String)
}

class EditDeckViewController: UIViewController {
    @IBOutlet weak var fieldName: UITextField!
    @IBOutlet weak var fieldDescription: UITextView!
    @IBOutlet weak var switchPublic: UISwitch!
    
    var cardController : CardViewController?
    var deck : Deck?
    var delegate : EditDeckDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        if let deck = deck {
            fieldName.text = deck.name
            fieldDescription.text = deck.description
            switchPublic.isOn = deck.isPublic
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if deck != nil {
            delegate?.onEdit(id: doSave())
        }
    }
    
    func doSave() -> String {
        let db = Firestore.firestore()
        let deckDocument = deck != nil ? db.collection("decks").document(deck?.id ?? ""
            ) : db.collection("decks").document()
        deckDocument.setData([
            "name": self.fieldName.text ?? "",
            "description": self.fieldDescription.text ?? "",
            "owner": Auth.auth().currentUser?.uid ?? "public",
            "public": switchPublic.isOn,
            "cards": cardController?.cards.map { card -> NSDictionary in
                return [
                    "meaning": card.meaning,
                    "character": card.character,
                    "pinyin": card.pinyin
                ]
                } ?? []
        ])
        return deckDocument.documentID
    }
    
    @IBAction func onSave(_ sender: UIBarButtonItem) {
        if self.fieldName.text?.count ?? 0 == 0 {
            let alert = UIAlertController(title: "Error", message: "You must enter a name for your flash card deck!", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        _ = doSave()

        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        // add in border to uitextview so user knows it is editable
        fieldDescription.layer.borderWidth = 1
        fieldDescription.layer.borderColor = UIColor.lightGray.cgColor
        fieldDescription.layer.cornerRadius = 5
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "card" {
            if let controller = segue.destination as? CardViewController {
                self.cardController = controller
                if let deck = deck {
                    controller.cards = deck.cards
                    controller.deckId = deck.id
                }
            }
        }
    }
}
