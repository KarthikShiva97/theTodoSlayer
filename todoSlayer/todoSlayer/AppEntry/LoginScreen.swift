//
//  LoginScreen.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 01/12/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import FirebaseUI

protocol LoginInfoHandler {
    func saveUser(_ user: App.User)
}

class LoginScreen: UIViewController, FUIAuthDelegate {
    private lazy var authUI: UIViewController? = {
        let authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        authUI?.providers = [FUIGoogleAuth()]
        return authUI?.authViewController()
    }()
    
    private let onLoginSuccess: (()->())
    private let viewModel: LoginInfoHandler
    
    init(viewModel: LoginInfoHandler, onLoginSuccess: @escaping ()->()) {
        self.viewModel = viewModel
        self.onLoginSuccess = onLoginSuccess
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        guard let authUI = authUI else { return }
        present(authUI, animated: true, completion: nil)
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        guard let firebaseUser = authDataResult?.user, error == nil else { return }
        let appUser = App.User.get(using: firebaseUser)
        AppSession.shared.getMutableVersion().setCurrentUser(appUser)
        viewModel.saveUser(appUser)
        onLoginSuccess()
    }
    
    private func getAppUser(using firebaseUser: User) -> App.User {
        return App.User(ID: firebaseUser.uid,
                        name: firebaseUser.displayName,
                        emailID: firebaseUser.email,
                        photoURL: firebaseUser.photoURL)
    }
}
