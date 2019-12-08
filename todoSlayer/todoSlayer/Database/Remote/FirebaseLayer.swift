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
    
    weak var todoItemListViewDelegate: ItemListViewServiceDelegate?
    
    // MARK:- Paths
    let pendingTasksPath = "list1/\(Constants.tasks)/\(Constants.TaskType.pending)"
    let completedTasksPath = "list1/\(Constants.tasks)/\(Constants.TaskType.completed)"
    
    let pendingTasksMetaPath = "list1/\(Constants.meta)/\(Constants.TaskType.pending)/\(Constants.details)"
    
    let completedTasksMetaPath = "list1/\(Constants.meta)/\(Constants.TaskType.completed)/\(Constants.details)"
    
    let deviceTokensPath = "\(Constants.deviceTokens)"
    
}

// MARK:- Constants Storage
extension FirebaseLayer {
    
    enum Constants: String {
        case tasks
        case meta
        case details
        case deviceTokens
        
        enum Meta: String {
            case lastOperation
            case lastOperationMeta
            case positions
            
            enum LastOperationMeta: String {
                case lastRemovedIndex
                case fromIndex
                case toIndex
            }
        }
        
        enum TaskType: String {
            case pending
            case completed
        }
        
        enum AppEntry: String {
            case users
            case deviceTokens 
        }
    } // ListConstants end ...
    
}
