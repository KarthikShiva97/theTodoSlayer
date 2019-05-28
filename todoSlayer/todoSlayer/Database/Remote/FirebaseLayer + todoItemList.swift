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
        
        let path = firebase.collection("taskOrder").document("list1")
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
            
            guard let positions = snapshotData["positions"] as? [String] else {
                Logger.log(reason: "\(errorMsg). Failed to typecast !")
                return onCompletion(.failure(.typecastFailed))
            }
            
            return onCompletion(.success(positions))
        }
        
    }
    
    func getAllTodoItems(onCompletion: @escaping (Result<[TodoItem], TodoItemListViewDbAPIError>)->()) {
        let path = firebase.collection("tasks")
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
        
        let pathToListen = firebase.collection("tasks").order(by: "name")
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
        
        let pathToListen = firebase.collection("taskOrder").document("list1")
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
            
            guard let lastOperationAsString = snapshotData["last_operation"] as? String else {
                Logger.log(.typecastFailed)
                return
            }
            
            guard let lastOperation = Operation(rawValue: lastOperationAsString) else {
                Logger.log(.typecastFailed, reason: "Cannot get back lastOperation as enum!")
                return
            }
            
            guard let positions = snapshotData["positions"] as? [String] else {
                Logger.log(.typecastFailed, reason: "Failed to get list positions!")
                return
            }
            
            self.todoItemListViewDelegate?.todoItemListViewDbDelegate(positions: positions)
            
            if lastOperation == .delete {
                guard let lastRemovedIndex = snapshotData["last_removed_index"] as? Int else {
                    Logger.log(reason: "Failed to get last removed index position!")
                    return
                }
                self.todoItemListViewDelegate?.didDeletePositionForTodoItem(atIndex: lastRemovedIndex)
                return
            }
            
            guard lastOperation == .reorder else { return }
            
            guard let lastPositionChange = snapshotData["last_position_change"] as? [String: Int] else {
                Logger.log(reason: "Failed to get last position change!")
                return
            }
            
            guard let fromIndex = lastPositionChange[PositionChange.from.rawValue],
                let toIndex = lastPositionChange[PositionChange.to.rawValue] else {
                    Logger.log(reason: "Failed to get last position change!")
                    return
            }
            
            self.todoItemListViewDelegate?.todoItemPositionDidChange(from: fromIndex, to: toIndex)
            return
            
        }
        
    }
    
    func updateTodoListPositions(positions: [String], positionChange: [String: Int]) {
        let pathToUpdate = firebase.collection("taskOrder").document("list1")
        pathToUpdate.setData(["positions": positions,
                              "last_operation": Operation.reorder.rawValue,
                              "last_position_change": positionChange])
    }
    
    func clearLastPositionChanges() {
        let pathToUpdate = firebase.collection("taskOrder").document("list1")
        pathToUpdate.updateData(["last_position_change": FieldValue.delete()])
    }
    
    func detachListener() {
        allTodoItemsEventListener?.remove()
        todoItemListPositionEventListener?.remove()
    }
    
}
