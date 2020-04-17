//
//  CardViewController.swift
//  ChineseFlashcards
//
//  Created by Eric Wang on 4/17/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit

class CardViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var cardView: UITableView!
    @IBOutlet weak var fieldNew: UITextField!
    
    var cards : [Card] = []
    
    @IBAction func onAdd(_ sender: Any) {
        if let text = fieldNew.text {
            // TODO: properly handle character/meaning/pinyin retrieval
            cards.append(Card(character: text, meaning: text, pinyin: text))
        }
        cardView.reloadData()
        fieldNew.text = ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "card")!
        
        // TODO: properly render character/meaning/pinyin
        cell.textLabel?.text = cards[indexPath.row].character
        cell.detailTextLabel?.text = cards[indexPath.row].meaning
        
        return cell
    }
    
    override func viewDidLoad() {
        cardView.delegate = self
        cardView.dataSource = self
        cardView.register(UITableViewCell.self, forCellReuseIdentifier: "card")
    }
}
