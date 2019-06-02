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
        
        todoItem.setDocumentID(documentID)
        createListPosition(forDocumentID: documentID)
        
        let data = todoItem.json
        documentPath.setData(data)
    }
    
    func deleteTodoItem(_ todoItem: TodoItem, atIndex index: Int) {
        deleteListPosition(forDocumentID: todoItem.documentID, atIndex: index)
        firebase.collection("tasks").document(todoItem.documentID).delete()
    }
    
    func updateTodoItem(_ todoItem: TodoItem) {
        firebase.collection("tasks").document(todoItem.documentID).setData(todoItem.json)
    }
    
    internal func createListPosition(forDocumentID documentID: String) {
        let path = firebase.collection("taskOrder").document("list1")
        path.updateData(["positions": FieldValue.arrayUnion([documentID]) ]) { (error) in
            guard error == nil else {
                path.setData(["positions": [documentID],
                              "last_operation": Operation.add.rawValue,
                              "last_removed_index": FieldValue.delete(),
                              "last_position_change": FieldValue.delete()], merge: true)
                return
            }
        }
    }
    
    internal func deleteListPosition(forDocumentID documentID: String, atIndex index: Int) {
        let path = firebase.collection("taskOrder").document("list1")
        path.updateData(["positions": FieldValue.arrayRemove([documentID]),
                         "last_operation": Operation.delete.rawValue,
                         "last_removed_index": index,
                         "last_position_change": FieldValue.delete()])
    }
    
}
