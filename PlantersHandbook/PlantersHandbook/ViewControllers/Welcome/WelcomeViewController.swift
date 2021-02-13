//
//  WelcomeViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import Foundation
import RealmSwift

class WelcomeViewController: WelcomeView{
    
    internal override func setActions() {
        signUpButton.addTarget(self, action: #selector(signInAction), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
    }
    
    @objc fileprivate func signInAction(){
        print("Sign In")
        let vc = SignUpViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc fileprivate func loginAction(){
        print("Login")
        let vc = LoginViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

}




