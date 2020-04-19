//
//  SettingsViewController.swift
//  ChineseFlashcards
//
//  Created by Eric Wang on 4/18/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsViewController : UIViewController {
    @IBOutlet weak var switchOffline: UISwitch!
    @IBOutlet weak var switchShowAnswer: UISwitch!

    @IBAction func onLogout(_ sender: Any) {
        try? Auth.auth().signOut()
        performSegue(withIdentifier: "logout", sender: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        switchOffline.isOn = UserDefaults.standard.bool(forKey: "useOffline")
        switchShowAnswer.isOn = UserDefaults.standard.bool(forKey: "useShowAnswer")
    }
    
    @IBAction func onOfflineToggle(_ sender: Any) {
        UserDefaults.standard.set(switchOffline.isOn, forKey: "useOffline")
    }
    
    @IBAction func onShowAnswerToggle(_ sender: Any) {
        UserDefaults.standard.set(switchShowAnswer.isOn, forKey: "useShowAnswer")
    }
    
    @IBAction func onDeleteAll(_ sender: Any) {
        let dialog = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete ALL of your flash card decks?", preferredStyle: .alert)
        
        dialog.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) -> Void in
            if let uid = Auth.auth().currentUser?.uid {
                Firestore.firestore().collection("decks").whereField("owner", isEqualTo: uid).getDocuments {
                    (querySnapshot, error) in
                    if let documents = querySnapshot?.documents {
                        for document in documents {
                            Firestore.firestore().collection("decks").document(document.documentID).delete()
                        }
                    }
                }
                
                let alert = UIAlertController(title: "Decks Deleted", message: "All decks have been deleted.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        
        dialog.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(dialog, animated: true, completion: nil)
    }
}
