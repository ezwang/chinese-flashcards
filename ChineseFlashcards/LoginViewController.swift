//
//  LoginViewController.swift
//  ChineseFlashcards
//
//  Created by Eric Wang on 4/17/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit
import FirebaseAuth

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
