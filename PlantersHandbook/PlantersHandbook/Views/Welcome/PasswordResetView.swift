//
//  PasswordResetView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit

class PasswordResetView: GeneralViewController {
    
    internal let icon : UIImageView = UIImageView(image: UIImage(named: "icons8-oak-tree-64.png"))
    internal let passwordRecoveryTitleLabel = SUI_Label(title: "Password Recovery", fontSize: FontSize.extraLarge)
    internal let passwordRecoveryInfoMessage = SUI_TextView_MultiLine(text: "A email will be sent with a link to renew your password", fontSize: FontSize.medium)
    internal let emailTextField = SUI_TextField_Form(placeholder: "email", textType: .emailAddress)
    internal let sendButton = PH_Button(title: "Send", fontSize: FontSize.large)
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        keyboardMoveUpWhenTextFieldTouched = 150
    }
    
    internal override func setUpTitleLayout() {
        super.setUpTitleLayout()
        let titleLayoutFrame = titleLayout.safeAreaFrame
        
        [icon, passwordRecoveryTitleLabel].forEach{titleLayout.addSubview($0)}
        icon.anchor(top: titleLayout.topAnchor, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayoutFrame.height*0.4, height: titleLayoutFrame.height*0.4))
        icon.anchorCenterX(to: titleLayout)
        
        passwordRecoveryTitleLabel.anchor(top: icon.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0),size: .init(width: titleLayoutFrame.width, height: titleLayoutFrame.height*0.4))
        passwordRecoveryTitleLabel.anchorCenterX(to: titleLayout)
    }
    
    internal override func setUpInfoLayout() {
        super.setUpInfoLayout()
        let infoLayoutFrame = infoLayout.safeAreaFrame
        let textFieldBoundarySpace = CGFloat(20)
        
        [passwordRecoveryInfoMessage, emailTextField, sendButton].forEach{infoLayout.addSubview($0)}
        
        passwordRecoveryInfoMessage.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 5, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        
        emailTextField.anchor(top: passwordRecoveryInfoMessage.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 5, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        
        sendButton.anchor(top: nil, leading: infoLayout.leadingAnchor, bottom: infoLayout.bottomAnchor, trailing: infoLayout.trailingAnchor, padding: .init(top: 0, left: infoLayoutFrame.width*0.3, bottom: infoLayoutFrame.height*0.4, right: infoLayoutFrame.width*0.3),size: .init(width: 0, height: 0))
    }
    
}
