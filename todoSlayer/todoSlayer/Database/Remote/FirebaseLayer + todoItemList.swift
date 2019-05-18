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
fileprivate var isInitialFetch = false

extension FirebaseLayer: TodoItemListViewDbAPI {
    
    func attachListenerForAllTodoItems() {
        isInitialFetch = true
        allTodoItemsEventListener = firebase.collection("tasks").addSnapshotListener { (snapshot, error) in
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
    
    func detachListener() {
        allTodoItemsEventListener.remove()
    }
}
