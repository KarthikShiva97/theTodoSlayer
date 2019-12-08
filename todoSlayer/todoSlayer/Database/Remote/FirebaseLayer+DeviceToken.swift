//
//  FirebaseLayer+TokenManagement.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 09/11/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import FirebaseFirestore

extension FirebaseLayer: DeviceTokenService {
    func storeDeviceToken(token: String, underUserID userID: String) {
        let dict = [Constants.AppEntry.deviceTokens.rawValue: FieldValue.arrayUnion([token])]
        firebase.collection(Constants.AppEntry.users.rawValue).document(userID).updateData(dict) { error in
            guard error == nil else {
                Logger.log(reason: "Failed to update device token to server!")
                return
            }
        }
    }
}
