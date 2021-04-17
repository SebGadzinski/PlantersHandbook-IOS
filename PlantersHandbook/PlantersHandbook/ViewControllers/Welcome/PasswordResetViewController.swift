//
//  PasswordResetVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-09.
//

import UIKit
import UnderLineTextField
import JDropDownAlert

///PasswordResetViewController.swift - Recover password page
class PasswordResetViewController: PasswordResetView {
    fileprivate let emailGivenFromLogin : String
    fileprivate var credientialsGiven = false
    fileprivate var email: String? {
        get {
            return emailTextField.text
        }
    }

    ///Contructor that contains the email that was fiven from login and presets the emailTextField
    init(emailGivenFromLogin: String) {
        self.emailGivenFromLogin = emailGivenFromLogin
        super.init(nibName: nil, bundle: nil)
        self.credientialsGiven = true
    }
    
    ///Contructor that initalizes required fields
    init(){
        self.emailGivenFromLogin = ""
        super.init(nibName: nil, bundle: nil)
    }
    
    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Functionality for when view will appear
    ///- Parameter animated: Boolean to decide if view will apear with anination or not
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.text = (credientialsGiven ? emailGivenFromLogin : "seb.gadzinski@gmail.com")
        emailTextField.delegate = self
    }

    ///Set all actions in progrmaic view controller
    internal override func setActions() {
        sendButton.addTarget(self, action: #selector(recoverPassword), for: .touchUpInside)
    }

    ///Sends a recover password email to the users email
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

///Functionality required for using UnderLineTextFieldDelegate
extension PasswordResetViewController: UnderLineTextFieldDelegate{
    ///Validates input given into UnderLineTextField
    ///- Parameter underLineTextField: UnderLineTextField to be validated
    func textFieldValidate(underLineTextField: UnderLineTextField) throws {
        let result : String = Validation.emailValidator(email: emailTextField.text!)
        if result != "Success"{
            throw UnderLineTextFieldErrors
                .error(message: result)
        }
    }
    ///Functionality for when UITextField should begin ediitng
    ///- Parameter textField: UITextField to be checked
    ///- Returns: True if editing should begin or false if it should not.
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField is UnderLineTextField{
            let goodTextField = textField as! UnderLineTextField
            goodTextField.status = .normal
        }
        return true
    }
}
