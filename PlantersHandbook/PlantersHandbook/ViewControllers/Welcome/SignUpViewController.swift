//
//  SignUpViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import SwiftSpinner
import JDropDownAlert
import UnderLineTextField

///SignUpViewController.swift - Sign up page
class SignUpViewController: SignUpView {
    
    fileprivate var credientialsGiven = false
    fileprivate var email: String? {
        get {
            return emailTextField.text
        }
    }
    fileprivate var password: String? {
        get {
            return passwordTextField.text
        }
    }
    
    ///Functionality for when view will appear
    ///- Parameter animated: Boolean to decide if view will apear with anination or not
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextField.tag = 0
        emailTextField.delegate = self
        passwordTextField.tag = 1
        passwordTextField.delegate = self
        passwordConfirmTextField.tag = 2
        passwordConfirmTextField.delegate = self
    }
    
    ///Set all actions in progrmaic view controller
    internal override func setActions() {
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
    }
    
    ///Sets the loading screen and halts any input on the screen
    ///- Parameter loading: Is the ViewController loading something
    fileprivate func setLoading(_ loading: Bool) {
        if loading {
            SwiftSpinner.show("Checking Info")
            emailTextField.errorLabel.text = "";
            passwordTextField.errorLabel.text = "";
            passwordConfirmTextField.errorLabel.text = "";
        } else {
            SwiftSpinner.show("Failed to connect, waiting...", animated: false)
            SwiftSpinner.hide()
        }
        emailTextField.isEnabled = !loading
        passwordTextField.isEnabled = !loading
        passwordConfirmTextField.isEnabled = !loading
        signUpButton.isEnabled = !loading
    }

    ///Signs the user up in the database if no errors with credentials and sends user to login screen with credentials
    @objc fileprivate func signUp() {
        view.endEditing(true)
        
        if(emailTextField.status == .error || emailTextField.text == "" || passwordTextField.status == .error || passwordTextField.text == "" || passwordConfirmTextField.status == .error || passwordConfirmTextField.text! != passwordTextField.text! ){
            let alert = JDropDownAlert()
            alert.alertWith("*** Error: Check Info ***")
            return
        }
        else{
            setLoading(true);
            app.emailPasswordAuth.registerUser(email: email!, password: password!,completion: { [weak self](error) in
                DispatchQueue.main.async {
                    self!.setLoading(false);
                    guard error == nil else {
                        print("Signup failed: \(error!)")
                        let alert = JDropDownAlert()
                        alert.alertWith("*** Error: \(error?.localizedDescription) ***")
                        return
                    }

                    print("Signup successful!")
                    // Registering just registers. Now we need to sign in, but we can reuse the existing email and password.
                    self!.navigationController!.pushViewController(LoginViewController(emailGivenFromSignUp: self!.email!, passwordGivenFromSignUp: self!.password!), animated: true);
                }
            })
        }
    }
    
    ///Action if button to close the keyboard when user presses return
    ///- Parameter sender: UITextField that was being used last
    ///- Returns: True if the text field should implement its default behavior for the return button; otherwise, false.
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let nextTextField = view.viewWithTag(textField.tag + 1) else {
            view.endEditing(true)
            return false
        }
        _ = nextTextField.becomeFirstResponder()
        return false
    }
    
}

///Functionality required for using UnderLineTextFieldDelegate
extension SignUpViewController: UnderLineTextFieldDelegate{
    ///Validates input given into UnderLineTextField
    ///- Parameter underLineTextField: UnderLineTextField to be validated
    func textFieldValidate(underLineTextField: UnderLineTextField) throws {
        if underLineTextField.text! == "" {return}
        switch underLineTextField {
        case emailTextField:
            let result : String = Validation.emailValidator(email: emailTextField.text!)
            if result != "Success"{
                throw UnderLineTextFieldErrors
                    .error(message: result)
            }
        case passwordTextField:
            let result : String = Validation.passwordValidator(password: passwordTextField.text!)
            if result != "Success"{
                passwordTextField.text = ""
                throw UnderLineTextFieldErrors
                    .error(message: result)
            }
        case passwordConfirmTextField:
            let result : String = Validation.passwordConfirmValidator(password: passwordTextField.text!, confirmingPassword: passwordConfirmTextField.text!)
            if result != "Success"{
                passwordConfirmTextField.text = ""
                passwordTextField.text = ""
                passwordTextField.status = .error
                throw UnderLineTextFieldErrors
                    .error(message: result)
            }
        default:
            break
        }
    }
}
