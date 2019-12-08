//
//  RootNavigator.swift
//  Created by Kalyani shiva on 04/02/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import UIKit

protocol RootViewNavigator: UIViewController  {
    var currentChildVC: UIViewController? { get set }
}

extension RootViewNavigator {
    
    func showChildVC(newVC: UIViewController) {
        removeCurrentChildVCIfAny()
        addChildVC(newVC)
        currentChildVC = newVC
    }
    
    func animateIntoNewChildVC(from oldChildVC: UIViewController,
                           to newChildVC: UIViewController,
                           withOptions: UIView.AnimationOptions,
                           duration: Double) {
        
        oldChildVC.willMove(toParent: nil)
        addChildVC(newChildVC)
        transition(from: oldChildVC, to: newChildVC, duration: duration, options: withOptions, animations: {
            oldChildVC.removeFromParent()
            newChildVC.didMove(toParent: self)
            self.currentChildVC = newChildVC
        }, completion: nil)
    }
    
    private func removeCurrentChildVCIfAny() {
        guard let currentChildVC = currentChildVC else { return }
        removeChildVC(currentChildVC)
    }
}

protocol RootViewNavigatorProvider: AppDelegate {
    var rootViewNavigator: RootViewNavigator!  { get set }
}

extension RootViewNavigatorProvider {
    func startRootViewNavigator() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootViewNavigator
        window?.makeKeyAndVisible()
    }
}

extension AppDelegate {
    fileprivate static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    static var rootViewNavigator: RootViewController {
        return ((UIApplication.shared.delegate as! RootViewNavigatorProvider).rootViewNavigator as! RootViewController)
    }
}
