//
//  AppViewModel.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 09/11/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import Foundation
import FirebaseAuth

class AppEntryViewModel {
    
    enum Action {
        case startAppFlow(RootViewController)
        case loginSuccess(RootViewController)
        case deviceTokenResult(DeviceTokenResult)
        case testNotificationCreation
    }
    
    private let remoteDatabase: DeviceTokenService & LoginService = {
        return FirebaseLayer()
    }()
    
    private let appSession: MutableAppSession
    
    init(session: MutableAppSession = AppSession.shared.getMutableVersion()) {
        self.appSession = session
    }
    
    func handle(_ action: Action) {
        switch action {
        case .startAppFlow(let rootViewController):
            handleAppFlow(using: rootViewController)
            
        case .loginSuccess(let rootViewController):
            handleAppFlow(using: rootViewController)
            
        case .deviceTokenResult(let result):
            handleDeviceTokenResult(result)
            
        case .testNotificationCreation:
            createNotification()
        }
    }
}


extension AppEntryViewModel {
    fileprivate typealias didSetCurrentUser = Bool
    
    private func handleAppFlow(using rootViewController: RootViewController) {
        guard trySettingCurrentUser(using: rootViewController) else { return }
        registerForPushNotifications()
        
        // When the user has permitted for push notifications,
        if let deviceToken = AppSession.shared.deviceToken {
            remoteDatabase.storeDeviceToken(token: deviceToken,
                                            underUserID: AppSession.shared.currentUser.ID)
        }
        rootViewController.showHomeScreen()
    }
    
    private func trySettingCurrentUser(using rootViewController: RootViewController) -> didSetCurrentUser {
        // if user logged in, load into session
        // else prompt user for credentials
        if let firebaseUser = Auth.auth().currentUser {
            AppSession.shared.getMutableVersion().setCurrentUser(App.User.get(using: firebaseUser))
            return true
        } else {
            rootViewController.showLoginScreen()
            return false
        }
    }
}

extension AppEntryViewModel {
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
    
    private func createNotification() {
        let content = UNMutableNotificationContent()
        content.title = "my first notification! 30 sec bruhh!"
        content.body = "Vanakam da mapla app la irundhu!"
        content.badge = 2
        content.sound = .init(UNNotificationSound.default)
        
        let dateNow = Date(timeIntervalSinceNow: 30)
        let dateComponents = Calendar.current.dateComponents([Calendar.Component.minute,
                                                              Calendar.Component.second], from: dateNow)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            guard error == nil else {
                print("Error occured \(String(describing: error))")
                return
            }
            print("Posted mann!")
        }
    }
}

extension AppEntryViewModel {
    enum DeviceTokenResult{
        case success(String)
        case failure(Error)
    }
    
    // TOKEN SAVE MECHANISM
    // FCM delivers the token whenever it likes regardless of whether the user is logged in or
    // has enabled push notifications. We need to associate this token with a user. We do this in either of the 2 ways
    // 1) When token arrives, we check if current user is set. If yes, we save it to user details else we save it to App Session
    // 2) When user logs in, we check for any saved tokens in App Session. If found, we save it to user details
    private func handleDeviceTokenResult(_ result: DeviceTokenResult) {
        switch result {
        case .success(let token):
            appSession.setDeviceToken(token)
            guard let userID = AppSession.shared.currentUser?.ID else { return }
            Logger.log(reason: "Token was refreshed! Saving to server!")
            remoteDatabase.storeDeviceToken(token: token, underUserID: userID)
            
        case .failure(let error):
            Logger.log(reason: "Failed to register for remote notifications! \(error)")
        }
    }
}

extension AppEntryViewModel: LoginInfoHandler {
    func saveUser(_ user: App.User) {
        guard let userJSON = user.json else {
            Logger.log(reason: "Failed to get userJSON from AppUser!")
            return
        }
        remoteDatabase.storeUser(userJSON, userID: user.ID)
    }
}
