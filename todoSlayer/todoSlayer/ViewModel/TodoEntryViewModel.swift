
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
    case sort
}

enum TaskType: CaseIterable {
    case pending
    case completed
}

extension TaskType {
    static func forEachDo(_ closure: (TaskType)->()) {
        TaskType.allCases.forEach { (taskType) in
            closure(taskType)
        }
    }
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
        
        let onCompletion: ((Bool) -> ()) = { didComplete in
            self.delegate?.didCompleteOperation(.add)
        }
        
        let todoItem = TodoItem(name: taskName, notes: taskNotes, priority: taskPriority, reminderDateTime: nil)
        remoteDatabase.saveTodoItem(todoItem, to: .pending, execute: .operation(onCompletion))
        
    }
    
    func deleteTodoItem(_ todoItem: TodoItem, atIndexPath indexPath: IndexPath) {
        
        let index = indexPath.row
        let taskType = todoItem.taskType
        
        let onCompletion: ((Bool) -> ()) = { didComplete in
            self.delegate?.didCompleteOperation(.delete)
        }
        
        remoteDatabase.deleteTodoItem(todoItem, atIndex: index,
                                      from: taskType,
                                      execute: .operation(onCompletion))
        
    }
    
    func updateTodoItem(_ todoItem: TodoItem) {
        remoteDatabase.updateTodoItem(todoItem)
        delegate?.didCompleteOperation(.update)
    }
    
}

private extension TodoEntryViewModel {
    func setDueDate(_ date: Date, for todoItem: TodoItem) {
        
    }
}
