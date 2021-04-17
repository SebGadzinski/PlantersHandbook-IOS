//
//  WelcomeViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import Foundation
import RealmSwift

///WelcomeViewController.swift - Welcome page
class WelcomeViewController: WelcomeView{
    
    ///Set all actions in progrmaic view controller
    internal override func setActions() {
        signUpButton.addTarget(self, action: #selector(signInAction), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
    }
    
    ///Signs the user into the application
    @objc fileprivate func signInAction(){
        print("Sign In")
        let vc = SignUpViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    ///Logs user out from application and brings them back to the homescreen
    @objc fileprivate func loginAction(){
        print("Login")
        let vc = LoginViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

}




