
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

enum Operation: String {
    case add
    case delete
    case update
    case reorder
}

protocol TodoEntryViewModelDelegate: class {
    func handleFailure(_ failure: TaskEntryFailure)
    func didCompleteOperation(_ operation: Operation)
}

class TodoEntryViewModel {
    
    weak var delegate: TodoEntryViewModelDelegate!
    
    private let remoteDatabase: TodoItemDetailViewDbAPI = {
        return FirebaseLayer()
    }()
    
    var taskName: String?
    var taskNotes: String = ""
    
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
        let todoItem = TodoItem(name: taskName, notes: taskNotes)
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
