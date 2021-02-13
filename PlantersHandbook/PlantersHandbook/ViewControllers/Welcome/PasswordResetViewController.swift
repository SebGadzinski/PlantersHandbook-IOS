//
//  PasswordResetVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-09.
//

import UIKit
import UnderLineTextField
import JDropDownAlert

class PasswordResetViewController: PasswordResetView {
    fileprivate let emailGivenFromLogin : String
    fileprivate var credientialsGiven = false
    fileprivate var email: String? {
        get {
            return emailTextField.text
        }
    }

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = (credientialsGiven ? emailGivenFromLogin : "seb.gadzinski@gmail.com")
        emailTextField.delegate = self
    }

    internal override func setActions() {
        sendButton.addTarget(self, action: #selector(recoverPassword), for: .touchUpInside)
    }

    @objc fileprivate func recoverPassword(){
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

extension PasswordResetViewController: UnderLineTextFieldDelegate{
    func textFieldValidate(underLineTextField: UnderLineTextField) throws {
        let result : String = Validation.emailValidator(email: emailTextField.text!)
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
