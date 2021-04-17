//
//  LoginView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit

///LoginView.swift - View for LoginViewController
class LoginView: GeneralView{
    
    internal let icon : UIImageView = UIImageView(image: UIImage(named: "icon.png"))
    internal let loginTitleLabel = SUI.label(title: "Login", fontSize: FontSize.extraLarge)
    internal let emailTextField = SUI.textFieldUnderlined(placeholder: "email", textType: .emailAddress)
    internal let passwordTextField = SUI.textFieldUnderlined(placeholder: "password", textType: .newPassword)
    internal let forgotPasswordLabel = SUI.label(title: "Forgot Password?", fontSize: FontSize.small)
    internal let loginButton = PHUI.button(title: "Login!", fontSize: FontSize.large)
    
    ///Called after the controller's view is loaded into memory.
    internal override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.accessibilityLabel = "password"
        keyboardMoveWhenTextFieldTouched = 150
    }

    ///Set up title layout within general view controller
    internal override func setUpTitleLayout() {
        super.setUpTitleLayout()
        let titleLayoutFrame = titleLayout.safeAreaFrame
        
        [icon, loginTitleLabel].forEach{titleLayout.addSubview($0)}
        icon.anchor(top: titleLayout.topAnchor, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayoutFrame.height*0.4, height: titleLayoutFrame.height*0.4))
        icon.anchorCenterX(to: titleLayout)
        
        loginTitleLabel.anchor(top: icon.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0),size: .init(width: titleLayoutFrame.width, height: titleLayoutFrame.height*0.4))
        loginTitleLabel.anchorCenterX(to: titleLayout)
    }
    
    ///Set up info layout within general view controller
    internal override func setUpInfoLayout() {
        super.setUpInfoLayout()
        let infoLayoutFrame = infoLayout.safeAreaFrame
        let textFieldBoundarySpace = CGFloat(20)
        
        [emailTextField, passwordTextField, forgotPasswordLabel, loginButton].forEach{infoLayout.addSubview($0)}
        
        emailTextField.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 5, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        emailTextField.tag = 0
        emailTextField.delegate = self
        emailTextField.autocorrectionType = .no
        
        passwordTextField.anchor(top: emailTextField.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 5, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        passwordTextField.tag = 1
        passwordTextField.delegate = self
        
        forgotPasswordLabel.anchor(top: passwordTextField.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 0), size: .init(width: infoLayoutFrame.width*0.6, height: infoLayoutFrame.height*0.1))
        forgotPasswordLabel.isUserInteractionEnabled = true

        
        loginButton.anchor(top: nil, leading: infoLayout.leadingAnchor, bottom: infoLayout.bottomAnchor, trailing: infoLayout.trailingAnchor, padding: .init(top: 0, left: infoLayoutFrame.width*0.3, bottom: infoLayoutFrame.height*0.4, right: infoLayoutFrame.width*0.3),size: .init(width: 0, height: 0))
        
    }

}

///Description
///- Parameter param:
///- Returns:
