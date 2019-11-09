//
//  AppViewModel.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 09/11/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import UIKit

class AppViewModel {
    
    enum Action {
        case registerForPushNotifications
        case handleDeviceTokenResult(DeviceTokenResult)
    }
    
    private let remoteDatabase: DeviceTokenManager = {
        return FirebaseLayer()
    }()
    
    func handle(_ action: Action) {
        switch action {
        case .registerForPushNotifications:
            registerForPushNotifications()
        case .handleDeviceTokenResult(let result):
            handleDeviceTokenResult(result)
        }
    }
}

extension AppViewModel {
    private func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { didGrantPermission, error in
            guard error == nil else { print("Failed to register for push notifications!", error ?? ""); return }
            guard didGrantPermission else { print("User denied permission for push notifications!"); return }
            self.checkIfCurrentlyAuthorized() { isAuthorized in
                guard isAuthorized else { print("User currenly is blocking push notifications!"); return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    private func checkIfCurrentlyAuthorized(onVerification: @escaping (Bool)->()) {
        UNUserNotificationCenter.current().getNotificationSettings() {
            onVerification($0.authorizationStatus == .authorized)
        }
    }
}

extension AppViewModel {
    enum DeviceTokenResult{
        case success(Data)
        case failure(Error)
    }
    
    enum Platform: String {
        case iOS
        case iPadOS
        case MacOS
    }
    
    private func getToken(from tokenData: Data) -> String {
        return tokenData.map { data in String(format: "%02.2hhx", data) }.joined()
    }
    
    private func handleDeviceTokenResult(_ result: DeviceTokenResult) {
        switch result {
        case .success(let tokenData):
            let token = getToken(from: tokenData)
            guard let platform = Platform(rawValue: UIDevice().systemName) else {
                Logger.log(reason: "Failed to store device token! Invalid platform \(UIDevice().systemName)")
                return
            }
            remoteDatabase.storeDeviceToken(token: token, forPlatform: platform)
        case .failure(let error):
            Logger.log(reason: "Failed to register for remote notifications! \(error)")
        }
    }
}
