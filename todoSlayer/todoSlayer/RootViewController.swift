//
//  RootViewController.swift
//  
//
//  Created by Kalyani shiva on 24/11/19.
//

import UIKit
import FirebaseAuth

class RootViewController: UIViewController, RootViewNavigator {
    let viewModel: AppEntryViewModel
    var currentChildVC: UIViewController?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(viewModel: AppEntryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.handle(.startAppFlow(self))
    }
}

extension RootViewController {
    func showHomeScreen() {
        let navigationController = UINavigationController(rootViewController: HomeVC())
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        showChildVC(newVC: navigationController)
    }
    
    func showLoginScreen() {
        showChildVC(newVC: LoginScreen(viewModel: viewModel, onLoginSuccess: { [unowned self] in
            self.viewModel.handle(.loginSuccess(self))
        }))
    }
}
