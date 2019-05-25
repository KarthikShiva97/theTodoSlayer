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
    func reloadAllItemsWithAnimation()
    func reloadAllItems()
    func appendItem(_ todoItem: TodoItem, atIndexPath indexPath: IndexPath)
    func deleteItem(atIndexPath indexPath: IndexPath)
    func scrollToItem(atIndexPath indexPath: IndexPath)
    func openTodoDetailVC(withMode mode: TodoDetailVC.Mode)
    func moveItem(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

enum PositionChange: String {
    case from
    case to
}

class TodoListViewModel {
    
    private weak var delegate: TodoListViewModelDelegate!
    
    private let remoteDatabase: FirebaseLayer = {
        return FirebaseLayer()
    }()
    
    private var todoItemsPositions: [String]!
    
    private var indexPathDocumentIDMap: [IndexPath: String]! {
        willSet {
            
            // Initially indexPathDocumentIDMap is nil,
            // After determining the order of documents, fetch all documents
            if indexPathDocumentIDMap == nil {
                remoteDatabase.attachListenerForAllTodoItems()
                return
            }
        }
        
        didSet {
            // If there is an update while there is already a mapping between document Id and todo items,
            // it means that there is an update to the position of the items
            if documentIDTodoItemMap != nil {
                delegate.reloadAllItemsWithAnimation()
            }
            
        }
    }
    
    private var documentIDTodoItemMap: [String: TodoItem]!
    
    var todoItems: [TodoItem] = []
    
    init(delegate: TodoListViewModelDelegate) {
        self.delegate = delegate
    }
}

// MARK:- Public API's
extension TodoListViewModel {
    
    func moveItem(from source: IndexPath, to destination: IndexPath) {
        let removedItem = todoItems.remove(at: source.row)
        todoItems.insert(removedItem, at: destination.row)
        
        // Updating Document Positions locally
        let removedDocumentID = todoItemsPositions.remove(at: source.row)
        todoItemsPositions.insert(removedDocumentID, at: destination.row)
        
        let positionChange: [String: Int] = [PositionChange.from.rawValue: source.row,
                                             PositionChange.to.rawValue: destination.row]
        
        // Update Document Positions to Remote
        remoteDatabase.updateTodoListPositions(positions: todoItemsPositions, positionChange: positionChange)
    }
    
    func didSelectItem(atIndexPath indexPath: IndexPath) {
        let todoItemAtIndexPath = todoItems[indexPath.row]
        delegate?.openTodoDetailVC(withMode: .existingTodoItem(todoItemAtIndexPath))
    }
    
    func didSelectAddButton() {
        delegate?.openTodoDetailVC(withMode: .newTodoItem)
    }
    
    func willEnterScreen() {
        remoteDatabase.todoItemListViewDelegate = self
        remoteDatabase.attachListenerForTodoItemListPositions()
    }
    
    func willLeaveScreen() {
        remoteDatabase.clearLastPositionChanges()
        remoteDatabase.detachListener()
    }
    
    func getTotalCount() -> Int {
        return todoItems.count
    }
    
    func getTodoItem(forIndexPath indexPath: IndexPath) -> TodoItemListModel {
        guard let documentIDForIndexPath = indexPathDocumentIDMap[indexPath] else {
            fatalError()
        }
        
        guard let todoItem = documentIDTodoItemMap[documentIDForIndexPath] else {
            fatalError()
        }
        
        let textColor: UIColor = indexPath.row % 2 == 0 ? #colorLiteral(red: 0.5490196078, green: 0.7764705882, blue: 0.2901960784, alpha: 1) : #colorLiteral(red: 0.9647058824, green: 0.6901960784, blue: 0.0431372549, alpha: 1)
        return TodoItemListModel(name: todoItem.name, textColor: textColor)
    }
}

extension TodoListViewModel: TodoItemListViewDbDelegate {
    
    func todoItemPositionDidChange(from sourceIndex: Int, to destinationIndex: Int) {
        let maxValidIndex = todoItems.count - 1
        guard sourceIndex <= maxValidIndex && destinationIndex <= maxValidIndex else {
            print("Inavlid Position Change !")
            return
        }
        
        let removedItem = todoItems.remove(at: sourceIndex)
        todoItems.insert(removedItem, at: destinationIndex)
        
        let sourceIndexPath = IndexPath(row: sourceIndex, section: 0)
        let destinationIndexPath = IndexPath(row: destinationIndex, section: 0)
        delegate.moveItem(at: sourceIndexPath, to: destinationIndexPath)
    }
    
    func todoItemListViewDbDelegate(todoItemPositions: [String]) {
        self.todoItemsPositions = todoItemPositions
        createIndexPathDocumentIDMap()
    }
    
    func todoItemListViewDbDelegate(didAddTodoItem newTodoItem: TodoItem) {
        self.todoItems.append(newTodoItem)
        let indexPathToInsert = IndexPath(item: todoItems.count - 1, section: 0)
        let indexPathToScroll = IndexPath(item: todoItems.count - 2, section: 0)
        
        // Insert document ID <-> Todo Item entry
        documentIDTodoItemMap[newTodoItem.documentID] = newTodoItem
        
        delegate.appendItem(newTodoItem, atIndexPath: indexPathToInsert)
        delegate.scrollToItem(atIndexPath: indexPathToScroll)
    }
    
    func todoItemListViewDbDelegate(didDeleteTodoItem deletedTodoItem: TodoItem) {
        for (index, todoItem) in todoItems.enumerated() {
            if todoItem.ID == deletedTodoItem.ID {
                
                // Delete document ID <-> Todo Item entry
                documentIDTodoItemMap[todoItem.documentID] = nil
                
                todoItems.remove(at: index)
                delegate.deleteItem(atIndexPath: IndexPath(item: index, section: 0))
            }
        }
    }
    
    func todoItemListViewDbDelegate(allTodoItems: [TodoItem]) {
        self.todoItems = allTodoItems
        createDocumentIDTodoItemMap()
        delegate.reloadAllItems()
    }
    
}


extension TodoListViewModel {
    
    private func createIndexPathDocumentIDMap() {
        guard self.todoItemsPositions.isEmpty == false else { return }
        var indexPathDocumentIDMap = [IndexPath: String]()
        for index in 0...(todoItemsPositions.count - 1) {
            let indexPath = IndexPath(row: index, section: 0)
            let documentID = todoItemsPositions[index]
            indexPathDocumentIDMap[indexPath] = documentID
        }
        self.indexPathDocumentIDMap = indexPathDocumentIDMap
    }
    
    private func createDocumentIDTodoItemMap() {
        var documentIDTodoItemMap = [String: TodoItem]()
        todoItems.forEach { (todoItem) in
            documentIDTodoItemMap[todoItem.documentID] = todoItem
        }
        self.documentIDTodoItemMap = documentIDTodoItemMap
    }
}
