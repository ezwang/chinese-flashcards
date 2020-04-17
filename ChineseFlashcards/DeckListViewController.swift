//
//  DeckListViewController.swift
//  ChineseFlashcards
//
//  Created by Eric Wang on 4/17/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class DeckListViewController: UITableViewController {
    var decks : [Deck] = []
    var deckListener : ListenerRegistration?
    
    override func viewWillAppear(_ animated: Bool) {
        let db = Firestore.firestore()
        let userId =  Auth.auth().currentUser?.uid ?? "public"
        self.deckListener = db.collection("decks").whereField("owner", isEqualTo: userId).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return
            }
            self.decks = snapshot.documents.map { doc -> Deck in
                let data = doc.data()
                let rawCards = data["cards"] as? [NSDictionary] ?? []
                let cards = rawCards.map { card -> Card in
                    return Card(character: card["character"] as? String ?? "", meaning: card["meaning"] as? String ?? "", pinyin: card["pinyin"] as? String ?? "")
                }
                return Deck(id: doc.documentID, name: data["name"] as? String ?? "", description: data["description"] as? String ?? "", cards: cards)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let listener = deckListener {
            listener.remove()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deckCell")!
        
        cell.textLabel?.text = decks[indexPath.row].name
        cell.detailTextLabel?.text = decks[indexPath.row].description
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "deckDetail", sender: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "deckDetail" {
            if let row = sender as? Int {
                if let controller = segue.destination as? DeckDetailViewController {
                    controller.deck = decks[row]
                }
            }
        }
    }
}
