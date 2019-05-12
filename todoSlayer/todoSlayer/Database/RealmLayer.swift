//
//  Realm.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 12/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import RealmSwift

class RealmLayer {
    let realm: Realm = {
        return try! Realm()
    }()
}
