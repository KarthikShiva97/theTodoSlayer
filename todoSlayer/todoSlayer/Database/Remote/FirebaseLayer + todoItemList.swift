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
fileprivate var todoItemOrderEventListener: ListenerRegistration!
fileprivate var isInitialFetch = false

extension FirebaseLayer: TodoItemListViewDbAPI {
    
    func attachListenerForAllTodoItems() {
        isInitialFetch = true
        
        let pathToListen = firebase.collection("tasks").order(by: "name")
        
        allTodoItemsEventListener = pathToListen.addSnapshotListener { (snapshot, error) in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            if isInitialFetch {
                let todoItems = snapshot.documents.compactMap({ (document) in
                    return TodoItem(json: document.data())
                })
                self.todoItemListViewDelegate?.todoItemListViewDbDelegate(allTodoItems: todoItems)
                isInitialFetch = false
                return
            }
            
            snapshot.documentChanges.forEach{ (change)  in
                guard let todoItem = TodoItem(json: change.document.data()) else { return }
                if change.type == .added {
                    self.todoItemListViewDelegate?.todoItemListViewDbDelegate(didAddTodoItem: todoItem)
                }
                
                if change.type == .removed {
                    self.todoItemListViewDelegate?.todoItemListViewDbDelegate(didDeleteTodoItem: todoItem)
                }
            }
        }
    }
    
    func attachListenerForTodoItemListPositions() {
        let pathToListen = firebase.collection("taskOrder").document("list1")
        todoItemOrderEventListener = pathToListen.addSnapshotListener(){ (snapshot, error) in
            
            let errMsg = "Failed to fetch todo item order!"
            guard error == nil else {
                print(error!)
                print(errMsg)
                return
            }
            
            guard let snapshotData = snapshot?.data() else { return }
            
            guard let todoItemOrder = snapshotData["positions"] as? [String] else {
                print(errMsg)
                self.todoItemListViewDelegate?.todoItemListViewDbDelegate(todoItemPositions: [])
                return
            }
            
            if let lastPositionChange = snapshotData["last_position_change"] as? [String: Int] {
                
                guard let fromIndex = lastPositionChange[PositionChange.from.rawValue],
                    let toIndex = lastPositionChange[PositionChange.to.rawValue] else {
                        print("Failed to get last Position Changes!")
                        return
                }
                
                self.todoItemListViewDelegate?.todoItemPositionDidChange(from: fromIndex, to: toIndex)
                
            }
            
            self.todoItemListViewDelegate?.todoItemListViewDbDelegate(todoItemPositions: todoItemOrder)
        }
        
    }
    
    func updateTodoListPositions(positions: [String], positionChange: [String: Int]) {
        let pathToUpdate = firebase.collection("taskOrder").document("list1")
        pathToUpdate.setData(["positions": positions, "last_position_change": positionChange])
    }
    
    func clearLastPositionChanges() {
        let pathToUpdate = firebase.collection("taskOrder").document("list1")
        pathToUpdate.updateData(["last_position_change": FieldValue.delete()])
    }
    
    func detachListener() {
//        allTodoItemsEventListener?.remove()
    }
    
}
