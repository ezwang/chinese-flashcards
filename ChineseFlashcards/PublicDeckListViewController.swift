//
//  PublicDeckListViewController.swift
//  ChineseFlashcards
//
//  Created by Eric Wang on 4/19/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit
import FirebaseFirestore

class PublicDeckListViewController : UITableViewController {
    var decks : [Deck] = []
    var deckListener : ListenerRegistration?
    
    override func viewWillAppear(_ animated: Bool) {
        let db = Firestore.firestore()

        self.deckListener = db.collection("decks").whereField("public", isEqualTo: true).addSnapshotListener {
            querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return
            }
            self.decks = snapshot.documents.map(Deck.fromFirebase)
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "deckCell")!
        
        cell.textLabel?.text = decks[indexPath.row].name
        cell.detailTextLabel?.text = decks[indexPath.row].description
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decks.count
    }
}
