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

typealias DatabaseRequirements = ItemListViewService & ItemDetailViewService & DeviceTokenService & LoginService

protocol ItemListViewService: class {
    var todoItemListViewDelegate: ItemListViewServiceDelegate? { get set }
}

protocol ItemListViewServiceDelegate: class {
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

protocol ItemDetailViewService {
    func saveTodoItem(_ todoItem: TodoItem, to taskType: TaskType, execute: Execute)
    
    func deleteTodoItem(_ todoItem: TodoItem, atIndex index: Int, from taskType: TaskType,
                        execute: Execute)
    
    func updateTodoItem(_ todoItem: TodoItem)
    
    func createListPosition(forDocumentID documentID: String, for taskType: TaskType, batch: WriteBatch)
    
    func updateTodoListPositions(positions: [String], positionChange: [String: Int]?,
                                 taskType: TaskType)
    
    func clearLastPositionChanges()
}

protocol DeviceTokenService {
    func storeDeviceToken(token: String, underUserID userID: String)
}

protocol LoginService {
    func storeUser(_ userJSON: [String: Any], userID: String)
    func doesUserExist(withID userID: String, onCompletion: @escaping (Bool)->())
}
