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

class TransitionSegue : UIStoryboardSegue {
    override func perform() {
        var viewControllers = self.source.navigationController?.viewControllers ?? []
        _ = viewControllers.popLast()
        viewControllers.append(self.destination)
        self.source.navigationController?.setViewControllers(viewControllers, animated: true)
    }
}

extension UIView {
    @IBInspectable var borderRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.masksToBounds = true
            layer.cornerRadius = newValue
        }
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

class QuizViewController: UIViewController {
    var deck : Deck?
    var cardQueue : [Card] = []
    var maxCount : Int = 1
    var answerShown : Bool = false
    
    @IBOutlet weak var labelProgress: UILabel!
    @IBOutlet weak var barProgress: UIProgressView!
    @IBOutlet weak var labelAnswer: UIButton!
    @IBOutlet weak var labelQuestion: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        if let realDeck = deck {
            cardQueue = realDeck.cards
            cardQueue.shuffle()
            maxCount = cardQueue.count
        }
        
        updateProgress()
    }
    
    func updateProgress() {
        labelProgress.text = "\(cardQueue.count)/\(maxCount) Cards Reviewed"
        barProgress.setProgress(1 - Float(cardQueue.count) / Float(maxCount), animated: true)
        
        if let card = getCard() {
            // TODO: allow customization for this
            labelQuestion.text = card.character
            labelAnswer.setTitle("Show Answer", for: .normal)
            labelAnswer.backgroundColor = UIColor.systemIndigo
            labelAnswer.setTitleColor(UIColor.systemBackground, for: .normal)
            answerShown = false
        }
        else {
            performSegue(withIdentifier: "done", sender: nil)
        }
    }
    
    func getCard() -> Card? {
        return cardQueue.last
    }
    
    @IBAction func onShow(_ sender: Any) {
        if let card = getCard() {
            // TODO: allow customization for this
            labelAnswer.setTitle(card.meaning, for: .normal)
            labelAnswer.backgroundColor = UIColor.systemBackground
            labelAnswer.setTitleColor(UIColor.label, for: .normal)
            answerShown = true
        }
    }
    
    @IBAction func onNo(_ sender: Any) {
        // if the answer is shown, continue and mark as no
        if (answerShown) {
            _ = cardQueue.popLast()
            updateProgress()
        }
        else {
            // show the answer otherwise
            onShow(sender)
        }
    }
    
    @IBAction func onYes(_ sender: Any) {
        _ = cardQueue.popLast()
        updateProgress()
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
    
    @IBAction func onQuiz(_ sender: Any) {
        performSegue(withIdentifier: "quiz", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "card" {
            if let controller = segue.destination as? CardViewController {
                if let realDeck = deck {
                    controller.cards = realDeck.cards
                }
            }
        }
        else if segue.identifier == "quiz" {
            if let controller = segue.destination as? QuizViewController {
                if let realDeck = deck {
                    controller.deck = realDeck
                }
            }
        }
    }
}

class EditDeckViewController: UIViewController {
    @IBOutlet weak var fieldName: UITextField!
    @IBOutlet weak var fieldDescription: UITextView!
    
    var cardController : CardViewController?
    
    @IBAction func onSave(_ sender: UIBarButtonItem) {
        let db = Firestore.firestore()
        db.collection("decks").document().setData([
            "name": self.fieldName.text ?? "",
            "description": self.fieldDescription.text ?? "",
            "owner": Auth.auth().currentUser?.uid ?? "public",
            "cards": cardController?.cards.map { card -> NSDictionary in
                return [
                    "meaning": card.meaning,
                    "character": card.character,
                    "pinyin": card.pinyin
                ]
                } ?? []
        ])
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
            }
        }
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

