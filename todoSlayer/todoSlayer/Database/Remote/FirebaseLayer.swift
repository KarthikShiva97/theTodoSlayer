//
//  FirebaseLayer.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 18/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FirebaseLayer {
    
    let firebase: Firestore = {
        let instance = Firestore.firestore()
        //        instance.disableNetwork(completion: nil)
        return instance
    }()
    weak var todoItemListViewDelegate: TodoItemListViewDbDelegate?
    
    // MARK:- Constants
    let pendingTasksPath = "list1/\(ListConstants.taskType)/\(ListConstants.TaskType.pending)"
    let listMetaPath = "list1/\(ListConstants.meta)"
}

// MARK:- Constants Storage
extension FirebaseLayer {
    
    internal struct ListConstants {
        static let taskType = "taskType"
        static let meta = "meta"
        
        struct Meta {
            static let lastOperation = "lastOperation"
            static let lastOperationMeta = "lastOperationMeta"
            static let positions = "positions"
            
            struct LastOperationMeta {
                static let lastRemovedIndex = "lastRemovedIndex"
                static let fromIndex = "fromIndex"
                static let toIndex = "toIndex"
            }
        }
        
        struct TaskType {
            static let pending = "pending"
            static let completed = "completed"
        }
    }
    
}
