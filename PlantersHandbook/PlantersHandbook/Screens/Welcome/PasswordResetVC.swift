//
//  PasswordResetVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-09.
//

import UIKit
import UnderLineTextField
import JDropDownAlert

class PasswordResetVC: ProgramicVC {
    fileprivate var titleLayout : UIView!
    fileprivate var infoLayout : UIView!
    
    fileprivate let icon : UIImageView = UIImageView(image: UIImage(named: "icons8-oak-tree-64.png"))
    fileprivate let passwordRecoveryTitleLabel = SUI_Label(title: "Password Recovery", fontSize: FontSize.extraLarge)
    fileprivate let passwordRecoveryInfoMessage = SUI_TextView_MultiLine(text: "A email will be sent with a link to renew your password", fontSize: FontSize.meduim)
    fileprivate let emailTextField = SUI_TextField_Form(placeholder: "email", textType: .emailAddress)
    fileprivate let sendButton = PH_Button(title: "Send", fontSize: FontSize.large)
    fileprivate let emailGivenFromLogin : String
    fileprivate var credientialsGiven = false

        
    init(emailGivenFromLogin: String) {
        self.emailGivenFromLogin = emailGivenFromLogin
        
        super.init(nibName: nil, bundle: nil)
        
        self.credientialsGiven = true
    }
    
    init(){
        self.emailGivenFromLogin = ""
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var email: String? {
        get {
            return emailTextField.text
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(credientialsGiven){
            
            emailTextField.text = emailGivenFromLogin
            
        }
        else{
            emailTextField.text = "seb.gadzinski@gmail.com"
        }
    }
    
    override func generateLayout() {
        titleLayout = SUI_View(backgoundColor: .systemBackground)
        infoLayout = SUI_View(backgoundColor: .systemBackground)
    }
    
    override func configureViews() {
        setUpOverlay()
        setUpTitleLayout()
        setUpInfoLayout()
    }
    
    override func setActions() {
        sendButton.addTarget(self, action: #selector(recoverPassword), for: .touchUpInside)
    }
    
    func setUpOverlay() {
        [titleLayout, infoLayout].forEach{bgView.addSubview($0)}
        
        print(frame.size)
        
        titleLayout.anchor(top: bgView.topAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.25))
        infoLayout.anchor(top: titleLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor,size: .init(width: frame.width, height: frame.height*0.7))
    }
    
    func setUpTitleLayout() {
        let titleLayoutFrame = titleLayout.safeAreaFrame
        
        [icon, passwordRecoveryTitleLabel].forEach{titleLayout.addSubview($0)}
        icon.anchor(top: titleLayout.topAnchor, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayoutFrame.height*0.4, height: titleLayoutFrame.height*0.4))
        icon.anchorCenterX(to: titleLayout)
        
        passwordRecoveryTitleLabel.anchor(top: icon.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0),size: .init(width: titleLayoutFrame.width, height: titleLayoutFrame.height*0.4))
        passwordRecoveryTitleLabel.anchorCenterX(to: titleLayout)
    }
    
    func setUpInfoLayout() {
        let infoLayoutFrame = infoLayout.safeAreaFrame
        let textFieldBoundarySpace = CGFloat(20)
        
        [passwordRecoveryInfoMessage, emailTextField, sendButton].forEach{infoLayout.addSubview($0)}
        
        passwordRecoveryInfoMessage.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 5, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        
        emailTextField.anchor(top: passwordRecoveryInfoMessage.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 5, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        emailTextField.delegate = self
        
        sendButton.anchor(top: nil, leading: infoLayout.leadingAnchor, bottom: infoLayout.bottomAnchor, trailing: infoLayout.trailingAnchor, padding: .init(top: 0, left: infoLayoutFrame.width*0.3, bottom: infoLayoutFrame.height*0.4, right: infoLayoutFrame.width*0.3),size: .init(width: 0, height: 0))
    }

    @objc func recoverPassword(){
        app.emailPasswordAuth.sendResetPasswordEmail(email!){ [weak self](error) in
            
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Reset password email not sent: \(error!.localizedDescription)")
                    return
                }
            
            let alertController = UIAlertController(title: "Reset Password Email Sent", message: "Email sent to \(self!.email!)", preferredStyle: .alert)
            let ReturnToLoginAction = UIAlertAction(title: "Return To Login", style: .default) {
                UIAlertAction in
                self!.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(ReturnToLoginAction)
            self!.present(alertController, animated: true, completion: nil)
                
            }
        }
    }

}

extension PasswordResetVC: UnderLineTextFieldDelegate{
    func textFieldValidate(underLineTextField: UnderLineTextField) throws {
        let result : String = emailValidator(email: emailTextField.text!)
        if result != "Success"{
            throw UnderLineTextFieldErrors
                .error(message: result)
        }
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField is UnderLineTextField{
            let goodTextField = textField as! UnderLineTextField
            goodTextField.status = .normal
        }
        return true
    }
}
