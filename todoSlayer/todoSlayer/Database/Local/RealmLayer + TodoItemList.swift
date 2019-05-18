////
////  RealmLayer + TodoItemList.swift
////  todoSlayer
////
////  Created by Kalyani shiva on 12/05/19.
////  Copyright © 2019 Kalyani shiva. All rights reserved.
////
//
//import Foundation
//import RealmSwift
//
//extension RealmLayer: TodoItemListViewDbAPI {
//    
//    var todoItemListViewDelegate: TodoItemListViewDbDelegate? {
//        get {
//            <#code#>
//        }
//        set {
//            <#code#>
//        }
//    }
//    
//    
//    func getAllTodoItems() -> [TodoItem] {
//        if let allTodoItems = allTodoItems {
//            return convertToTodoItems(allTodoItems)
//        }
//        allTodoItems = realm.objects(TodoItem.self)
//        return getAllTodoItems()
//    }
//    
//    private func convertToTodoItems(_ results: Results<TodoItem>) -> [TodoItem] {
//        return results.map { (todoItem) -> TodoItem in
//            return todoItem
//        }
//    }
//}
