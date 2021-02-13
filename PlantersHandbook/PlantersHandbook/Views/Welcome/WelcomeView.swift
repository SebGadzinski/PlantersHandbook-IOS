//
//  WelcomeView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit
import Foundation
import RealmSwift

class WelcomeView: ProgramicVC {
    
    internal let icon : UIImageView = UIImageView(image: UIImage(named: "icons8-oak-tree-64.png"))
    internal let signUpButton = PH_Button(title: "SignUp", fontSize: FontSize.large)
    internal let loginButton = PH_Button(title: "Login", fontSize: FontSize.large)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func configureViews() {
        [icon, signUpButton, loginButton].forEach{backgroundView.addSubview($0)}
        
        icon.anchor(top: backgroundView.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 150, left: 0, bottom: 0, right: 0))
        icon.anchorCenterX(to: backgroundView)
        icon.anchorSize(size: CGSize(width: frame.width/2, height: frame.width/2))
        
        signUpButton.anchor(top: icon.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 100, left: 0, bottom: 0, right: 0), size: .init(width: frame.width*0.5, height: frame.width*0.2))
        signUpButton.anchorCenterX(to: backgroundView)
        signUpButton.titleLabel?.textColor = .systemGreen
        
        loginButton.anchor(top: signUpButton.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 20, left: 0, bottom: 0, right: 0), size: .init(width: frame.width*0.5, height: frame.width*0.2))
        loginButton.anchorCenterX(to: backgroundView)
        loginButton.titleLabel?.textColor = .systemGreen
    }

}
