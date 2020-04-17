//
//  CardViewController.swift
//  ChineseFlashcards
//
//  Created by Eric Wang on 4/17/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit

class CardCell : UITableViewCell {
    @IBOutlet weak var labelCharacter: UILabel!
    @IBOutlet weak var labelPinyin: UILabel!
    @IBOutlet weak var labelMeaning: UILabel!
    @IBOutlet weak var constraintCharacter: NSLayoutConstraint!
}

class CardViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var cardView: UITableView!
    @IBOutlet weak var fieldNew: UITextField!
    
    var cards : [Card] = []
    
    @IBAction func onAdd(_ sender: Any) {
        if let text = fieldNew.text {
            // TODO: properly handle character/meaning/pinyin retrieval
            let results = searchCharacter(search: text)
            if results.count > 0 {
                results.forEach { card in cards.append(card) }
            }
        }
        cardView.reloadData()
        fieldNew.text = ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "card")!
        
        if let cardCell = cell as? CardCell {
            cardCell.labelCharacter.text = cards[indexPath.row].character
            cardCell.labelPinyin.text = formatPinyin(cards[indexPath.row].pinyin)
            cardCell.labelMeaning.text = cards[indexPath.row].meaning
            cardCell.constraintCharacter.constant = CGFloat((cardCell.labelCharacter.text?.count ?? 0) * 35)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func viewDidLoad() {
        cardView.delegate = self
        cardView.dataSource = self
    }
}
