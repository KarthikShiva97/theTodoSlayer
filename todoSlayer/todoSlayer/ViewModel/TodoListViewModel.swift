//
//  TodoListViewModel.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 09/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import UIKit

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

enum TodoItemListViewDbAPIError: Error {
    case typecastFailed
    case nilSnapshot
    case generalError(Error)
}

class TodoListViewModel {
    
    private weak var delegate: TodoListViewModelDelegate!
    
    private let remoteDatabase: FirebaseLayer = {
        return FirebaseLayer()
    }()
    
    private var todoItemsPositions = [String]() {
        didSet {
            createIndexPathDocumentIDMap()
        }
    }
    
    private var indexPathDocumentIDMap = [IndexPath: String]()
    private var documentIDTodoItemMap = [String: TodoItem]()
    
    private var lastSourceIndex: Int = 0
    private var lastDestinationIndex: Int = 0
    
    init(delegate: TodoListViewModelDelegate) {
        self.delegate = delegate
    }
}

// MARK:- Public API's
extension TodoListViewModel {
    
    func moveItem(from source: IndexPath, to destination: IndexPath) {
        lastSourceIndex = source.row
        lastDestinationIndex = destination.row
        
        let positionChange: [String: Int] = [PositionChange.from.rawValue: source.row,
                                             PositionChange.to.rawValue: destination.row]
        // Update Document Positions to Remote
        remoteDatabase.updateTodoListPositions(positions: todoItemsPositions, positionChange: positionChange)
    }
    
    func didSelectItem(atIndexPath indexPath: IndexPath) {
        guard let todoItem = getTodoItem(atIndexPath: indexPath) else {
            Logger.log(reason: "Cannot show detail view for todo Item at \(indexPath) !")
            return
        }
        delegate?.openTodoDetailVC(withMode: .existingTodoItem(todoItem))
    }
    
    func didSelectAddButton() {
        delegate?.openTodoDetailVC(withMode: .newTodoItem)
    }
    
    func willEnterScreen() {
        indexPathDocumentIDMap = [:]
        documentIDTodoItemMap = [:]
        remoteDatabase.todoItemListViewDelegate = self
        getTodoItemsListPositions()
    }
    
    func didLeaveScreen() {
        remoteDatabase.clearLastPositionChanges()
        remoteDatabase.detachListener()
    }
    
    private func getTodoItemsListPositions() {
        remoteDatabase.getTodoItemListPositions { [unowned self] (result) in
            let positions = try! result.get()
            self.todoItemsPositions = positions
            self.createIndexPathDocumentIDMap()
            self.getAllTodoItems()
        }
    }
    
    private func getAllTodoItems() {
        remoteDatabase.getAllTodoItems { [unowned self] (result) in
            let todoItems = try! result.get()
            self.createDocumentIDTodoItemMap(todoItems: todoItems)
            self.remoteDatabase.attachListenerForTodoItemListPositions()
            self.remoteDatabase.attachListenerForAllTodoItems()
            self.delegate.reloadAllItems()
        }
    }
    
    private func getTodoItem(atIndexPath indexPath: IndexPath) -> TodoItem? {
        guard let documentID = indexPathDocumentIDMap[indexPath] else {
            Logger.log(reason: "Cannot find document ID for IndexPath \(indexPath)")
            return nil
        }
        
        guard let todoItem = documentIDTodoItemMap[documentID] else {
            Logger.log(reason: "Cannot find Todo Item ID for Document ID \(documentID)")
            return nil
        }
        return todoItem
    }
    
    private func removeTodoItem(atIndexPath indexPath: IndexPath) {
        guard let documentID = getTodoItem(atIndexPath: indexPath)?.documentID else {
            Logger.log(reason: "Failed to remove item at IndexPath \(indexPath)")
            return
        }
        documentIDTodoItemMap[documentID] = nil
    }
    
    
    func getTotalCount() -> Int {
        return documentIDTodoItemMap.values.count
    }
    
    
    func getTodoItem(forIndexPath indexPath: IndexPath) -> TodoItemListModel {
        
        guard let todoItem = getTodoItem(atIndexPath: indexPath) else {
            fatalError()
        }
        
        let textColor: UIColor = indexPath.row % 2 == 0 ? #colorLiteral(red: 0.5490196078, green: 0.7764705882, blue: 0.2901960784, alpha: 1) : #colorLiteral(red: 0.9647058824, green: 0.6901960784, blue: 0.0431372549, alpha: 1)
        return TodoItemListModel(name: todoItem.name, textColor: textColor)
    }
    
}

extension TodoListViewModel: TodoItemListViewDbDelegate {
    
    func todoItemListViewDbDelegate(positions: [String]) {
        self.todoItemsPositions = positions
    }
    
    func todoItemPositionDidChange(from sourceIndex: Int, to destinationIndex: Int) {
        guard lastSourceIndex != sourceIndex && lastDestinationIndex != destinationIndex else { return }
        let sourceIndexPath = IndexPath(row: sourceIndex, section: 0)
        let destinationIndexPath = IndexPath(row: destinationIndex, section: 0)
        delegate.moveItem(at: sourceIndexPath, to: destinationIndexPath)
    }
    
    func todoItemListViewDbDelegate(didAddTodoItem newTodoItem: TodoItem) {
        
        documentIDTodoItemMap[newTodoItem.documentID] = newTodoItem
        
        let indexPathToInsert = IndexPath(item: getTotalCount() - 1, section: 0)
        let indexPathToScroll = IndexPath(item: getTotalCount() - 2, section: 0)
        
        // Insert document ID <-> Todo Item entry
        indexPathDocumentIDMap[indexPathToInsert] = newTodoItem.documentID
        documentIDTodoItemMap[newTodoItem.documentID] = newTodoItem
        
        delegate.appendItem(newTodoItem, atIndexPath: indexPathToInsert)
        delegate.scrollToItem(atIndexPath: indexPathToScroll)
    }
    
    func todoItemListViewDbDelegate(didDeleteTodoItem deletedTodoItem: TodoItem) {
        
        documentIDTodoItemMap[deletedTodoItem.documentID] = nil
        
        var indexPathToDelete: IndexPath!
        
        for (indexPath, documentID) in indexPathDocumentIDMap {
            guard documentID == deletedTodoItem.documentID else { continue }
            indexPathToDelete = indexPath
        }
        
        guard indexPathToDelete != nil else {
            Logger.log(reason: "Cannot find IndexPath to delete for \(deletedTodoItem)!")
            return
        }
        
        delegate.deleteItem(atIndexPath: indexPathToDelete)
    }
}


extension TodoListViewModel {
    
    private func createIndexPathDocumentIDMap() {
        
        // Index Path Document ID map is created from todoItemPositions
        // If the latter is empty, former should also be empty
        guard self.todoItemsPositions.isEmpty == false else {
            indexPathDocumentIDMap = [:]
            return
        }
        
        var indexPathDocumentIDMap = [IndexPath: String]()
        
        for index in 0...(todoItemsPositions.count - 1) {
            let indexPath = IndexPath(row: index, section: 0)
            let documentID = todoItemsPositions[index]
            indexPathDocumentIDMap[indexPath] = documentID
        }
        
        self.indexPathDocumentIDMap = indexPathDocumentIDMap
    }
    
    private func createDocumentIDTodoItemMap(todoItems: [TodoItem]) {
        var documentIDTodoItemMap = [String: TodoItem]()
        todoItems.forEach { (todoItem) in
            documentIDTodoItemMap[todoItem.documentID] = todoItem
        }
        self.documentIDTodoItemMap = documentIDTodoItemMap
    }
}
