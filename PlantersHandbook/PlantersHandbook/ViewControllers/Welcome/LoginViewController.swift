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
        
    init(emailGivenFromSignUp: String, passwordGivenFromSignUp: String) {
        self.emailGivenFromSignUp = emailGivenFromSignUp
        self.passwordGivenFromSignUp = passwordGivenFromSignUp
        
        super.init(nibName: nil, bundle: nil)
        
        self.credientialsGiven = true
    }
    
    init(){
        self.emailGivenFromSignUp = ""
        self.passwordGivenFromSignUp = ""
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        else{
            emailTextField.text = "seb.gadzinski@gmail.com"
            passwordTextField.text = "Skittles2!"
        }
    }
    
    internal override func setActions() {
        loginButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToPasswordResetVC(tapGestureRecognizer:)))
        forgotPasswordLabel.addGestureRecognizer(tapGesture)
    }
    
    // Turn on or off the activity indicator.
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
    
    @objc fileprivate func goToPasswordResetVC(tapGestureRecognizer: UITapGestureRecognizer) {
      // Your code goes here
        self.navigationController!.pushViewController(PasswordResetViewController(emailGivenFromLogin: email!), animated: true)
    }
    
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
                    self!.setLoading(false, message: nil);
                    return
                case .success(let user):
                    print("Login succeeded!");
                    self!.setLoading(true, message: "Gathering Info From Database");
                    
                    print(user.id)
                    
                    var configuration = user.configuration(partitionValue: "user=\(user.id)", cancelAsyncOpenOnNonFatalErrors: true)
                    
                    configuration.objectTypes = [User.self, Season.self, HandbookEntry.self, Block.self, SubBlock.self, Cache.self, BagUpInput.self, PlotInput.self, CoordinateInput.self, Coordinate.self]
                                      
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
                                if realmDatabase.getLocalUser() == nil{
                                    realmDatabase.add(item: User(_id: user.id, partition: "user=\(user.id)", name: self!.email!, company: "", seasons: List<String>(), stepDistance: 0))
                                }
                                if let user = realmDatabase.getLocalUser(){
                                    if(user.company == ""){
                                        self!.navigationController!.pushViewController(GetCompanyViewController(), animated: true)
                                        return
                                    }
                                    else if user.stepDistance == 0{
                                        self!.navigationController!.pushViewController(GetStepLengthViewController(), animated: true)
                                        return
                                    }
                                    else{
                                        self!.navigationController!.pushViewController(HomeTabViewController(), animated: false)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        };
    }
}

extension LoginViewController: UnderLineTextFieldDelegate{
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

