//
//  WelcomeViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import Foundation
import RealmSwift

class WelcomeVC: ProgramicVC{
    
    fileprivate let icon : UIImageView = UIImageView(image: UIImage(named: "icons8-oak-tree-64.png"))
    fileprivate let signUpButton = ph_button(title: "SignUp", fontSize: FontSize.large)
    fileprivate let loginButton = ph_button(title: "Login", fontSize: FontSize.large)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func configureViews() {
        [icon, signUpButton, loginButton].forEach{bgView.addSubview($0)}
        
        icon.anchor(top: bgView.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 150, left: 0, bottom: 0, right: 0))
        icon.anchorCenterX(to: bgView)
        icon.anchorSize(size: CGSize(width: frame.width/2, height: frame.width/2))
        
        signUpButton.anchor(top: icon.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 100, left: 0, bottom: 0, right: 0), size: .init(width: frame.width*0.5, height: frame.width*0.2))
        signUpButton.anchorCenterX(to: bgView)
        signUpButton.titleLabel?.textColor = .systemGreen
        
        loginButton.anchor(top: signUpButton.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 20, left: 0, bottom: 0, right: 0), size: .init(width: frame.width*0.5, height: frame.width*0.2))
        loginButton.anchorCenterX(to: bgView)
        loginButton.titleLabel?.textColor = .systemGreen
    }
    
    override func setActions() {
        signUpButton.addTarget(self, action: #selector(signInAction), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
    }
    
    @objc func signInAction(){
        print("Sign In")
        let vc = SignUpVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func loginAction(){
        print("Login")
        let vc = LoginVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }

}




