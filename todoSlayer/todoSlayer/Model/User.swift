//
//  User.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 01/12/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import Firebase

struct App {
    struct User: Codable {
        let ID: String
        let name: String?
        let emailID: String?
        let photoURL: URL?
        // This field is only accessible on the server and is present since its a part of user JSON
        private let deviceTokens = [String]()
    }
}

extension App.User {
    static func get(using firebaseUser: User) -> App.User {
        return App.User(ID: firebaseUser.uid,
                        name: firebaseUser.displayName,
                        emailID: firebaseUser.email,
                        photoURL: firebaseUser.photoURL)
    }
}
