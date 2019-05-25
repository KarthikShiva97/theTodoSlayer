//
//  DatabaseRequirements.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 12/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import RealmSwift

typealias DatabaseRequirements = TodoItemDetailViewDbAPI

protocol TodoItemDetailViewDbAPI {
    func saveTodoItem(_ todoItem: TodoItem)
    func deleteTodoItem(_ todoItem: TodoItem)
    func updateTodoItem(_ todoItem: TodoItem)
    func createListPosition(forDocumentID documentID: String)
    func updateTodoListPositions(positions: [String], positionChange: [String: Int])
    func clearLastPositionChanges()
}

protocol TodoItemListViewDbAPI: class {
    var todoItemListViewDelegate: TodoItemListViewDbDelegate? {get set}
}

protocol TodoItemListViewDbDelegate: class {
    func todoItemListViewDbDelegate(todoItemPositions: [String])
    func todoItemPositionDidChange(from sourceIndex: Int, to destinationIndex: Int)
    func todoItemListViewDbDelegate(allTodoItems: [TodoItem])
    func todoItemListViewDbDelegate(didAddTodoItem newTodoItem: TodoItem)
    func todoItemListViewDbDelegate(didDeleteTodoItem deletedTodoItem: TodoItem)
}
