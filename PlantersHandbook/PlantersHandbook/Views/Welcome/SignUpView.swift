//
//  SignUpView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit
import UnderLineTextField
import RealmSwift

class SignUpView: GeneralViewController {
    
    internal let icon : UIImageView = UIImageView(image: UIImage(named: "icons8-oak-tree-64.png"))
    internal let signUpTitleLabel = SUI_Label(title: "Sign Up", fontSize: FontSize.extraLarge)
    internal let emailTextField = SUI_TextField_Form(placeholder: "email", textType: .emailAddress)
    internal let passwordTextField = SUI_TextField_Form(placeholder: "password", textType: .newPassword)
    internal let passwordConfirmTextField = SUI_TextField_Form(placeholder: "confirm password", textType: .password)
    internal let signUpButton = PH_Button(title: "Sign Up!", fontSize: FontSize.large)
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        keyboardMoveUpWhenTextFieldTouched = 150
    }

    internal override func setUpTitleLayout() {
        super.setUpTitleLayout()
        let titleLayoutFrame = titleLayout.safeAreaFrame
        
        [icon, signUpTitleLabel].forEach{titleLayout.addSubview($0)}
        icon.anchor(top: titleLayout.topAnchor, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayoutFrame.height*0.4, height: titleLayoutFrame.height*0.4))
        icon.anchorCenterX(to: titleLayout)
        
        signUpTitleLabel.anchor(top: icon.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0),size: .init(width: titleLayoutFrame.width, height: titleLayoutFrame.height*0.4))
        signUpTitleLabel.anchorCenterX(to: titleLayout)
    }
    
    internal override func setUpInfoLayout() {
        super.setUpInfoLayout()
        let infoLayoutFrame = infoLayout.safeAreaFrame
        let textFieldBoundarySpace = CGFloat(20)
        
        [emailTextField, passwordTextField, passwordConfirmTextField, signUpButton].forEach{infoLayout.addSubview($0)}
        
        emailTextField.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 5, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        
        passwordTextField.anchor(top: emailTextField.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 5, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        
        passwordConfirmTextField.anchor(top: passwordTextField.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 5, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        
        signUpButton.anchor(top: nil, leading: infoLayout.leadingAnchor, bottom: infoLayout.bottomAnchor, trailing: infoLayout.trailingAnchor, padding: .init(top: 0, left: infoLayoutFrame.width*0.3, bottom: infoLayoutFrame.height*0.2, right: infoLayoutFrame.width*0.3),size: .init(width: 0, height: infoLayoutFrame.height*0.1))
        
    }

}
