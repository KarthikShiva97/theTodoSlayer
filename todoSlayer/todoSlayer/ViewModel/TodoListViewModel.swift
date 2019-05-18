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

protocol TodoListViewModelDelegate: class {
    func reloadAllItems()
    func appendItem(_ todoItem: TodoItem, atIndexPath indexPath: IndexPath)
    func deleteItem(atIndexPath indexPath: IndexPath)
    func scrollToItem(atIndexPath indexPath: IndexPath)
    func openTodoDetailVC(withMode mode: TodoDetailVC.Mode)
}

class TodoListViewModel {
    
    private weak var delegate: TodoListViewModelDelegate!
    
    private let remoteDatabase: FirebaseLayer = {
        return FirebaseLayer()
    }()
    
    var todoItems: [TodoItem] = []
    
    init(delegate: TodoListViewModelDelegate) {
        self.delegate = delegate
    }
}

// MARK:- Public API's
extension TodoListViewModel {
    
    func didSelectItem(atIndexPath indexPath: IndexPath) {
        let todoItemAtIndexPath = todoItems[indexPath.row]
        delegate?.openTodoDetailVC(withMode: .existingTodoItem(todoItemAtIndexPath))
    }
    
    func didSelectAddButton() {
        delegate?.openTodoDetailVC(withMode: .newTodoItem)
    }
    
    func willEnterScreen() {
        remoteDatabase.attachListenerForAllTodoItems()
        remoteDatabase.todoItemListViewDelegate = self
    }
    
    func willLeaveScreen() {
        remoteDatabase.detachListener()
    }
    
    func getTotalCount() -> Int {
        return todoItems.count
    }
    
    func getTodoItem(forIndexPath indexPath: IndexPath) -> TodoItemListModel {
        let todoItem = todoItems[indexPath.row]
        let textColor: UIColor = indexPath.row % 2 == 0 ? #colorLiteral(red: 0.5490196078, green: 0.7764705882, blue: 0.2901960784, alpha: 1) : #colorLiteral(red: 0.9647058824, green: 0.6901960784, blue: 0.0431372549, alpha: 1)
        return TodoItemListModel(name: todoItem.name, textColor: textColor)
    }
}

extension TodoListViewModel: TodoItemListViewDbDelegate {
    
    func todoItemListViewDbDelegate(didAddTodoItem newTodoItem: TodoItem) {
        self.todoItems.append(newTodoItem)
        let indexPathToInsert = IndexPath(item: todoItems.count - 1, section: 0)
        let indexPathToScroll = IndexPath(item: todoItems.count - 2, section: 0)
        delegate.appendItem(newTodoItem, atIndexPath: indexPathToInsert)
        delegate.scrollToItem(atIndexPath: indexPathToScroll)
    }
    
    func todoItemListViewDbDelegate(didDeleteTodoItem deletedTodoItem: TodoItem) {
        for (index, todoItem) in todoItems.enumerated() {
            if todoItem.ID == deletedTodoItem.ID {
                todoItems.remove(at: index)
                delegate.deleteItem(atIndexPath: IndexPath(item: index, section: 0))
            }
        }
    }
    
    func todoItemListViewDbDelegate(allTodoItems: [TodoItem]) {
        self.todoItems = allTodoItems
        delegate.reloadAllItems()
    }
    
}
