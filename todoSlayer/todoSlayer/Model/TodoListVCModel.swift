//
//  TodoListVCModel.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 08/06/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation

class TodoListVCModel {
    
    let taskType: TaskType
    var todoItemsPositions = [String]()
    var todoItems = [TodoItem]() {
        didSet {
            guard oldValue != todoItems else { return }
            sortByPosition()
        }
    }
    
    // This refers to the last positions moved on the list
    var lastSourceIndex: Int = 0
    var lastDestinationIndex: Int = 0
    
    var indexPathToDelete: IndexPath?
    
    init(taskType: TaskType) {
        self.taskType = taskType
    }
    
}

extension TodoListVCModel {
    
    func clearData() {
        todoItemsPositions = []
        todoItems = []
    }
    
    func deleteTodoItem(withDocumentID documentID: String) {
        todoItems.removeAll { (todoItem) -> Bool in
            todoItem.documentID == documentID
        }
    }
    
    func sortByPosition() {
        guard todoItemsPositions.count == todoItems.count else {
            Logger.log(reason: "Cannot sort! Count mismatch!")
            return
        }
        todoItems.sort { (todoItem1, todoItem2) -> Bool in
            let item1ID = todoItem1.documentID
            let item2ID = todoItem2.documentID
            return todoItemsPositions.firstIndex(of: item1ID)! < todoItemsPositions.firstIndex(of: item2ID)!
        }
    }
}
