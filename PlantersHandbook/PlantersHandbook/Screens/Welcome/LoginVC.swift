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

class LoginVC: ProgramicVC {
    
    fileprivate var titleLayout : UIView!
    fileprivate var infoLayout : UIView!
    
    fileprivate let icon : UIImageView = UIImageView(image: UIImage(named: "icons8-oak-tree-64.png"))
    fileprivate let signUpTitleLabel = SUI_Label(title: "Login", fontSize: FontSize.extraLarge)
    fileprivate let emailTextField = SUI_TextField_Form(placeholder: "email", textType: .emailAddress)
    fileprivate let passwordTextField = SUI_TextField_Form(placeholder: "password", textType: .newPassword)
    fileprivate let forgotPasswordLabel = SUI_Label(title: "Forgot Password?", fontSize: FontSize.small)
    fileprivate let loginButton = PH_Button(title: "Login!", fontSize: FontSize.large)
    fileprivate var credientialsGiven = false
    fileprivate let emailGivenFromSignUp : String
    fileprivate let passwordGivenFromSignUp : String
        
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
    
    var email: String? {
        get {
            return emailTextField.text
        }
    }

    var password: String? {
        get {
            return passwordTextField.text
        }
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
        loginButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToPasswordResetVC(tapGestureRecognizer:)))
        forgotPasswordLabel.addGestureRecognizer(tapGesture)
    }
    
    func setUpOverlay() {
        [titleLayout, infoLayout].forEach{bgView.addSubview($0)}
        
        print(frame.size)
        
        titleLayout.anchor(top: bgView.topAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.25))
        infoLayout.anchor(top: titleLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor,size: .init(width: frame.width, height: frame.height*0.7))
    }
    
    func setUpTitleLayout() {
        let titleLayoutFrame = titleLayout.safeAreaFrame
        
        [icon, signUpTitleLabel].forEach{titleLayout.addSubview($0)}
        icon.anchor(top: titleLayout.topAnchor, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayoutFrame.height*0.4, height: titleLayoutFrame.height*0.4))
        icon.anchorCenterX(to: titleLayout)
        
        signUpTitleLabel.anchor(top: icon.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0),size: .init(width: titleLayoutFrame.width, height: titleLayoutFrame.height*0.4))
        signUpTitleLabel.anchorCenterX(to: titleLayout)
    }
    
    func setUpInfoLayout() {
        let infoLayoutFrame = infoLayout.safeAreaFrame
        let textFieldBoundarySpace = CGFloat(20)
        
        [emailTextField, passwordTextField, forgotPasswordLabel, loginButton].forEach{infoLayout.addSubview($0)}
        
        emailTextField.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 5, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        emailTextField.tag = 0
        emailTextField.delegate = self
        
        passwordTextField.anchor(top: emailTextField.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 5, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        passwordTextField.tag = 1
        passwordTextField.delegate = self
        
        forgotPasswordLabel.anchor(top: passwordTextField.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 5, left: 0, bottom: 0, right: 0), size: .init(width: infoLayoutFrame.width*0.6, height: infoLayoutFrame.height*0.1))
        forgotPasswordLabel.isUserInteractionEnabled = true

        
        loginButton.anchor(top: nil, leading: infoLayout.leadingAnchor, bottom: infoLayout.bottomAnchor, trailing: infoLayout.trailingAnchor, padding: .init(top: 0, left: infoLayoutFrame.width*0.3, bottom: infoLayoutFrame.height*0.4, right: infoLayoutFrame.width*0.3),size: .init(width: 0, height: 0))
        
    }
    
    // Turn on or off the activity indicator.
    func setLoading(_ loading: Bool, message: String?) {
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
    
    @objc func goToPasswordResetVC(tapGestureRecognizer: UITapGestureRecognizer) {
      // Your code goes here
        self.navigationController!.pushViewController(PasswordResetVC(emailGivenFromLogin: email!), animated: true)
    }
    
    @objc func signIn() {
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
                    
                    var configuration = user.configuration(partitionValue: "user=\(user.id)")
                    
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
                                if let user = realmDatabase.getLocalUser(){
                                    if(user.company != ""){
                                        self!.navigationController!.pushViewController(HomeTBC(), animated: false)
                                    }
                                    else{
                                        self!.navigationController!.pushViewController(GetCompanyVC(), animated: true)
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

extension LoginVC: UnderLineTextFieldDelegate{
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

