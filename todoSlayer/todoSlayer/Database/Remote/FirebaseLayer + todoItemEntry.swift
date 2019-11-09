//
//  FirebaseLayer + todoItemEntry.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 18/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum Execute {
    case operation(didComplete)
    case syncBatchWrite(WriteBatch)
    case asyncBatchWrite(WriteBatch, didCompleteBatchWrite)
}

typealias didCompleteBatchWrite = ((WriteBatch) -> ())?
typealias didComplete = ((Bool) -> ())?

//TODO:- Create Objects all the raw strings below

extension FirebaseLayer: TodoItemDetailViewDbAPI {
    
    fileprivate typealias Constants = ListConstants
    
    func saveTodoItem(_ todoItem: TodoItem, to taskType: TaskType, execute: Execute) {
        
        var batch: WriteBatch!
        var operationCompletionClosure: didComplete = nil
        var asyncBatchWriteCompletionClosure: didCompleteBatchWrite = nil
        
        switch execute {
            
        case .operation(let completionClosure):
            operationCompletionClosure = completionClosure
            batch = firebase.batch()
            
        case .syncBatchWrite(let batchReceived):
            operationCompletionClosure = nil
            asyncBatchWriteCompletionClosure = nil
            fatalError("Cannot perfrom Sync Batch Write!")
            
        case .asyncBatchWrite(let batchReceived, let completionClosure):
            asyncBatchWriteCompletionClosure = completionClosure
            batch = batchReceived
            
        }
        
        let taskPath = taskType == .pending ? pendingTasksPath : completedTasksPath
        let newTodoItemdocumentPath =  firebase.collection(taskPath).document()
        let documentID = newTodoItemdocumentPath.documentID
        
        todoItem.setDocumentID(documentID)
        
        checkIfListPositionExists(for: taskType) { (exists) in
            
            if exists {
                self.addListPosition(forDocumentID: documentID, for: taskType, batch: batch)
            } else {
                self.createListPosition(forDocumentID: documentID, for: taskType, batch: batch)
            }
            
            let data = todoItem.json
            batch.setData(data, forDocument: newTodoItemdocumentPath)
            
            // Handling Execution
            
            if case .asyncBatchWrite(_, _)  = execute {
                asyncBatchWriteCompletionClosure!(batch)
                return
            }
            
            // If it should be executed now, execute and call the completion handler
            guard case .operation(_) = execute else { return }
            
            batch.commit(completion: { (error) in
                guard error == nil else { operationCompletionClosure!(false); return }
                operationCompletionClosure!(true)
                return
            })
            
        } // checkIfListPositionExists closure ends ...
        
    }
    
    func deleteTodoItem(_ todoItem: TodoItem, atIndex index: Int, from taskType: TaskType,
                        execute: Execute) {
        
        
        var batch: WriteBatch!
        var onCompletion: didComplete
        
        switch execute {
            
        case .operation(let completionClosure):
            onCompletion = completionClosure
            batch = firebase.batch()
            
        case .syncBatchWrite(let batchReceived):
            onCompletion = nil
            batch = batchReceived
            
        default: fatalError("oops!")
            
        }
        
        let pathToDelete = taskType == .pending ? pendingTasksPath : completedTasksPath
        let todoItemPathRef = self.firebase.collection(pathToDelete).document(todoItem.documentID)
        
        
        deleteListPosition(forDocumentID: todoItem.documentID,
                           atIndex: index,
                           taskType: taskType,
                           batch: batch)
        
        batch.deleteDocument(todoItemPathRef)
        
        
        // If it should be executed now, execute and call the completion handler
        guard case .operation(_) = execute else { return }
        
        
        batch.commit { (error) in
            guard error == nil else { onCompletion!(false); return }
            onCompletion!(true)
            return
        }
        
    } // deleteTodoItem func ends ...
    
    
    func updateTodoItem(_ todoItem: TodoItem) {
        let path = todoItem.taskType == .pending ? pendingTasksPath : completedTasksPath
        firebase.collection(path).document(todoItem.documentID).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else { return }
            guard snapshot.exists else {
                Logger.log(reason: "Update for Todo \(todoItem) Failed! It does not exist!")
                return
            }
            self.firebase.collection(path).document(todoItem.documentID).setData(todoItem.json)
        }
    }
    
    
    func checkIfListPositionExists(for taskType: TaskType, onCompletion: @escaping (Bool)->()) {
        let path = getMetaPath(for: taskType)
        let fullPath = firebase.document(path)
        fullPath.getDocument { (snapshot, error) in
            let exists = snapshot?.exists ?? false
            onCompletion(exists)
        }
    }
    
    func createListPosition(forDocumentID documentID: String, for taskType: TaskType, batch: WriteBatch) {
        let path = getMetaPath(for: taskType)
        let fullPath = firebase.document(path)
        let newData = [Constants.Meta.positions: [documentID],
                       Constants.Meta.lastOperation: ListOperation.add.rawValue,
                       Constants.Meta.lastOperationMeta: NSNull()] as [String : Any]
        
        batch.setData(newData, forDocument: fullPath)
    }
    
    func addListPosition(forDocumentID documentID: String, for taskType: TaskType, batch: WriteBatch){
        let path = getMetaPath(for: taskType)
        let fullPath = firebase.document(path)
        let newData  = ([Constants.Meta.positions: FieldValue.arrayUnion([documentID]),
                         Constants.Meta.lastOperation: ListOperation.add.rawValue,
                         Constants.Meta.lastOperationMeta: NSNull()] as [String : Any])
        batch.updateData(newData, forDocument: fullPath)
    }
    
    internal func deleteListPosition(forDocumentID documentID: String,
                                     atIndex index: Int,
                                     taskType: TaskType,
                                     batch: WriteBatch) {
        
        // 1) Remove its position from List Meta
        let metaPathRef = firebase.document(getMetaPath(for: taskType))
        let lastOperationMeta = [Constants.Meta.LastOperationMeta.lastRemovedIndex: index]
        let updatedData =
            [Constants.Meta.positions: FieldValue.arrayRemove([documentID]),
             Constants.Meta.lastOperation: ListOperation.delete.rawValue,
             Constants.Meta.lastOperationMeta: lastOperationMeta] as [String : Any]
        
        batch.updateData(updatedData, forDocument: metaPathRef)
        
    } // deleteListPosition func ends ....
    
    
    private func getMetaPath(for taskType: TaskType) -> String {
        return taskType == .pending ? pendingTasksMetaPath : completedTasksMetaPath
    }
    
} // extension ends ....
