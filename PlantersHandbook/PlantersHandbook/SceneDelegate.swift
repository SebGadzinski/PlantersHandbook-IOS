//
//  SceneDelegate.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift
import SwiftSpinner

let app = App(id: "planters-handbook-unaje") // Public Key : FAZFDKLA | Private Key : 296432d3-6d71-4dfc-a311-9e66a95ad555
var realmDatabase = RealmDatabase()

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()
                
        let navigationController = UINavigationController(rootViewController: WelcomeVC())
        SwiftSpinner.show("")
        if let _ = app.currentUser{
            print("user is logged in")
            
            var configuration = app.currentUser!.configuration(partitionValue: "user=\(app.currentUser!.id)")
            configuration.objectTypes = [User.self, Season.self, HandbookEntry.self, Block.self, SubBlock.self, Cache.self, BagUpInput.self, PlotInput.self, CoordinateInput.self, Coordinate.self]
            
            Realm.asyncOpen(configuration: configuration) { [weak self](result) in
                print(result)
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        fatalError("Failed to open realm: \(error)")
                    case .success(let realm):
                        realmDatabase.connectToRealm(realm: realm)
                        if let user = realmDatabase.getLocalUser(){
                            if(user.company != ""){
                                navigationController.pushViewController(HomeTBC(), animated: false)
                            }
                            else{
                                navigationController.pushViewController(GetCompanyVC(), animated: true)
                            }
                        }
                            
                        SwiftSpinner.hide()
                        
                        self!.window?.rootViewController = navigationController
                        
                        guard let _ = (scene as? UIWindowScene) else { return }
                        
                    }
                }
            }
        } else {
            SwiftSpinner.hide()
            window?.rootViewController = navigationController
            guard let _ = (scene as? UIWindowScene) else { return }
            print("not logged in; present sign in/signup view")
        }
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

