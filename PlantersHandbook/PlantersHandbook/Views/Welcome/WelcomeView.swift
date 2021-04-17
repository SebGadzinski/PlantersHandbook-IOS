//
//  WelcomeView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit
import Foundation
import RealmSwift

///WelcomeView.swift - View for WelcomeViewController
class WelcomeView: ProgrammaticViewController {
    
    internal let icon : UIImageView = UIImageView(image: UIImage(named: "icon.png"))
    internal let signUpButton = PHUI.button(title: "SignUp", fontSize: FontSize.large)
    internal let loginButton = PHUI.button(title: "Login", fontSize: FontSize.large)
    
    ///Functionality for when view will appear
    ///- Parameter animated: Boolean to decide if view will apear with anination or not
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    ///Functionality for when view will disappear
    ///- Parameter animated: Boolean to decide if view will disappear with anination or not
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    ///Configuire all views in programic view controller
    override func configureViews() {
        [icon, signUpButton, loginButton].forEach{backgroundView.addSubview($0)}
        
        icon.anchor(top: backgroundView.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 100, left: 0, bottom: 0, right: 0))
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
