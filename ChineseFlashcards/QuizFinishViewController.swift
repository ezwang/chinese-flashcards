//
//  QuizFinishViewController.swift
//  ChineseFlashcards
//
//  Created by Eric Wang on 4/17/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import UIKit

class QuizFinishViewController: UIViewController {
    @IBOutlet weak var labelReviewed: UILabel!
    @IBOutlet weak var labelSuccess: UILabel!
    @IBOutlet weak var labelTries: UILabel!
    
    var results : QuizResults?
    
    override func viewWillAppear(_ animated: Bool) {
        if let results = results {
            labelReviewed.text = "\(results.numCards)"
            let percent = results.numSuccess * 100 / results.numCards
            labelSuccess.text = "\(percent)%"
            if percent >= 75 {
                labelSuccess.textColor = UIColor.systemGreen
            }
            else if percent >= 50 {
                labelSuccess.textColor = UIColor.systemYellow
            }
            else {
                labelSuccess.textColor = UIColor.systemRed
            }
            let tries = Double(results.numTries) / Double(results.numOriginalCards)
            labelTries.text = "\(String(format: "%.1f", tries))"
            if tries > 3 {
                labelTries.textColor = UIColor.systemRed
            }
            else if tries > 2 {
                labelTries.textColor = UIColor.systemYellow
            }
            else {
                labelTries.textColor = UIColor.systemGreen
            }
        }
    }
    
    @IBAction func onBack(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
