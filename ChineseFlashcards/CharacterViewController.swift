//
//  CharacterViewController.swift
//  ChineseFlashcards
//
//  Created by Eric Wang on 4/17/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit

protocol CharacterDelegate {
    func addCharacter(card: Card)
}

class CharacterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var results : [Card] = []
    var delegate : CharacterDelegate?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var characterView: UITableView!
    
    override func viewDidLoad() {
        characterView.delegate = self
        characterView.dataSource = self
        searchBar.delegate = self
        let nib = UINib.init(nibName: "CardCell", bundle: nil)
        characterView.register(nib, forCellReuseIdentifier: "card")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "card")!
        
        (cell as? CardCell)?.setCard(card: results[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.addCharacter(card: results[indexPath.row])
        dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.results = searchCharacter(search: searchText)
        characterView.reloadData()
    }
}
