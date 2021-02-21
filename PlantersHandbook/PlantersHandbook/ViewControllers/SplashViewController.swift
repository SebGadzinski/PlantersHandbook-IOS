//
//  SplashViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-10.
//

import UIKit
import SwiftyGif
import RealmSwift

class SplashViewController: SplashView {
    
    internal override func configureViews() {
        super.configureViews()
//        logoAnimationView.logoGifImageView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
//        logoAnimationView.logoGifImageView.startAnimatingGif()
        checkingConfiguration()
    }
    
    fileprivate func checkingConfiguration(){
        if let _ = app.currentUser{
            print("User is logged in")
            var configuration = app.currentUser!.configuration(partitionValue: "user=\(app.currentUser!.id)", cancelAsyncOpenOnNonFatalErrors: true)
            configuration.objectTypes = [User.self, Season.self, HandbookEntry.self, Block.self, SubBlock.self, Cache.self, BagUpInput.self, PlotInput.self, CoordinateInput.self, Coordinate.self, ExtraCash.self]
            Realm.asyncOpen(configuration: configuration, callbackQueue: .main, callback: { result in
                switch result {
                case .failure( _):
                    print("Failed to load aysnc")
                    if Realm.fileExists(for: configuration){
                        self.enterapp(configuration: configuration, foundRealm: nil)
                    }else{
                        print("User not logged in; present sign in/sign up view")
                        self.navigationController?.pushViewController(WelcomeViewController(), animated: false)
                    }
                case .success(let realm):
                    self.enterapp(configuration: configuration, foundRealm: realm)
                }
            })
        }else {
            print("User not logged in; present sign in/sign up view")
            self.navigationController?.pushViewController(WelcomeViewController(), animated: false)
        }
    }
    
    func enterapp(configuration: Realm.Configuration, foundRealm: Realm?){
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
        if let user = realmDatabase.getLocalUser(){
            if user.company == ""{
                self.navigationController!.pushViewController(GetCompanyViewController(), animated: true)
                return
            }
            else if user.stepDistance == 0{
                self.navigationController!.pushViewController(GetStepLengthViewController(), animated: true)
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

//extension SplashViewController: SwiftyGifDelegate {
//    func gifDidStop(sender: UIImageView) {
//        logoAnimationView.isHidden = true
//
//    }
//}
