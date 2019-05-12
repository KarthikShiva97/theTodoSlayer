//
//  TodoListViewModel.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 09/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import RealmSwift

struct TodoItemListModel {
    let name: String
    let textColor: UIColor
}

class TodoListViewModel {
    
    private let database: TodoItemListViewDbAPI = {
        return RealmLayer()
    }()
    
    var todoItems: Results<TodoItem>!
    
    init() {
        todoItems = database.getAllTodoItems()
        guard todoItems != nil else {fatalError("Task Items is nil!")}
    }
}

// MARK:- Public API's
extension TodoListViewModel {
    
    func getTotalCount() -> Int {
        return todoItems.count
    }
    
    func getTodoItem(forIndexPath indexPath: IndexPath) -> TodoItemListModel {
        let todoItem = todoItems[indexPath.row]
        let textColor: UIColor = indexPath.row % 2 == 0 ? #colorLiteral(red: 0.5490196078, green: 0.7764705882, blue: 0.2901960784, alpha: 1) : #colorLiteral(red: 0.9647058824, green: 0.6901960784, blue: 0.0431372549, alpha: 1)
        return TodoItemListModel(name: todoItem.name, textColor: textColor)
    }
}
