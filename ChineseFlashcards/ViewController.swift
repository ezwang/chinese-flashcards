//
//  ViewController.swift
//  ChineseFlashcards
//
//  Created by Eric Wang on 4/12/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

func getErrorMessage(code: Int) -> String {
    let errCode = FirebaseAuth.AuthErrorCode(rawValue: code)
    switch errCode {
    case .invalidEmail:
        return "Invalid email address."
    case .wrongPassword:
        return "Wrong email or password."
    case .emailAlreadyInUse:
        return "Email is already in use."
    case .weakPassword:
        return "Password is too weak."
    default:
        return "An unknown authentication error occured."
    }
}

class RootSegue : UIStoryboardSegue {
    override func perform() {
        self.source.navigationController?.setViewControllers([self.destination], animated: true)
    }
}

struct Card {
    var character : String
    var meaning : String
    var pinyin : String
}

struct Deck {
    var id : String
    var name : String
    var description : String
    var cards : [Card]
}

class DeckListViewController: UITableViewController {
    var decks : [Deck] = []
    var deckListener : ListenerRegistration?
    
    override func viewWillAppear(_ animated: Bool) {
        let db = Firestore.firestore()
        self.deckListener = db.collection("decks").whereField("owner", isEqualTo: Auth.auth().currentUser?.uid ?? "public").addSnapshotListener { querySnapshot, error in
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

class DeckDetailViewController: UIViewController {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDescription: UITextView!
    
    var deck : Deck?

    override func viewWillAppear(_ animated: Bool) {
        labelName.text = deck?.name
        labelDescription.text = deck?.description
    }
    
    @IBAction func onDelete(_ sender: Any) {
        let db = Firestore.firestore()
        if let realDeck = deck {
            db.collection("decks").document(realDeck.id).delete()
        }
        self.dismiss(animated: true, completion: nil)
    }
}

class EditDeckViewController: UIViewController {
    @IBOutlet weak var fieldName: UITextField!
    @IBOutlet weak var fieldDescription: UITextView!
    
    @IBAction func onSave(_ sender: UIBarButtonItem) {
        let db = Firestore.firestore()
        db.collection("decks").document().setData([
            "name": self.fieldName.text ?? "",
            "description": self.fieldDescription.text ?? "",
            "owner": Auth.auth().currentUser?.uid ?? "public",
            "cards": []
        ])
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        // add in border to uitextview so user knows it is editable
        fieldDescription.layer.borderWidth = 1
        fieldDescription.layer.borderColor = UIColor.lightGray.cgColor
        fieldDescription.layer.cornerRadius = 5
    }
}

class RegisterViewController: UIViewController {
    @IBOutlet weak var fieldEmail: UITextField!
    @IBOutlet weak var fieldPassword: UITextField!
    
    
    @IBAction func registerClicked(button: UIButton)
    {
        Auth.auth().createUser(withEmail: fieldEmail.text ?? "", password: fieldEmail.text ?? "") { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if let e = error {
                let errorMessage = getErrorMessage(code: e._code)
                
                let alert = UIAlertController(title: "Registration Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                strongSelf.present(alert, animated: true, completion: nil)
            }
            else if authResult != nil {
                strongSelf.performSegue(withIdentifier: "deck", sender: nil)
            }
        }
    }
}

class LogoViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "deck", sender: nil)
        }
    }
}

class LoginViewController: UIViewController {
    @IBOutlet weak var fieldEmail: UITextField!
    @IBOutlet weak var fieldPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginClicked(button: UIButton) {
        Auth.auth().signIn(withEmail: fieldEmail.text ?? "", password: fieldPassword.text ?? "") { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if let e = error {
                let errorMessage = getErrorMessage(code: e._code)
                
                let alert = UIAlertController(title: "Login Error", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                strongSelf.present(alert, animated: true, completion: nil)
            }
            else if authResult != nil {
                strongSelf.performSegue(withIdentifier: "deck", sender: nil)
            }
        }
    }
}

