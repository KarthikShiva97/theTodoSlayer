//
//  FirebaseLayer + todoItemEntry.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 18/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation

extension FirebaseLayer: TodoItemDetailViewDbAPI {
    
    func saveTodoItem(_ todoItem: TodoItem) {
        let documentPath =  firebase.collection("tasks").document()
        todoItem.documentID = documentPath.documentID
        let data = todoItem.json
        documentPath.setData(data)
    }
    
    func deleteTodoItem(_ todoItem: TodoItem) {
        firebase.collection("tasks").document(todoItem.documentID).delete()
    }
    
    func updateTodoItem(_ todoItem: TodoItem) {
        firebase.collection("tasks").document(todoItem.documentID).setData(todoItem.json)
    }
    
}
