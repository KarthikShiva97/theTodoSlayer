//
//  TodoListViewModel.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 09/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

struct TodoItemListModel: Hashable {
    let ID: String
    let name: String
    let textColor: UIColor
    let completeButtonColor: UIColor
    let isCompleted: Bool
    let checkBoxAction: ((RoundedCheckBoxButton)->())?
    
    static func == (lhs: TodoItemListModel, rhs: TodoItemListModel) -> Bool {
        return (lhs.ID == rhs.ID) &&
            (lhs.name == rhs.name) &&
            (lhs.completeButtonColor == rhs.completeButtonColor)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ID)
    }
    
}

protocol TodoListViewModelDelegate: class {
    var dataSource: UICollectionViewDiffableDataSource<TodoItemSection, TodoItemListModel> { get set }
    func stopRefreshing()
    func scrollToItem(atIndexPath indexPath: IndexPath)
    func openTodoDetailVC(withMode mode: TodoDetailVC.Mode)
    func showLoading()
    func hideLoading()
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

enum SortOption {
    case name
    case priority
    case manual
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
            loadData(shouldAnimate: false)
        }
    }
    
    init(delegate: TodoListViewModelDelegate) {
        self.delegate = delegate
        self.currentTaskDataSource = pendingTasks
    }
}

// MARK:- Public API's
extension TodoListViewModel {
    
//    var shouldShowLoading() {
//
//    }
    
    func sortBy(_ sortOption: SortOption) {
        var newTodoItemPositions = [String]()
        
        switch sortOption {
            
        case .name:
            newTodoItemPositions = currentTaskDataSource.todoItems.sorted {
                $0.name < $1.name
            }.map { $0.documentID }
            
        case .priority:
            newTodoItemPositions = currentTaskDataSource.todoItems.sorted {
                $0.priority.rawValue < $1.priority.rawValue
            }.map { $0.documentID }
            
        default:
            Logger.log(reason: "unknown sort order!")
            
        }
        
        currentTaskDataSource.todoItemsPositions = newTodoItemPositions
        currentTaskDataSource.sortByPosition()
        loadData(shouldAnimate: true)
        
        remoteDatabase.updateTodoListPositions(positions: currentTaskDataSource.todoItemsPositions,
                                               taskType: currentTaskType)
    }
    
    func setCurrentTaskType(to taskType: TaskType) {
        guard taskType != currentTaskType else { return }
        self.currentTaskType = taskType
    }
    
    func refresh() {
        beginDataSetup()
    }
    
    func getDragItem(atIndexPath indexPath: IndexPath) -> [UIDragItem] {
        let todoItem = currentTaskDataSource.todoItems[indexPath.item]
        let itemProvider = NSItemProvider()
        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) {
            completion in
            let data = todoItem.name.data(using: .utf8)
            completion(data, nil)
            return nil
        }
        return [UIDragItem(itemProvider: itemProvider)]
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
        
        currentTaskDataSource.sortByPosition()
        
    }
    
    func didSelectItem(atIndexPath indexPath: IndexPath) {
        let todoItem = currentTaskDataSource.todoItems[indexPath.item]
        delegate?.openTodoDetailVC(withMode: .existingTodoItem(todoItem, indexPath))
    }
    
    func didSelectAddButton() {
        delegate?.openTodoDetailVC(withMode: .newTodoItem)
    }
    
    
    func getTodoItemName(atIndexPath indexPath: IndexPath) -> String {
        return currentTaskDataSource.todoItems[indexPath.item].name
    }
    
    
    func screenDidLoad() {
        beginDataSetup()
    }
    
    func didLeaveScreen() {
        remoteDatabase.clearLastPositionChanges()
        remoteDatabase.detachListener()
    }
    
}

extension TodoListViewModel {
    
    private func beginDataSetup() {
        delegate.showLoading()
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
                $0.hideLoading()
                $0.stopRefreshing()
                self.loadData(shouldAnimate: false)
            }
        }
    }
    
    private func loadData(shouldAnimate: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<TodoItemSection, TodoItemListModel>()
        snapshot.appendSections([TodoItemSection.zero])
        let items = getTodoItemListModel(forTodoItems: currentTaskDataSource.todoItems)
        snapshot.appendItems(items)
        delegate.dataSource.apply(snapshot, animatingDifferences: shouldAnimate)
    }
    
    
    func getTodoItemListModel(forTodoItems todoItems: [TodoItem]) -> [TodoItemListModel] {
        
        var todoItemListModels = [TodoItemListModel]()
        
        for (index, todoItem) in todoItems.enumerated() {
            
            let textColor: UIColor = index % 2 == 0 ? #colorLiteral(red: 0.5490196078, green: 0.7764705882, blue: 0.2901960784, alpha: 1) : #colorLiteral(red: 0.9647058824, green: 0.6901960784, blue: 0.0431372549, alpha: 1)
            let completeButtonColor = todoItem.priority.color
            
            let checkBoxAction: ((RoundedCheckBoxButton) -> ())? = { checkBox in
                
                let currentTaskType: TaskType = todoItem.isCompleted ? .completed: .pending
                let newTaskType: TaskType = currentTaskType == .pending ? .completed : .pending
                
                checkBox.toggle()
                todoItem.isCompleted = checkBox.isChecked
                
                self.remoteDatabase.moveTodoItem(todoItem: todoItem,
                                                 currentTaskType: currentTaskType,
                                                 newTaskType: newTaskType,
                                                 index: index,
                                                 onCompletion: nil)
                
            } // checkBoxAction closure ends ...
            
            let todoItemListModel = TodoItemListModel(ID: todoItem.ID,
                                                      name: todoItem.name,
                                                      textColor: textColor,
                                                      completeButtonColor: completeButtonColor,
                                                      isCompleted: todoItem.isCompleted,
                                                      checkBoxAction: checkBoxAction)
            
            todoItemListModels.append(todoItemListModel)
            
        } // loop ends ...
        
        return todoItemListModels
        
    }// func ends ..
    
}

// MARK:- Listener Delegate Methods
extension TodoListViewModel: TodoItemListViewDbDelegate {

    func todoItemPositionDidChange(from sourceIndex: Int, to destinationIndex: Int,
                                   taskType: TaskType) {
        getTaskDataSource(for: taskType).sortByPosition()
        loadDataIfCurrentTaskType(is: taskType)
    }
    
    func todoItemListViewDbDelegate(positions: [String], taskType: TaskType, isSortOperation: Bool) {
        let taskDataSource = getTaskDataSource(for: taskType)
        taskDataSource.todoItemsPositions = positions
        
        guard isSortOperation else { return }
        currentTaskDataSource.sortByPosition()
        loadData(shouldAnimate: true)
    }
    
    func todoItemListViewDbDelegate(didAddTodoItem newTodoItem: TodoItem, taskType: TaskType) {
        let taskDataSource = getTaskDataSource(for: taskType)
        taskDataSource.todoItems.append(newTodoItem)
        
        loadDataIfCurrentTaskType(is: taskType)
        
        invokeDelegateActionIfCurrentTaskType(is: taskType) {
            let totalItemCount = currentTaskDataSource.todoItems.count - 2
            let indexPathToScroll = IndexPath(item: totalItemCount, section: 0)
            $0.scrollToItem(atIndexPath: indexPathToScroll)
        }
    }
    
    
    func didDeletePositionForTodoItem(atIndex index: Int, taskType: TaskType) {
        //        getTaskDataSource(for: taskType).indexPathToDelete = IndexPath(row: index, section: 0)
    }
    
    
    func todoItemListViewDbDelegate(didDeleteTodoItem deletedTodoItem: TodoItem, taskType: TaskType) {
        
        let taskDataSource = getTaskDataSource(for: taskType)
        
        taskDataSource.todoItems.removeAll { (todoItem) -> Bool in
            return todoItem.ID == deletedTodoItem.ID
        }
        
        loadDataIfCurrentTaskType(is: taskType)
    }
    
    func todoItemListViewDbDelegate(didUpdateTodoItem updatedTodoItem: TodoItem, taskType: TaskType) {
        
        let taskDataSource = getTaskDataSource(for: taskType)
        
        taskDataSource.todoItems = taskDataSource.todoItems.map { (todoItem) -> TodoItem in
            guard todoItem.ID == updatedTodoItem.ID else { return todoItem }
            return updatedTodoItem
        }
        
        loadDataIfCurrentTaskType(is: taskType)
        
    } // func ends ...
    
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
    
    func loadDataIfCurrentTaskType(is taskType: TaskType) {
        guard currentTaskType == taskType else { return }
        self.loadData(shouldAnimate: true)
    }
    
}
