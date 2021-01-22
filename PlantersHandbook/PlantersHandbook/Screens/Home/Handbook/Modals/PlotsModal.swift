//
//  PlotsVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift

class PlotsModal: ProgramicVC {
    
    let plots: List<PlotInput>
    let realm: Realm
    let partitionValue: String
    
    required init(realm: Realm, title: String, plots: List<PlotInput>) {
        guard let syncConfiguration = realm.configuration.syncConfiguration else {
            fatalError("Sync configuration not found! Realm not opened with sync?")
        }
        
        self.realm = realm
        self.partitionValue = syncConfiguration.partitionValue!.stringValue!
        self.plots = plots
       
        super.init(nibName: nil, bundle: nil)
        
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func generateLayout() {
        
    }
    
    override func configureViews() {
        
    }
    
    override func setActions() {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
