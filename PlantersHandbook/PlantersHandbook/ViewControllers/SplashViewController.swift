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
        logoAnimationView.logoGifImageView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.checkingConfiguration()
        }
        logoAnimationView.logoGifImageView.startAnimatingGif()
    }
    
    fileprivate func checkingConfiguration(){
        if let _ = app.currentUser{
            print("user is logged in")
            var configuration = app.currentUser!.configuration(partitionValue: "user=\(app.currentUser!.id)", cancelAsyncOpenOnNonFatalErrors: true)
            configuration.objectTypes = [User.self, Season.self, HandbookEntry.self, Block.self, SubBlock.self, Cache.self, BagUpInput.self, PlotInput.self, CoordinateInput.self, Coordinate.self]
            Realm.asyncOpen(configuration: configuration) { [weak self](result) in
                DispatchQueue.main.async {
                    switch result {
                    case .failure( _):
                        if Realm.fileExists(for: configuration){
                            self!.enterapp(configuration: configuration, foundRealm: nil)
                        }else{
                            self!.navigationController?.pushViewController(WelcomeViewController(), animated: false)
                            print("not logged in; present sign in/signup view")
                        }
                    case .success(let realm):
                        self!.enterapp(configuration: configuration, foundRealm: realm)
                    }
                }
            }
            
        } else {
            self.navigationController?.pushViewController(WelcomeViewController(), animated: false)
            print("not logged in; present sign in/signup view")
        }
    }
    
    func enterapp(configuration: Realm.Configuration, foundRealm: Realm?){
        if foundRealm != nil{
            realmDatabase.connectToRealm(realm: foundRealm!)
        }else{
            guard let realm = Realm.safeInit(configuration: configuration) else {
                let alertController = UIAlertController(title: "** ERROR **", message: "We cannot open database. Please close application and restart.", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: {_ in
                    self.saveFirstTimer(finishedFirstTime: true)
                })
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

extension SplashViewController: SwiftyGifDelegate {
    func gifDidStop(sender: UIImageView) {
        logoAnimationView.isHidden = true
    }
}
