//
//  AppDelegate.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 05/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, RootViewNavigatorProvider {
    
    var window: UIWindow?
    var rootViewNavigator: RootViewNavigator!
    private lazy var viewModel = AppEntryViewModel()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        rootViewNavigator = RootViewController(viewModel: viewModel)
        startRootViewNavigator()
        return true
    }
}

// MARK:- Notification Handling
extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        viewModel.handle(.deviceTokenResult(.success(fcmToken)))
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        viewModel.handle(.deviceTokenResult(.failure(error)))
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("YEAAA brooo!")
    }
}
