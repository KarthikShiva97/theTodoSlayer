//
//  DatabaseRequirements.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 12/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation

typealias DatabaseRequirements = TodoItemDetailViewDbAPI

protocol TodoItemDetailViewDbAPI {
    
    func saveTodoItem(_ todoItem: TodoItem, to taskType: TaskType)
    
    func deleteTodoItem(_ todoItem: TodoItem, atIndex index: Int, from taskType: TaskType,
                        onCompletion: @escaping didComplete)
    
    func updateTodoItem(_ todoItem: TodoItem)
    
    func createListPosition(forDocumentID documentID: String, for taskType: TaskType)
    
    func updateTodoListPositions(positions: [String], positionChange: [String: Int],
                                 taskType: TaskType)
    
    func clearLastPositionChanges()
}

protocol TodoItemListViewDbAPI: class {
    var todoItemListViewDelegate: TodoItemListViewDbDelegate? {get set}
}

protocol TodoItemListViewDbDelegate: class {
    
    func todoItemPositionDidChange(from sourceIndex: Int, to destinationIndex: Int,
                                   taskType: TaskType)
    
    func didDeletePositionForTodoItem(atIndex index: Int,
                                      taskType: TaskType)
    
    func todoItemListViewDbDelegate(positions: [String],
                                    taskType: TaskType)
    
    func todoItemListViewDbDelegate(didAddTodoItem newTodoItem: TodoItem,
                                    taskType: TaskType)
    
    func todoItemListViewDbDelegate(didDeleteTodoItem deletedTodoItem: TodoItem,
                                    taskType: TaskType)
    
    func todoItemListViewDbDelegate(didUpdateTodoItem updatedTodoItem: TodoItem,
                                    taskType: TaskType)
}
