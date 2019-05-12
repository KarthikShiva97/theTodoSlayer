//
//  TodoItem.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 09/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import RealmSwift

class TodoItem: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var notes = ""
    
    convenience init(name: String, notes: String) {
        self.init()
        self.name = name
        self.notes = notes
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
