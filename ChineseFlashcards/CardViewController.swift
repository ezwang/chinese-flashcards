//
//  CardViewController.swift
//  ChineseFlashcards
//
//  Created by Eric Wang on 4/17/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit
import FirebaseFirestore

class CardViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CharacterDelegate {
    
    @IBOutlet weak var cardView: UITableView!
    @IBOutlet weak var btnAddCard: UIButton!
    
    var cards : [Card] = []
    var deckId : String?
    var isReadOnly : Bool = false
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "card")!
        
        (cell as? CardCell)?.setCard(card: cards[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let card = cards.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // if editing, delete card in firestore
            if let did = deckId {
                Firestore.firestore().collection("decks").document(did).updateData([
                    "cards": FieldValue.arrayRemove([card.dict])
                ])
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func viewDidLoad() {
        cardView.delegate = self
        cardView.dataSource = self
        
        let nib = UINib.init(nibName: "CardCell", bundle: nil)
        cardView.register(nib, forCellReuseIdentifier: "card")
        
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.lightGray.cgColor
        cardView.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        btnAddCard.isEnabled = !isReadOnly
    }
    
    @IBAction func onAdd(_ sender: Any) {
        performSegue(withIdentifier: "character", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "character" {
            if let view = segue.destination as? CharacterViewController {
                view.delegate = self
            }
        }
    }
    
    func addCharacter(card: Card) {
        cards.append(card)
        cardView.reloadData()
        
        // if editing, add card to firestore
        if let did = deckId {
            Firestore.firestore().collection("decks").document(did).updateData(["cards": FieldValue.arrayUnion([card.dict])])
        }
    }
    
    func setCards(_ newCards: [Card]) {
        self.cards = newCards
        cardView.reloadData()
    }
}
