//
//  SplashViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-10.
//

import UIKit
import SwiftyGif
import RealmSwift

///SplashViewController.swift - Splash screen that displays logo animation and loads realm from cluster or local storage
class SplashViewController: SplashView {
    static let schemaVersion : UInt64 = 0
    var logoAnimationView : LogoAnimationView!
    
    
    ///Configure all views in programic view controller
    internal override func configureViews() {
        super.configureViews()
        logoAnimationView = LogoAnimationView(frame: .zero, fileName: (traitCollection.userInterfaceStyle == .dark ? "logoAnimation_black.gif" : "logoAnimation_white.gif"))
        backgroundView.addSubview(logoAnimationView)
        logoAnimationView.fillSuperView()
        logoAnimationView.logoGifImageView.delegate = self
    }
    
    ///Anything that needs to happen right when the view appears
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.checkingConfiguration()
        }
    }
    
    
    ///Checks to see if we can load a file using the proper configuration
    fileprivate func checkingConfiguration(){
        if let _ = app.currentUser{
            print("User is logged in")
            var configuration = app.currentUser!.configuration(partitionValue: "user=\(app.currentUser!.id)", cancelAsyncOpenOnNonFatalErrors: true)
            
            configuration.schemaVersion = SplashViewController.schemaVersion
            configuration.migrationBlock = { migration, oldVersion in
                if(oldVersion < SplashViewController.schemaVersion){
                    
                }
            }
            
            let globalQueue = DispatchQueue.global()
            var timerWasUp = false
            var realmAsyncFound = false;
            //If realm is not loaded after 12 seconds, proceed accordinly
            globalQueue.asyncAfter(deadline: DispatchTime.now() + 12) {
                timerWasUp = true
                if !realmAsyncFound{
                    DispatchQueue.main.async {
                        if Realm.fileExists(for: configuration){
                            self.enterapp(configuration: configuration, foundRealm: nil)
                        }else{
                            print("User not logged in; present sign in/sign up view")
                            self.navigationController?.pushViewController(WelcomeViewController(), animated: false)
                        }
                    }
                }
            }
            
            configuration.objectTypes = [User.self, Season.self, HandbookEntry.self, Block.self, SubBlock.self, Cache.self, BagUpInput.self, PlotInput.self, CoordinateInput.self, Coordinate.self, ExtraCash.self]
            Realm.asyncOpen(configuration: configuration, callbackQueue: .main, callback: { result in
                realmAsyncFound = true
                switch result {
                case .failure( _):
                    if(!timerWasUp){
                        print("Failed to load aysnc")
                        if Realm.fileExists(for: configuration){
                            self.enterapp(configuration: configuration, foundRealm: nil)
                        }else{
                            print("User not logged in; present sign in/sign up view")
                            self.navigationController?.pushViewController(WelcomeViewController(), animated: false)
                        }
                    }
                case .success(let realm):
                    if(!timerWasUp){
                        self.enterapp(configuration: configuration, foundRealm: realm)
                    }
                }
            })
        }else {
            print("User not logged in; present sign in/sign up view")
            self.navigationController?.pushViewController(WelcomeViewController(), animated: false)
        }
    }
    
    
    ///Enters the application with given realm if found, and if not it opens local realm
    ///- Parameter configuration: Conifuration for realm
    ///- Parameter foundRealm: Realm to be used in RealmDatabase
    fileprivate func enterapp(configuration: Realm.Configuration, foundRealm: Realm?){
        if foundRealm != nil{
            realmDatabase.connectToRealm(realm: foundRealm!)
        }else{
            guard let realm = Realm.safeInit(configuration: configuration) else {
                let alertController = UIAlertController(title: "** ERROR **", message: "Cannot open database. Please close application and restart.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            realmDatabase.connectToRealm(realm: realm)
        }
        logoAnimationView.logoGifImageView.stopAnimating()
        ///Goes to the the next view controller
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
        else{
            self.navigationController?.pushViewController(WelcomeViewController(), animated: false)
        }
    }
    
}

extension SplashViewController: SwiftyGifDelegate {
    ///Constructor that sets up the frame of the cell
    ///- Parameter sender: UIImageView that stopped operating
    func gifDidStop(sender: UIImageView) {
        logoAnimationView.isHidden = true
    }
}
