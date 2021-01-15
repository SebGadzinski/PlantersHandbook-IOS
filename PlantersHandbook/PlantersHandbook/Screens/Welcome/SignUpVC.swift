//
//  SignUpViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import UnderLineTextField
import SwiftSpinner
import JDropDownAlert
import RealmSwift

class SignUpVC: ProgramicVC {
    
    fileprivate var titleLayout : UIView!
    fileprivate var infoLayout : UIView!
    
    fileprivate let icon : UIImageView = UIImageView(image: UIImage(named: "icons8-oak-tree-64.png"))
    fileprivate let signUpTitle = label_normal(title: "Sign Up", fontSize: FontSize.extraLarge)
    fileprivate let emailTextInput = textField_form(placeholder: "email", textType: .emailAddress)
    fileprivate let passwordTextInput = textField_form(placeholder: "password", textType: .newPassword)
    fileprivate let passwordConfirmTextInput = textField_form(placeholder: "confirm password", textType: .password)
    fileprivate let signUpButton = ph_button(title: "Sign Up!", fontSize: FontSize.large)
    fileprivate var credientialsGiven = false

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailTextInput.text = "seb.gadzinski@gmail.com"
        passwordTextInput.text = "Skittles2!"
        passwordConfirmTextInput.text = "Skittles2!"
    }
    
    var email: String? {
        get {
            return emailTextInput.text
        }
    }

    var password: String? {
        get {
            return passwordTextInput.text
        }
    }
    
    override func generateLayout() {
        titleLayout = generalLayout(backgoundColor: .systemBackground)
        infoLayout = generalLayout(backgoundColor: .systemBackground)
    }
    
    override func configureViews() {
        setUpOverlay()
        setUpTitleLayout()
        setUpInfoLayout()
    }
    
    override func setActions() {
        signUpButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
    }
    
    func setUpOverlay() {
        [titleLayout, infoLayout].forEach{bgView.addSubview($0)}
        
        print(frame.size)
        
        titleLayout.anchor(top: bgView.topAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.25))
        infoLayout.anchor(top: titleLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor,size: .init(width: frame.width, height: frame.height*0.7))
    }
    
    func setUpTitleLayout() {
        let titleLayoutFrame = titleLayout.safeAreaFrame
        
        [icon, signUpTitle].forEach{titleLayout.addSubview($0)}
        icon.anchor(top: titleLayout.topAnchor, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayoutFrame.height*0.4, height: titleLayoutFrame.height*0.4))
        icon.anchorCenterX(to: titleLayout)
        
        signUpTitle.anchor(top: icon.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0),size: .init(width: titleLayoutFrame.width, height: titleLayoutFrame.height*0.4))
        signUpTitle.anchorCenterX(to: titleLayout)
    }
    
    func setUpInfoLayout() {
        let infoLayoutFrame = infoLayout.safeAreaFrame
        let textFieldBoundarySpace = CGFloat(20)
        
        [emailTextInput, passwordTextInput, passwordConfirmTextInput, signUpButton].forEach{infoLayout.addSubview($0)}
        
        emailTextInput.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 5, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        emailTextInput.tag = 0
        emailTextInput.delegate = self
        
        passwordTextInput.anchor(top: emailTextInput.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 5, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        passwordTextInput.tag = 1
        passwordTextInput.delegate = self
                
        passwordConfirmTextInput.anchor(top: passwordTextInput.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 5, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        passwordConfirmTextInput.tag = 2
        passwordConfirmTextInput.delegate = self
        
        signUpButton.anchor(top: nil, leading: infoLayout.leadingAnchor, bottom: infoLayout.bottomAnchor, trailing: infoLayout.trailingAnchor, padding: .init(top: 0, left: infoLayoutFrame.width*0.3, bottom: infoLayoutFrame.height*0.2, right: infoLayoutFrame.width*0.3),size: .init(width: 0, height: infoLayoutFrame.height*0.1))
        
    }
    
    // Turn on or off the activity indicator.
    func setLoading(_ loading: Bool) {
        if loading {
            SwiftSpinner.show("Checking Info")
            emailTextInput.errorLabel.text = "";
            passwordTextInput.errorLabel.text = "";
            passwordConfirmTextInput.errorLabel.text = "";
        } else {
            SwiftSpinner.show("Failed to connect, waiting...", animated: false)
            SwiftSpinner.hide()
        }
        emailTextInput.isEnabled = !loading
        passwordTextInput.isEnabled = !loading
        passwordConfirmTextInput.isEnabled = !loading
        signUpButton.isEnabled = !loading
    }

    @objc func signUp() {
        view.endEditing(true)
        
        if(emailTextInput.status == .error || emailTextInput.text == "" || passwordTextInput.status == .error || passwordTextInput.text == "" || passwordConfirmTextInput.status == .error || passwordConfirmTextInput.text! != passwordTextInput.text! ){
            let alert = JDropDownAlert()
            alert.alertWith("*** Error: Check Info ***")
            return
        }
        else{
            setLoading(true);
            app.emailPasswordAuth.registerUser(email: email!, password: password!,completion: { [weak self](error) in
                // Completion handlers are not necessarily called on the UI thread.
                // This call to DispatchQueue.main.async ensures that any changes to the UI,
                // namely disabling the loading indicator and navigating to the next page,
                // are handled on the UI thread:
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
                    self!.navigationController!.pushViewController(LoginVC(emailGivenFromSignUp: self!.email!, passwordGivenFromSignUp: self!.password!), animated: true);
                }
            })
        }
    }
}

extension SignUpVC: UnderLineTextFieldDelegate{
    func textFieldValidate(underLineTextField: UnderLineTextField) throws {
        if underLineTextField.text! == "" {return}
        switch underLineTextField {
        case emailTextInput:
            let result : String = emailValidator(email: emailTextInput.text!)
            if result != "Success"{
                throw UnderLineTextFieldErrors
                    .error(message: result)
            }
        case passwordTextInput:
            let result : String = passwordValidator(password: passwordTextInput.text!)
            if result != "Success"{
                passwordTextInput.text = ""
                throw UnderLineTextFieldErrors
                    .error(message: result)
            }
        case passwordConfirmTextInput:
            let result : String = passwordConfirmValidator(password: passwordTextInput.text!, confirmingPassword: passwordConfirmTextInput.text!)
            if result != "Success"{
                passwordConfirmTextInput.text = ""
                passwordTextInput.text = ""
                passwordTextInput.status = .error
                throw UnderLineTextFieldErrors
                    .error(message: result)
            }
        default:
            break
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let nextTextField = view.viewWithTag(textField.tag + 1) else {
            view.endEditing(true)
            return false
        }
        _ = nextTextField.becomeFirstResponder()
        return false
    }
    
}
