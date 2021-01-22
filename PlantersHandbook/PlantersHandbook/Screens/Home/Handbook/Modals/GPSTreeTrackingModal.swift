//
//  GPSTreeTrackingVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift

class GPSTreeTrackingModal: ProgramicVC {
    
    fileprivate var googleMapsLayout : UIView!
    fileprivate var actionLayout : UIView!
    
    let cacheCoordinates: List<Coordinate>
    let realm: Realm
    let partitionValue: String
    
    required init(realm: Realm, title: String, cacheCoordinates: List<Coordinate>) {
        guard let syncConfiguration = realm.configuration.syncConfiguration else {
            fatalError("Sync configuration not found! Realm not opened with sync?")
        }
        
        self.realm = realm
        self.partitionValue = syncConfiguration.partitionValue!.stringValue!
        self.cacheCoordinates = cacheCoordinates
       
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
    
}
