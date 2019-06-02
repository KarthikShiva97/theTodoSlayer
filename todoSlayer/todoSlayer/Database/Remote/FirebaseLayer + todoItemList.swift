//
//  FirebaseLayer + todoItemList.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 18/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import FirebaseFirestore


fileprivate var allTodoItemsEventListener: ListenerRegistration!
fileprivate var todoItemListPositionEventListener: ListenerRegistration!

fileprivate var isInitialTodoItemsFetch = true
fileprivate var isInitialListViewPositionsFetch = true

extension FirebaseLayer: TodoItemListViewDbAPI {
    
    func getTodoItemListPositions(onCompletion: @escaping (Result<[String], TodoItemListViewDbAPIError>)->()) {
        
        let path = firebase.document(listMetaPath)
        path.getDocument { (snapshot, error) in
            
            let errorMsg = "Failed to get to-do item list positions!"
            
            if let error = error {
                Logger.log(reason: errorMsg)
                return onCompletion(.failure(.generalError(error)))
            }
            
            guard let snapshotData = snapshot?.data() else {
                Logger.log(reason: "\(errorMsg) Snapshot data is nil!")
                return onCompletion(.failure(.nilSnapshot))
            }
            
            guard let positions = snapshotData[ListConstants.Meta.positions] as? [String] else {
                Logger.log(reason: "\(errorMsg). Failed to typecast !")
                return onCompletion(.failure(.typecastFailed))
            }
            
            return onCompletion(.success(positions))
        }
        
    }
    
    func getAllTodoItems(onCompletion: @escaping (Result<[TodoItem], TodoItemListViewDbAPIError>)->()) {
        let path = firebase.collection(pendingTasksPath)
        path.getDocuments { (snapshot, error) in
            
            let errorMsg = "Failed to get to-do items!"
            
            if let error = error {
                Logger.log(reason: errorMsg)
                return onCompletion(.failure(.generalError(error)))
            }
            
            guard let snapshot = snapshot else {
                Logger.log(reason: "\(errorMsg) Snapshot data is nil!")
                return onCompletion(.failure(.nilSnapshot))
            }
            
            let todoItems = snapshot.documents.compactMap({ (document) in
                return TodoItem(json: document.data())
            })
            
            return onCompletion(.success(todoItems))
        }
        
    }
    
    
    func attachListenerForAllTodoItems() {
        
        isInitialTodoItemsFetch = true
        
        let pathToListen = firebase.collection(pendingTasksPath)
        allTodoItemsEventListener = pathToListen.addSnapshotListener { (snapshot, error) in
            
            if let error = error {
                Logger.log(error)
                return
            }
            
            guard let snapshot = snapshot else {
                Logger.log(.nilSnapshot)
                return
            }
            
            guard isInitialTodoItemsFetch == false else {
                isInitialTodoItemsFetch = false
                return
            }
            
            snapshot.documentChanges.forEach{ (change)  in
                
                guard let todoItem = TodoItem(json: change.document.data()) else {
                    Logger.log(reason: "failed to convert JSON to todoItem!")
                    return
                }
                
                if change.type == .added {
                    self.todoItemListViewDelegate?.todoItemListViewDbDelegate(didAddTodoItem: todoItem)
                }
                
                if change.type == .removed {
                    self.todoItemListViewDelegate?.todoItemListViewDbDelegate(didDeleteTodoItem: todoItem)
                }
                
                if change.type == .modified {
                    self.todoItemListViewDelegate?.todoItemListViewDbDelegate(didUpdateTodoItem: todoItem)
                }
                
            }
        }
    }
    
    #warning("Refactor this function!")
    func attachListenerForTodoItemListPositions() {
        
        isInitialListViewPositionsFetch = true
        
        let pathToListen = firebase.document(listMetaPath)
        todoItemListPositionEventListener = pathToListen.addSnapshotListener() { (snapshot, error) in
            
            guard isInitialListViewPositionsFetch == false else {
                isInitialListViewPositionsFetch = false
                return
            }
            
            if let error = error {
                Logger.log(error)
                return
            }
            
            guard let snapshotData = snapshot?.data() else {
                Logger.log(.nilSnapshot)
                return
            }
            
            guard let lastOperationAsString = snapshotData[ListConstants.Meta.lastOperation] as? String else {
                Logger.log(.typecastFailed)
                return
            }
            
            guard let lastOperation = ListOperation(rawValue: lastOperationAsString) else {
                Logger.log(.typecastFailed, reason: "Cannot get back lastOperation as enum!")
                return
            }
            
            guard let positions = snapshotData[ListConstants.Meta.positions] as? [String] else {
                Logger.log(.typecastFailed, reason: "Failed to get list positions!")
                return
            }
            
            self.todoItemListViewDelegate?.todoItemListViewDbDelegate(positions: positions)
            
            guard [ListOperation.delete, ListOperation.reorder].contains(lastOperation) else { return }
            
            guard let lastOperationMeta = snapshotData[ListConstants.Meta.lastOperationMeta] as? [String: Any] else {
                Logger.log(reason: "Failed to get Operation Meta!")
                return
            }
            
            if lastOperation == .delete {
                let lastRemovedIndexKey = ListConstants.Meta.LastOperationMeta.lastRemovedIndex
                guard let lastRemovedIndex = lastOperationMeta[lastRemovedIndexKey] as? Int else {
                    Logger.log(reason: "Failed to get last removed index position!")
                    return
                }
                self.todoItemListViewDelegate?.didDeletePositionForTodoItem(atIndex: lastRemovedIndex)
                return
            }
            
            guard lastOperation == .reorder else { return }
            
            let fromIndexKey = ListConstants.Meta.LastOperationMeta.fromIndex
            let toIndexKey = ListConstants.Meta.LastOperationMeta.toIndex
            
            guard let fromIndex = lastOperationMeta[fromIndexKey] as? Int,
                let toIndex =   lastOperationMeta[toIndexKey] as? Int else {
                    Logger.log(reason: "Failed to get last position change!")
                    return
            }
            
            self.todoItemListViewDelegate?.todoItemPositionDidChange(from: fromIndex, to: toIndex)
            return
            
        }
        
    }
    
    func updateTodoListPositions(positions: [String], positionChange: [String: Int]) {
        let pathToUpdate = firebase.document(listMetaPath)
        pathToUpdate.setData([ListConstants.Meta.positions: positions,
                              ListConstants.Meta.lastOperation: ListOperation.reorder.rawValue,
                              ListConstants.Meta.lastOperationMeta: positionChange])
    }
    
    func clearLastPositionChanges() {
        let pathToUpdate = firebase.collection("taskOrder").document("list1")
        //        pathToUpdate.updateData(["last_position_change": FieldValue.delete()])
    }
    
    func detachListener() {
        allTodoItemsEventListener?.remove()
        todoItemListPositionEventListener?.remove()
    }
    
    func changeCompletionStatus(ForTodoItem todoItem: TodoItem) {
        let pathToUpdate = firebase.document(pendingTasksPath + "/" + (todoItem.documentID))
        pathToUpdate.updateData([TodoItem.Constants.isCompleted: todoItem.isCompleted])
    }
}
