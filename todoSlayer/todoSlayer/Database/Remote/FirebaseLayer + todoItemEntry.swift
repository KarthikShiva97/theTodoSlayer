//
//  FirebaseLayer + todoItemEntry.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 18/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import FirebaseFirestore

typealias didComplete = ((Bool) -> ())

//TODO:- Create Objects all the raw strings below

extension FirebaseLayer: TodoItemDetailViewDbAPI {
    
    fileprivate typealias Constants = ListConstants
    
    func saveTodoItem(_ todoItem: TodoItem, to taskType: TaskType) {
        
        let taskPath = taskType == .pending ? pendingTasksPath : completedTasksPath
        let documentPath =  firebase.collection(taskPath).document()
        let documentID = documentPath.documentID
        
        todoItem.setDocumentID(documentID)
        
        checkIfListPositionExists(for: taskType) { (exists) in
            if exists {
                self.addListPosition(forDocumentID: documentID, for: taskType)
            } else {
                self.createListPosition(forDocumentID: documentID, for: taskType)
            }
            let data = todoItem.json
            documentPath.setData(data)
        }
        
    }
    
    func deleteTodoItem(_ todoItem: TodoItem, atIndex index: Int,
                        from taskType: TaskType,
                        onCompletion: @escaping didComplete) {
        
        let pathToDelete = taskType == .pending ? pendingTasksPath : completedTasksPath
        
        deleteListPosition(forDocumentID: todoItem.documentID, atIndex: index,
                           taskType: taskType) { (didComplete) in
            
            guard didComplete == true else {
                Logger.log(reason: "Delete failed! Could not delete list position for \(todoItem) !")
                return onCompletion(false)
            }
            
            self.firebase.collection(pathToDelete).document(todoItem.documentID).delete(completion: { (error) in
                guard error == nil else {
                    Logger.log(reason: "Delete failed! Could not delete \(todoItem) !")
                    return onCompletion(false)
                }
                return onCompletion(true)
            })
            
        } // deleteListPosition 
        
    } // deleteTodoItem func ends ...
    
    
    func updateTodoItem(_ todoItem: TodoItem) {
        firebase.collection(pendingTasksPath).document(todoItem.documentID).setData(todoItem.json)
    }
    
    
    func checkIfListPositionExists(for taskType: TaskType, onCompletion: @escaping (Bool)->()) {
        let path = getMetaPath(for: taskType)
        let fullPath = firebase.document(path)
        fullPath.getDocument { (snapshot, error) in
            let exists = snapshot?.exists ?? false
            onCompletion(exists)
        }
    }
    
    func createListPosition(forDocumentID documentID: String, for taskType: TaskType) {
        let path = getMetaPath(for: taskType)
        let fullPath = firebase.document(path)
        fullPath.setData([Constants.Meta.positions: [documentID],
                          Constants.Meta.lastOperation: ListOperation.add.rawValue,
                          Constants.Meta.lastOperationMeta: NSNull()], merge: true)
    }
    
    func addListPosition(forDocumentID documentID: String, for taskType: TaskType){
        let path = getMetaPath(for: taskType)
        let fullPath = firebase.document(path)
        fullPath.updateData([Constants.Meta.positions: FieldValue.arrayUnion([documentID]),
                             Constants.Meta.lastOperation: ListOperation.add.rawValue,
                             Constants.Meta.lastOperationMeta: NSNull()])
    }
    
    internal func deleteListPosition(forDocumentID documentID: String,
                                     atIndex index: Int,
                                     taskType: TaskType,
                                     onCompletion: @escaping (Bool) -> ()) {
        
        let path = getMetaPath(for: taskType)
        let fullPath = firebase.document(path)
        let lastOperationMeta = [Constants.Meta.LastOperationMeta.lastRemovedIndex: index]
        let updatedData =
            [Constants.Meta.positions: FieldValue.arrayRemove([documentID]),
             Constants.Meta.lastOperation: ListOperation.delete.rawValue,
             Constants.Meta.lastOperationMeta: lastOperationMeta] as [String : Any]
        
        fullPath.updateData(updatedData) { (error) in
            guard error == nil else { return onCompletion(false) }
            onCompletion(true)
        }
        
    } // deleteListPosition func ends ....
    
    
    private func getMetaPath(for taskType: TaskType) -> String {
        return taskType == .pending ? pendingTasksMetaPath : completedTasksMetaPath
    }
    
} // extension ends ....
