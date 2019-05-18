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
        return Firestore.firestore()
    }()
    weak var todoItemListViewDelegate: TodoItemListViewDbDelegate?
}
