//
//  DatabaseRequirements.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 12/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

typealias DatabaseRequirements = TodoItemDetailViewDbAPI

protocol TodoItemDetailViewDbAPI {
    
    func saveTodoItem(_ todoItem: TodoItem, to taskType: TaskType, execute: Execute)
    
    func deleteTodoItem(_ todoItem: TodoItem, atIndex index: Int, from taskType: TaskType,
                        execute: Execute)
    
    func updateTodoItem(_ todoItem: TodoItem)
    
    func createListPosition(forDocumentID documentID: String, for taskType: TaskType, batch: WriteBatch)
    
    func updateTodoListPositions(positions: [String], positionChange: [String: Int]?,
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
                                    taskType: TaskType,
                                    isSortOperation: Bool)
    
    func todoItemListViewDbDelegate(didAddTodoItem newTodoItem: TodoItem,
                                    taskType: TaskType)
    
    func todoItemListViewDbDelegate(didDeleteTodoItem deletedTodoItem: TodoItem,
                                    taskType: TaskType)
    
    func todoItemListViewDbDelegate(didUpdateTodoItem updatedTodoItem: TodoItem,
                                    taskType: TaskType)
}

protocol DeviceTokenManager {
    func storeDeviceToken(token: String, forPlatform platform: AppViewModel.Platform)
}
