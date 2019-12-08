//
//  Session.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 01/12/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import FirebaseAuth

protocol ImmutableAppSession {
    static var shared: ImmutableAppSession { get }
    func getMutableVersion() -> MutableAppSession
    var deviceToken: String! { get }
    var currentUser: App.User! { get }
}

extension ImmutableAppSession {
    func getMutableVersion() -> MutableAppSession {
        return Self.shared as! MutableAppSession
    }
}

protocol MutableAppSession {
    func setDeviceToken(_ token: String)
    func setCurrentUser(_ user: App.User)
}

class AppSession: ImmutableAppSession {
    private (set) var currentUser: App.User!
    private (set) var deviceToken: String!
    
    static let shared: ImmutableAppSession = AppSession()
    private init(){}
}

extension AppSession: MutableAppSession {
    func setDeviceToken(_ token: String) {
        self.deviceToken = token
    }
    func setCurrentUser(_ user: App.User) {
        self.currentUser = user
    }
}
