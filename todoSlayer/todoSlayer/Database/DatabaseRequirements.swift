//
//  DatabaseRequirements.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 12/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import RealmSwift

typealias DatabaseRequirements = TodoItemEntryDbAPI

protocol TodoItemEntryDbAPI {
    func saveTodoItem(_ todoItem: TodoItem)
}

protocol TodoItemListViewDbAPI {
    func getAllTodoItems() -> Results<TodoItem>
}
