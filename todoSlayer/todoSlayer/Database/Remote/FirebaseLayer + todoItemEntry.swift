//
//  FirebaseLayer + todoItemEntry.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 18/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import FirebaseFirestore

//TODO:- Create Objects all the raw strings below

extension FirebaseLayer: TodoItemDetailViewDbAPI {
    
    fileprivate typealias Constants = ListConstants
    
    func saveTodoItem(_ todoItem: TodoItem) {
        let documentPath =  firebase.collection(pendingTasksPath).document()
        let documentID = documentPath.documentID
        
        todoItem.setDocumentID(documentID)
        createListPosition(forDocumentID: documentID)
        
        let data = todoItem.json
        documentPath.setData(data)
    }
    
    func deleteTodoItem(_ todoItem: TodoItem, atIndex index: Int) {
        deleteListPosition(forDocumentID: todoItem.documentID, atIndex: index)
        firebase.collection(pendingTasksPath).document(todoItem.documentID).delete()
    }
    
    func updateTodoItem(_ todoItem: TodoItem) {
        firebase.collection(pendingTasksPath).document(todoItem.documentID).setData(todoItem.json)
    }
    
    internal func createListPosition(forDocumentID documentID: String) {
        let path = firebase.document(listMetaPath)
        path.updateData([Constants.Meta.positions: FieldValue.arrayUnion([documentID]),
                         Constants.Meta.lastOperation: ListOperation.add.rawValue,
                         Constants.Meta.lastOperationMeta: NSNull()]) { (error) in
            guard error == nil else {
                path.setData([Constants.Meta.positions: [documentID],
                              Constants.Meta.lastOperation: ListOperation.add.rawValue,
                              Constants.Meta.lastOperationMeta: NSNull()], merge: false)
                return
            }
        }
    }
    
    internal func deleteListPosition(forDocumentID documentID: String, atIndex index: Int) {
        let path = firebase.document(listMetaPath)
        let lastOperationMeta = [Constants.Meta.LastOperationMeta.lastRemovedIndex: index]
        path.updateData([
            Constants.Meta.positions: FieldValue.arrayRemove([documentID]),
            Constants.Meta.lastOperation: ListOperation.delete.rawValue,
            Constants.Meta.lastOperationMeta: lastOperationMeta
            ])
        
    } // deleteListPosition func ends ....
    
}
