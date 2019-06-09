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
    
    var todoItemsPositions = [String]() {
        didSet {
            createIndexPathDocumentIDMap()
        }
    }
    
    var todoItems = [TodoItem]() {
        didSet {
            createDocumentIDTodoItemMap()
        }
    }
    
    var indexPathDocumentIDMap = [IndexPath: String]()
    var documentIDTodoItemMap = [String: TodoItem]()
    
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
        indexPathDocumentIDMap = [:]
        documentIDTodoItemMap = [:]
    }
    
    func deleteTodoItem(withDocumentID documentID: String) {
        documentIDTodoItemMap[documentID] = nil
    }
    
}

extension TodoListVCModel {
    
    private func createIndexPathDocumentIDMap() {
        // Index Path Document ID map is created from todoItemPositions
        // If the latter is empty, former should also be empty
        guard self.todoItemsPositions.isEmpty == false else {
            indexPathDocumentIDMap = [:]
            return
        }
        
        var indexPathDocumentIDMap = [IndexPath: String]()
        
        for index in 0...(todoItemsPositions.count - 1) {
            let indexPath = IndexPath(row: index, section: 0)
            let documentID = todoItemsPositions[index]
            indexPathDocumentIDMap[indexPath] = documentID
        }
        
        self.indexPathDocumentIDMap = indexPathDocumentIDMap
    }
    
    private func createDocumentIDTodoItemMap() {
        var documentIDTodoItemMap = [String: TodoItem]()
        self.todoItems.forEach { (todoItem) in
            documentIDTodoItemMap[todoItem.documentID] = todoItem
        }
        self.documentIDTodoItemMap = documentIDTodoItemMap
    }
}
