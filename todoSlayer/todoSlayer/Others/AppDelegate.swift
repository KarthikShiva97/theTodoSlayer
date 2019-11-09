//
//  AppDelegate.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 05/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let viewModel = AppViewModel()
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let navigationController = UINavigationController(rootViewController: TodoListVC())
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        viewModel.handle(.registerForPushNotifications)
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        viewModel.handle(.handleDeviceTokenResult(.success(deviceToken)))
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        viewModel.handle(.handleDeviceTokenResult(.failure(error)))
    }
    
}

