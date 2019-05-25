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
    
    func attachListenerForTodoItemListPositions() {
        let pathToListen = firebase.collection("taskOrder").document("list1")
        todoItemOrderEventListener = pathToListen.addSnapshotListener(){ (snapshot, error) in
            
            let errMsg = "Failed to fetch todo item order!"
            guard error == nil else {
                print(error!)
                print(errMsg)
                return
            }
            
            guard let snapshot = snapshot else { return }
            guard let todoItemOrder = snapshot.data()?["positions"] as? [String] else {
                print(errMsg)
                self.todoItemListViewDelegate?.todoItemListViewDbDelegate(todoItemPositions: [])
                return
            }
            
            self.todoItemListViewDelegate?.todoItemListViewDbDelegate(todoItemPositions: todoItemOrder)
        }
        
    }
    
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
    
    func updateTodoListPositions(positions: [String], positionChange: [String: Int]) {
        let pathToUpdate = firebase.collection("taskOrder").document("list1")
        pathToUpdate.setData(["positions": positions, "position_change": positionChange])
    }
    
    func detachListener() {
        allTodoItemsEventListener.remove()
    }
}
