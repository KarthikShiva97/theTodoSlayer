//
//  FirebaseLayer+TokenManagement.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 09/11/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation

extension FirebaseLayer: DeviceTokenManager {
    func storeDeviceToken(token: String, forPlatform platform: AppViewModel.Platform) {
        firebase.collection(deviceTokensPath).document(token).setData([
            ListConstants.DeviceToken.id: token,
            ListConstants.DeviceToken.platform: platform
        ])
    }
}
