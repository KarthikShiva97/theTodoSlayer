//
//  FirebaseLayer+LoginScreen.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 01/12/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Firebase

extension FirebaseLayer: LoginService {
    func storeUser(_ userJSON: [String : Any], userID: String) {
        firebase.collection(Constants.AppEntry.users.rawValue).document(userID).setData(userJSON, merge: true)
    }
    
    func doesUserExist(withID userID: String, onCompletion: @escaping (Bool)->()) {
        firebase.collection(Constants.AppEntry.users.rawValue).document(userID).getDocument { snapshot, _ in
            onCompletion(snapshot?.exists ?? false)
        }
    }
}
