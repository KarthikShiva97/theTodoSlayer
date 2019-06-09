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
    let completeButtonColor: UIColor
    let isCompleted: Bool
    let checkBoxAction: ((RoundedCheckBoxButton)->())?
}

protocol TodoListViewModelDelegate: class {
    func stopRefreshing()
    func reloadAllItemsWithAnimation()
    func reloadAllItems()
    func appendItem(_ todoItem: TodoItem, atIndexPath indexPath: IndexPath)
    func deleteItem(atIndexPath indexPath: IndexPath)
    func reloadItem(atIndexPath indexPath: IndexPath)
    func scrollToItem(atIndexPath indexPath: IndexPath)
    func openTodoDetailVC(withMode mode: TodoDetailVC.Mode)
    func moveItem(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

enum PositionChange: String {
    case from = "fromIndex"
    case to = "toIndex"
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
    
    private let pendingTasks = TodoListVCModel(taskType: .pending)
    private let completedTasks = TodoListVCModel(taskType: .completed)
    
    private var currentTaskDataSource: TodoListVCModel!
    
    private var currentTaskType: TaskType = .pending {
        didSet {
            switch currentTaskType {
            case .pending:
                currentTaskDataSource = pendingTasks
            case .completed:
                currentTaskDataSource = completedTasks
            }
            delegate.reloadAllItems()
        }
    }
    
    init(delegate: TodoListViewModelDelegate) {
        self.delegate = delegate
        self.currentTaskDataSource = pendingTasks
    }
}

// MARK:- Public API's
extension TodoListViewModel {
    
    func setCurrentTaskType(to taskType: TaskType) {
        guard taskType != currentTaskType else { return }
        self.currentTaskType = taskType
    }
    
    func refresh() {
        beginDataSetup()
    }
    
    func moveItem(from source: IndexPath, to destination: IndexPath) {
        currentTaskDataSource.lastSourceIndex = source.row
        currentTaskDataSource.lastDestinationIndex = destination.row
        
        let positionChange: [String: Int] = [PositionChange.from.rawValue: source.row,
                                             PositionChange.to.rawValue: destination.row]
        
        // Update the document ID position locally
        let documentID = currentTaskDataSource.todoItemsPositions.remove(at: source.row)
        currentTaskDataSource.todoItemsPositions.insert(documentID, at: destination.row)
        
        // Update Document Positions to Remote
        let positions = currentTaskDataSource.todoItemsPositions
        remoteDatabase.updateTodoListPositions(positions: positions,
                                               positionChange: positionChange,
                                               taskType: currentTaskType)
    }
    
    func didSelectItem(atIndexPath indexPath: IndexPath) {
        guard let todoItem = getTodoItem(atIndexPath: indexPath) else {
            Logger.log(reason: "Cannot show detail view for todo Item at \(indexPath) !")
            return
        }
        delegate?.openTodoDetailVC(withMode: .existingTodoItem(todoItem, indexPath))
    }
    
    func didSelectAddButton() {
        delegate?.openTodoDetailVC(withMode: .newTodoItem)
    }
    
    func willEnterScreen() {
        beginDataSetup()
    }
    
    func didLeaveScreen() {
        remoteDatabase.clearLastPositionChanges()
        remoteDatabase.detachListener()
    }
    
    private func beginDataSetup() {
        remoteDatabase.todoItemListViewDelegate = self
        TaskType.forEachDo {
            self.remoteDatabase.attachListenerForTodoItemListPositions(for: $0)
            self.remoteDatabase.attachListenerForAllTodoItems(for: $0)
        }
        TaskType.forEachDo { getTodoItemsListPositions(for: $0) }
    }
    
    private func getTodoItemsListPositions(for taskType: TaskType) {
        remoteDatabase.getTodoItemListPositions(for: taskType) { [unowned self] (result) in
            
            guard let positions = try? result.get() else {
                Logger.log(reason: "Todo Item positions are nil!")
                return
            }
            
            let taskDataSource = self.getTaskDataSource(for: taskType)
            taskDataSource.todoItemsPositions = positions
            
            self.getAllTodoItems(for: taskType)
            
        }
    }
    
    private func getAllTodoItems(for taskType: TaskType) {
        remoteDatabase.getAllTodoItems(for: taskType) { [unowned self] (result) in
            
            let todoItems = try! result.get()
            
            let taskDataSource = self.getTaskDataSource(for: taskType)
            taskDataSource.todoItems = todoItems
            
            self.invokeDelegateActionIfCurrentTaskType(is: taskType) {
                $0.stopRefreshing()
                $0.reloadAllItems()
            }
        }
    }
    
    private func getTodoItem(atIndexPath indexPath: IndexPath) -> TodoItem? {
        
        let indexPathDocumentIDMap = currentTaskDataSource.indexPathDocumentIDMap
        let documentIDTodoItemMap = currentTaskDataSource.documentIDTodoItemMap
        
        guard let documentID = indexPathDocumentIDMap[indexPath] else {
            Logger.log(reason: "Cannot find document ID for IndexPath \(indexPath)")
            return nil
        }
        
        guard let todoItem = documentIDTodoItemMap[documentID] else {
            Logger.log(reason: "Cannot find Todo Item for Document ID \(documentID)")
            return nil
        }
        return todoItem
    }
    
    private func removeTodoItem(atIndexPath indexPath: IndexPath) {
        guard let documentID = getTodoItem(atIndexPath: indexPath)?.documentID else {
            Logger.log(reason: "Failed to remove item at IndexPath \(indexPath)")
            return
        }
        currentTaskDataSource.deleteTodoItem(withDocumentID: documentID)
    }
    
    
    func getTotalCount() -> Int {
        return currentTaskDataSource.documentIDTodoItemMap.values.count
    }
    
    
    func getTodoItem(forIndexPath indexPath: IndexPath) -> TodoItemListModel {
        
        guard let todoItem = getTodoItem(atIndexPath: indexPath) else {
            fatalError()
        }
        
        let textColor: UIColor = indexPath.row % 2 == 0 ? #colorLiteral(red: 0.5490196078, green: 0.7764705882, blue: 0.2901960784, alpha: 1) : #colorLiteral(red: 0.9647058824, green: 0.6901960784, blue: 0.0431372549, alpha: 1)
        let completeButtonColor = todoItem.priority.color
        
        let checkBoxAction: ((RoundedCheckBoxButton) -> ())? = { checkBox in
            
            let currentList: TaskType = todoItem.isCompleted ? .completed: .pending
            let newList: TaskType = currentList == .pending ? .completed : .pending
            
            checkBox.toggle()
            todoItem.isCompleted = checkBox.isChecked
            
            self.remoteDatabase.changeCompletionStatus(ForTodoItem: todoItem, at: currentList)
            self.remoteDatabase.deleteTodoItem(todoItem, atIndex: indexPath.item, from: currentList) { (didComplete) in
                self.remoteDatabase.saveTodoItem(todoItem, to: newList)
            }
            
        } // checkBoxAction closure ends ...
        
        return TodoItemListModel(name: todoItem.name,
                                 textColor: textColor,
                                 completeButtonColor: completeButtonColor,
                                 isCompleted: todoItem.isCompleted,
                                 checkBoxAction: checkBoxAction)
    }
    
}

extension TodoListViewModel: TodoItemListViewDbDelegate {
    
    func todoItemPositionDidChange(from sourceIndex: Int, to destinationIndex: Int,
                                   taskType: TaskType) {
        //        if lastSourceIndex == sourceIndex && lastDestinationIndex == destinationIndex  { return }
        let sourceIndexPath = IndexPath(row: sourceIndex, section: 0)
        let destinationIndexPath = IndexPath(row: destinationIndex, section: 0)
        invokeDelegateActionIfCurrentTaskType(is: taskType) {
            $0.moveItem(at: sourceIndexPath, to: destinationIndexPath)
        }
    }
    
    func todoItemListViewDbDelegate(positions: [String], taskType: TaskType) {
        getTaskDataSource(for: taskType).todoItemsPositions = positions
    }
    
    func todoItemListViewDbDelegate(didAddTodoItem newTodoItem: TodoItem, taskType: TaskType) {
        
        let taskDataSource = getTaskDataSource(for: taskType)
        taskDataSource.documentIDTodoItemMap[newTodoItem.documentID] = newTodoItem
        
        let indexPathToInsert = IndexPath(item: getTotalCount() - 1, section: 0)
        let indexPathToScroll = IndexPath(item: getTotalCount() - 2, section: 0)
        
        invokeDelegateActionIfCurrentTaskType(is: taskType) {
            $0.appendItem(newTodoItem, atIndexPath: indexPathToInsert)
            $0.scrollToItem(atIndexPath: indexPathToScroll)
        }
    }
    
    
    func didDeletePositionForTodoItem(atIndex index: Int, taskType: TaskType) {
        getTaskDataSource(for: taskType).indexPathToDelete = IndexPath(row: index, section: 0)
    }
    
    
    func todoItemListViewDbDelegate(didDeleteTodoItem deletedTodoItem: TodoItem, taskType: TaskType) {
        
        let taskDataSource = getTaskDataSource(for: taskType)
        taskDataSource.documentIDTodoItemMap[deletedTodoItem.documentID] = nil
        
        var indexPathToDelete: IndexPath!
        
        for (indexPath, documentID) in taskDataSource.indexPathDocumentIDMap {
            guard documentID == deletedTodoItem.documentID else { continue }
            indexPathToDelete = indexPath
        }
        
        guard indexPathToDelete != nil else {
            Logger.log(reason: "Delete failed! IndexPath to delete was not found! Reloading all items!")
            delegate.reloadAllItems()
            return
        }
        
        invokeDelegateActionIfCurrentTaskType(is: taskType) {
            $0.deleteItem(atIndexPath: indexPathToDelete)
        }
    }
    
    func todoItemListViewDbDelegate(didUpdateTodoItem updatedTodoItem: TodoItem, taskType: TaskType) {
        
        let taskDataSource = getTaskDataSource(for: taskType)
        let todoItemsPositions = getTodoItemPositions(for: taskType)
        
        taskDataSource.documentIDTodoItemMap[updatedTodoItem.documentID] = updatedTodoItem
        
        guard let indexForUpdatedTodoItem = todoItemsPositions.firstIndex(of: updatedTodoItem.documentID) else {
            Logger.log(reason: "Failed to update todoItem \(updatedTodoItem) !")
            return
        }
        
        invokeDelegateActionIfCurrentTaskType(is: taskType) {
            let indexPathToUpdate = IndexPath(row: indexForUpdatedTodoItem, section: 0)
            $0.reloadItem(atIndexPath: indexPathToUpdate)
        }
    }
    
}

// MARK:- Helper Methods

extension TodoListViewModel {
    
    func getTaskDataSource(for taskType: TaskType) -> TodoListVCModel {
        return taskType == .pending ? self.pendingTasks : self.completedTasks
    }
    
    func invokeDelegateActionIfCurrentTaskType(is taskType: TaskType,
                                               action: (TodoListViewModelDelegate) -> ()) {
        guard taskType == currentTaskType else { return }
        action(delegate)
    }
    
    func getTodoItemPositions(for taskType: TaskType) -> [String] {
        return getTaskDataSource(for: taskType).todoItemsPositions
    }
    
}
