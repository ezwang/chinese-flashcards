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

extension UIView {
    @IBInspectable var borderRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.masksToBounds = true
            layer.cornerRadius = newValue
        }
    }
}

func extractDictionaryData() {
    if let filepath = Bundle.main.path(forResource: "dictionary", ofType: "txt") {
        do {
            let data = try String(contentsOfFile: filepath, encoding: .utf8)
            print(data)
        }
        catch {
            print("Error loading dictionary file! Path: \(filepath)")
        }
    }
}
