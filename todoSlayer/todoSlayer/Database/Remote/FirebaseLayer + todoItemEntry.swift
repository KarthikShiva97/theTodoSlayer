//
//  FirebaseLayer + todoItemEntry.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 18/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension FirebaseLayer: TodoItemDetailViewDbAPI {
    
    func saveTodoItem(_ todoItem: TodoItem) {
        let documentPath =  firebase.collection("tasks").document()
        let documentID = documentPath.documentID
        
        todoItem.documentID = documentID
        createListPosition(forDocumentID: documentID)
        
        let data = todoItem.json
        documentPath.setData(data)
    }
    
    internal func createListPosition(forDocumentID documentID: String) {
        let path = firebase.collection("taskOrder").document("list1")
        path.updateData(["positions": FieldValue.arrayUnion([documentID]) ]) { (error) in
            guard error == nil else {
                path.setData(["positions": [documentID]], merge: false)
                return
            }
        }
    }
    
    internal func deleteListPosition(forDocumentID documentID: String) {
        let path = firebase.collection("taskOrder").document("list1")
        path.updateData(["positions": FieldValue.arrayRemove([documentID])])
    }
    
    func deleteTodoItem(_ todoItem: TodoItem) {
        deleteListPosition(forDocumentID: todoItem.documentID)
        firebase.collection("tasks").document(todoItem.documentID).delete()
    }
    
    func updateTodoItem(_ todoItem: TodoItem) {
        firebase.collection("tasks").document(todoItem.documentID).setData(todoItem.json)
    }
    
}
