//
//  TodoItem.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 09/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import RealmSwift

class TodoItem {
    @objc dynamic var ID: String = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var notes = ""
    @objc dynamic var documentID = ""
    
    convenience init(name: String, notes: String) {
        self.init()
        self.name = name
        self.notes = notes
    }
    
    convenience init?(json: [String: Any]) {
        self.init()
        guard let ID = json[Constants.ID] as? String,
            let name = json[Constants.name] as? String,
            let notes = json[Constants.notes] as? String,
            let documentID = json[Constants.documentID] as? String else {
                print("Failed to convert JSON to Todo Item! JSON -> \(json)")
                return nil
        }
        self.ID = ID
        self.name = name
        self.notes = notes
        self.documentID = documentID
    }
    
    struct Constants {
        static let name = "name"
        static let ID = "ID"
        static let notes = "notes"
        static let documentID = "documentID"
    }
}

extension TodoItem {
    var json: [String: Any] {
        return [ TodoItem.Constants.ID: ID,
                 TodoItem.Constants.name: name,
                 TodoItem.Constants.notes: notes,
                 TodoItem.Constants.documentID: documentID]
    }
}
