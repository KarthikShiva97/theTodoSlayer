//
//  TodoItem.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 09/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import Firebase

enum TodoItemSection {
    case zero
}

class TodoItem {
    let ID: String
    private (set) var documentID = String()
    var name: String
    var notes: String
    var priority: TaskPriority
    var isCompleted: Bool
    var reminderDateTime: String?
    
    var taskType: TaskType {
        return isCompleted ? .completed : .pending
    }
    
    // MARK:- Creating Locally
    init(name: String, notes: String, priority: TaskPriority, reminderDateTime: String?) {
        self.ID = UUID().uuidString
        self.name = name
        self.notes = notes
        self.priority = priority
        self.isCompleted = false
        self.reminderDateTime = nil
    }
    
    // MARK:- Reconstructing from JSON
    init?(json: [String: Any]) {
        guard let ID = json[Constants.ID] as? String,
            let name = json[Constants.name] as? String,
            let notes = json[Constants.notes] as? String,
            let documentID = json[Constants.documentID] as? String,
            let priority =  TaskPriority(rawValue: json[Constants.priority] as? Int ?? -1),
            let isCompleted = json[Constants.isCompleted] as? Bool ,
            let reminderDateTime = json[Constants.reminderDateTime] as? String else {
                print("Failed to convert JSON to Todo Item! JSON -> \(json)")
                return nil
        }
        self.ID = ID
        self.documentID = documentID
        self.name = name
        self.notes = notes
        self.priority = priority
        self.isCompleted = isCompleted
        self.reminderDateTime = reminderDateTime
    }
    
    struct Constants {
        static let ID = "ID"
        static let documentID = "documentID"
        static let name = "name"
        static let notes = "notes"
        static let priority = "priority"
        static let isCompleted = "isCompleted"
        static let reminderDateTime = "reminderDateTime"
    }
}

extension TodoItem : Equatable {
    static func == (lhs: TodoItem, rhs: TodoItem) -> Bool {
        return lhs.ID == rhs.ID
    }
}

// MARK:- Setters
extension TodoItem {
    func setDocumentID(_ documentID: String) {
        self.documentID = documentID
    }
}

extension TodoItem {
    var json: [String: Any] {
        let jsonArray: [String : Any] = [
            TodoItem.Constants.ID: ID,
            TodoItem.Constants.name: name,
            TodoItem.Constants.notes: notes,
            TodoItem.Constants.documentID: documentID,
            TodoItem.Constants.priority: priority.rawValue,
            TodoItem.Constants.isCompleted: isCompleted,
            TodoItem.Constants.reminderDateTime: reminderDateTime as Any]
        return jsonArray.filter { (key, value) -> Bool in
            return jsonArray[key] != nil
        }
    }
}


extension TodoItem: CustomDebugStringConvertible {
    var debugDescription: String {
        return
        """
        NAME:-> \(name)
        DocumentID: -> \(documentID)
        Priority:-> \(priority)
        isCompleted:-> \(isCompleted)
        ReminderDateTime:-> \(reminderDateTime)
        """
    }
}
