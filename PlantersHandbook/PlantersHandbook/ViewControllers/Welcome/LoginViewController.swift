//
//  LoginViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import UnderLineTextField
import SwiftSpinner
import JDropDownAlert
import RealmSwift

///LoginViewController.swift - Login page
class LoginViewController: LoginView {
    
    fileprivate var credientialsGiven = false
    fileprivate let emailGivenFromSignUp : String
    fileprivate let passwordGivenFromSignUp : String
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
    
    ///Constructor that is used for when a user just signs up, credentials can be preset
    ///- Parameter emailGivenFromSignUp: Email given from SignUpVIewController
    ///- Parameter passwordGivenFromSignUp: Email given from SignUpVIewController
    init(emailGivenFromSignUp: String, passwordGivenFromSignUp: String) {
        self.emailGivenFromSignUp = emailGivenFromSignUp
        self.passwordGivenFromSignUp = passwordGivenFromSignUp
        
        super.init(nibName: nil, bundle: nil)
        
        self.credientialsGiven = true
    }
    
    ///Constructor that auto fills fields required
    init(){
        self.emailGivenFromSignUp = ""
        self.passwordGivenFromSignUp = ""
        super.init(nibName: nil, bundle: nil)
        emailTextField.inactivePlaceholderTextColor = .gray
        passwordTextField.inactivePlaceholderTextColor = .gray
        passwordTextField.accessibilityLabel = "password"
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
        if(credientialsGiven){
            
            emailTextField.text = emailGivenFromSignUp
            passwordTextField.text = passwordGivenFromSignUp
            
            //If there is no password it came from password reset or welcome page, if there is it came from sign up and user needs to confirm email
            if(passwordGivenFromSignUp != ""){
                let alert = UIAlertController(title: "You must confirm your email before pressing login", message: email, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "I Will", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    ///Set all actions in progrmaic view controller
    internal override func setActions() {
        super.setActions()
        loginButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToPasswordResetVC(tapGestureRecognizer:)))
        forgotPasswordLabel.addGestureRecognizer(tapGesture)
    }
    
    ///Sets the loading screen and halts any input on the screen
    ///- Parameter loading: Is the ViewController loading something
    ///- Parameter message: Message for the loading screen
    fileprivate func setLoading(_ loading: Bool, message: String?) {
        if loading {
            SwiftSpinner.show(message!)
            emailTextField.errorLabel.text = "";
            passwordTextField.errorLabel.text = "";
        } else {
            SwiftSpinner.hide()
        }
        emailTextField.isEnabled = !loading
        passwordTextField.isEnabled = !loading
        loginButton.isEnabled = !loading
    }
    
    ///Goes to the PasswordResetViewController
    ///- Parameter tapGestureRecognizer: Type of gesture recognizer
    @objc fileprivate func goToPasswordResetVC(tapGestureRecognizer: UITapGestureRecognizer) {
      // Your code goes here
        self.navigationController!.pushViewController(PasswordResetViewController(emailGivenFromLogin: email!), animated: true)
    }
    
    ///Goes to the the next view controller
    func nextVC(){
        if let user = realmDatabase.findLocalUser(){
            if(user.company == ""){
                self.navigationController!.pushViewController(GetCompanyViewController(), animated: true)
                return
            }
            else if user.stepDistance == 0{
                self.navigationController!.pushViewController(GetStepLengthViewController(), animated: true)
                return
            }
            else if !user.name.isName(){
                self.navigationController!.pushViewController(GetNameViewController(), animated: true)
                return
            }
            else{
                self.navigationController!.pushViewController(HomeTabViewController(), animated: false)
            }
        }
    }
    
    ///Signs the user in with the database, then sends user to next view controller
    @objc fileprivate func signIn() {
        print("Log in as user: \(email!)");
        setLoading(true, message: "Checking Info");
        
        app.login(credentials: Credentials.emailPassword(email: email!, password: password!)) { [weak self](result) in
            // Completion handlers are not necessarily called on the UI thread.
            // This call to DispatchQueue.main.async ensures that any changes to the UI,
            // namely disabling the loading indicator and navigating to the next page,
            // are handled on the UI thread:
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    // Auth error: user already exists? Try logging in as that user.
                    print("Login failed: \(error)");
                    let alert = JDropDownAlert()
                    alert.alertWith("*** Error: \(error.localizedDescription) ***")
                    self!.passwordTextField.text = ""
                    self!.setLoading(false, message: nil);
                    return
                case .success(let user):
                    print("Login succeeded!");
                    self!.setLoading(true, message: "Gathering Info From Database");
                    
                    print(user.id)
                    
                    var configuration = user.configuration(partitionValue: "user=\(user.id)", cancelAsyncOpenOnNonFatalErrors: true)
                    
                    configuration.objectTypes = [User.self, Season.self, HandbookEntry.self, Block.self, SubBlock.self, Cache.self, BagUpInput.self, PlotInput.self, CoordinateInput.self, Coordinate.self, ExtraCash.self]
                                      
                    Realm.asyncOpen(configuration: configuration) { [weak self](result) in
                        DispatchQueue.main.async {
                            switch result {
                            case .failure(let error):
                                self!.setLoading(false, message: "Deciding If your Good Enough");
                                fatalError("Failed to open realm: \(error)")
                            case .success(let realm):
                                SwiftSpinner.show(duration: 0.5, title: "Success!")
                                 realmDatabase.connectToRealm(realm: realm)
                                //If just signed up, create a user and add to realm
                                if realmDatabase.findLocalUser() == nil{
                                    realmDatabase.addUser(user: User(_id: user.id, partition: "user=\(user.id)", name: self!.email!, company: "", seasons: List<String>(), stepDistance: 0)){ success, error in
                                        if success{
                                            self!.nextVC()
                                        }else{
                                            let alert = JDropDownAlert()
                                            alert.alertWith("*** Error: \(error!) ***")
                                            self!.setLoading(false, message: nil);
                                        }
                                    }
                                }else{
                                    self!.nextVC()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

///Functionality required for using UnderLineTextFieldDelegate
extension LoginViewController: UnderLineTextFieldDelegate{
    ///Validates input given into UnderLineTextField
    ///- Parameter underLineTextField: UnderLineTextField to be validated
    func textFieldValidate(underLineTextField: UnderLineTextField) throws {
        if emailTextField == underLineTextField{
            let result : String = Validation.emailValidator(email: emailTextField.text!)
            if result != "Success"{
                throw UnderLineTextFieldErrors
                    .error(message: result)
            }
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

