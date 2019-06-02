
//
//  TodoEntryViewModel.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 12/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

enum TaskEntryFailure {
    case taskNameMissing
}

enum ListOperation: String {
    case add
    case delete
    case update
    case reorder
}

enum TaskPriority: Int {
    case high
    case medium
    case low
    
    func getName() -> String {
        switch self {
        case .high:
            return "High Priority"
        case .medium:
            return "Medium Priority"
        case .low:
            return "Low Priority"
        }
    }
    
    var color: UIColor {
        switch self {
        case .high:
            return #colorLiteral(red: 0.8156862745, green: 0.007843137255, blue: 0.1058823529, alpha: 0.8)
        case .medium:
            return #colorLiteral(red: 0.9607843137, green: 0.6509803922, blue: 0.137254902, alpha: 0.8)
        case .low:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8)
        }
    }
}

protocol TodoEntryViewModelDelegate: class {
    func handleFailure(_ failure: TaskEntryFailure)
    func didCompleteOperation(_ operation: ListOperation)
}

class TodoEntryViewModel {
    
    weak var delegate: TodoEntryViewModelDelegate!
    
    private let remoteDatabase: TodoItemDetailViewDbAPI = {
        return FirebaseLayer()
    }()
    
    var taskName: String?
    var taskNotes: String = ""
    var taskPriority: TaskPriority = .low
    
    init(delegate: TodoEntryViewModelDelegate) {
        self.delegate = delegate
    }
}

// MARK:- Public API's
extension TodoEntryViewModel {
    func addTodoItem() {
        guard let taskName = taskName, self.taskName?.isEmpty == false else {
            delegate?.handleFailure(.taskNameMissing)
            return
        }
        let todoItem = TodoItem(name: taskName, notes: taskNotes, priority: taskPriority)
        remoteDatabase.saveTodoItem(todoItem)
        delegate.didCompleteOperation(.add)
    }
    
    func deleteTodoItem(_ todoItem: TodoItem, atIndexPath indexPath: IndexPath) {
        remoteDatabase.deleteTodoItem(todoItem, atIndex: indexPath.row)
        delegate.didCompleteOperation(.delete)
    }
    
    func updateTodoItem(_ todoItem: TodoItem) {
        remoteDatabase.updateTodoItem(todoItem)
        delegate.didCompleteOperation(.update)
    }
}

private extension TodoEntryViewModel {
    
}
