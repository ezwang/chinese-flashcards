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
import SQLite

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

extension Card {
    static func fromFirebase(_ card : NSDictionary) -> Card {
        return Card(character: card["character"] as? String ?? "", meaning: card["meaning"] as? String ?? "", pinyin: card["pinyin"] as? String ?? "")
    }
}

extension Deck {
    static func fromFirebase(_ doc : DocumentSnapshot) -> Deck {
        if let data = doc.data() {
            let rawCards = data["cards"] as? [NSDictionary] ?? []
            let cards = rawCards.map(Card.fromFirebase)
            return Deck(
                id: doc.documentID,
                name: data["name"] as? String ?? "",
                description: data["description"] as? String ?? "",
                isPublic: data["public"] as? Bool ?? false,
                cards: cards
            )
        }
        return Deck(id: "", name: "", description: "", isPublic: false, cards: [])
    }
}

func getDatabase() throws -> Connection {
    let dbPath = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("dictionary.sqlite3").absoluteString
    return try Connection(dbPath)
}

struct NaverResponse : Codable {
    var items : [[[[String]]]]
}

func searchCharacterOnline(search: String, callback: @escaping ([Card]) -> Void) {
    let str = "https://ac.dict.naver.com/linedictweb/ac?q=\(search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&st=011&r_lt=000&q_enc=UTF-8&r_format=json&r_enc=UTF-8"
    if let url = URL(string: str) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                do {
                    let resp = try decoder.decode(NaverResponse.self, from: data)
                    let pinyinResults = resp.items[1]
                    let cards = pinyinResults.map { (chr: [[String]]) -> Card in
                        let character : String = chr[2][0]
                        let meaning : String = chr[3][0]
                        let pinyin : String = chr[4][0]
                        return Card(character: character.trimmingCharacters(in: .whitespacesAndNewlines), meaning: meaning.trimmingCharacters(in: .whitespacesAndNewlines), pinyin: pinyin.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    callback(cards)
                }
                catch {
                    print("Failed to decode search response: \(error)")
                }
            }
            else if let error = error {
                print("Error occured when executing search query: \(error)")
            }
            else {
                print("Unknown error occured when executing search query")
            }
        }.resume()
    }
    else {
        print("Could not create search URL: \(str)")
    }
}

func searchCharacter(search: String) -> [Card] {
    if let db = try? getDatabase() {
        let modSearch = "%\(search)%"
        if let result = try? db.prepare("SELECT character, meaning, pinyin FROM dictionary WHERE character LIKE ? OR meaning LIKE ? OR pinyin LIKE ? ORDER BY LENGTH(character) LIMIT 25").run([modSearch, modSearch, modSearch]) {
            let results = result.enumerated().map {row in
                return Card(character: row.element[0] as? String ?? "", meaning: row.element[1] as? String ?? "", pinyin: row.element[2] as? String ?? "")
            }
            return results.sorted(by: { a, b in a.character.count < b.character.count })
        }
    }
    return []
}

func getAccent(char: String, tone: Int) -> String? {
    let lookup = [
        "a": ["ā", "á", "ǎ", "à", "a"],
        "e": ["ē", "é", "ě", "è", "e"],
        "i": ["ī", "í", "ǐ", "ì", "i"],
        "o": ["ō", "ó", "ǒ", "ò", "o"],
        "u": ["ū", "ú", "ǔ", "ù", "u"]
    ]
    if let arr = lookup[char] {
        if tone > 0 && tone < arr.count {
            return arr[tone]
        }
    }
    return nil
}

func formatPinyin(_ input: String) -> String {
    if let regex = try? NSRegularExpression(pattern: "(?<char>[aeiou])(?<diff>[^aeiou]*?)(?<tone>\\d)", options: .caseInsensitive) {
        let nsInput = input as NSString
        var output : [String] = []
        var index = input.startIndex
        for match in regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.count)) {
            let char = nsInput.substring(with: match.range(withName: "char"))
            let diff = nsInput.substring(with: match.range(withName: "diff"))
            let lower = input.index(input.startIndex, offsetBy: match.range.lowerBound)
            output.append(String(input[index..<lower]))
            if let tone = Int(nsInput.substring(with: match.range(withName: "tone"))) {
                if let accent = getAccent(char: char, tone: tone) {
                    output.append(accent)
                }
                else {
                    output.append(char)
                }
            }
            else {
                output.append(char)
            }
            index = input.index(input.startIndex, offsetBy: match.range.upperBound)
            output.append(diff)
        }
        output.append(String(input[index...]))
        return output.joined()
    }
    return input.lowercased()
}

func extractDictionaryData() {
    do {
        let db = try getDatabase()
        try db.execute("PRAGMA encoding='UTF-8'")
        try db.execute("CREATE TABLE IF NOT EXISTS dictionary (character TEXT, pinyin TEXT, meaning TEXT);")
        
        let numEntries = try db.scalar("SELECT COUNT(*) FROM dictionary") as? Int64 ?? 0
        
        // if we've already created the database, return
        if numEntries > 0 {
            return
        }
        
        // regex for parsing the dictionary file
        let regex = try NSRegularExpression(pattern: "^(.*?)\\s+(?<character>.*?)\\s+\\[(?<pinyin>.*?)\\]\\s+/(?<meaning>.*?)/", options: .caseInsensitive)
        
        // read the text file into the database
        if let filepath = Bundle.main.path(forResource: "dictionary", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: filepath, encoding: .utf8)
                for line in data.components(separatedBy: .newlines) {
                    if line.starts(with: "#") {
                        continue
                    }
                    let nsLine = line as NSString
                    if let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.count)) {
                        let character = nsLine.substring(with: match.range(withName: "character"))
                        let meaning = nsLine.substring(with: match.range(withName: "meaning"))
                        let pinyin = nsLine.substring(with: match.range(withName: "pinyin"))
                        
                        try db.prepare("INSERT INTO dictionary (character, meaning, pinyin) VALUES (?, ?, ?)").run([character, meaning, pinyin])
                    }
                }
            }
            catch {
                print("Error loading dictionary file! Path: \(filepath)")
            }
        }
    }
    catch {
        print("Error setting up the SQLite database!")
    }
}
