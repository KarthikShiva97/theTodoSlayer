
//
//  TodoEntryViewModel.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 12/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import RealmSwift

enum TaskEntryFailure {
    case taskNameMissing
}

protocol TodoEntryViewModelDelegate: class {
    func handleFailure(_ failure: TaskEntryFailure)
    func didAddTask()
}

class TodoEntryViewModel {
    
    weak var delegate: TodoEntryViewModelDelegate!
    
    private let database: TodoItemEntryDbAPI = {
        return RealmLayer()
    }()
    
    var taskName: String?
    var taskNotes = String()
    
    init(delegate: TodoEntryViewModelDelegate) {
        self.delegate = delegate
    }
}

// MARK:- Public API's
extension TodoEntryViewModel {
    func addTask() {
        guard let taskName = taskName, self.taskName?.isEmpty == false else {
            delegate?.handleFailure(.taskNameMissing)
            return
        }
        let todoItem = TodoItem(name: taskName, notes: taskNotes)
        database.saveTodoItem(todoItem)
        delegate.didAddTask()
    }
}

private extension TodoEntryViewModel {
    
}
