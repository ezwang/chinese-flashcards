//
//  RegisterViewController.swift
//  ChineseFlashcards
//
//  Created by Eric Wang on 4/17/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit
import FirebaseAuth

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
