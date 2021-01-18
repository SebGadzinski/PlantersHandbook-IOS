//
//  StatisticsViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift

class StatisticsVC: ProgramicVC {
    
    let realm: Realm
    let partitionValue: String
    var notificationToken: NotificationToken?
    let seasons: Results<Season>
    let handbookEntries: Results<HandbookEntry>
    
    required init(realm: Realm) {
        guard let syncConfiguration = realm.configuration.syncConfiguration else {
            fatalError("Sync configuration not found! Realm not opened with sync?");
        }

        self.realm = realm

        // Partition value must be of string type.
        partitionValue = syncConfiguration.partitionValue!.stringValue!

        // Access all tasks in the realm, sorted by _id so that the ordering is defined.
        seasons = realm.objects(Season.self).sorted(byKeyPath: "_id")
        if let season = seasons.first{
            let predicate = NSPredicate(format: "seasonId = %@", season._id)
            handbookEntries = realm.objects(HandbookEntry.self).filter(predicate)
        }
        else{
            handbookEntries = realm.objects(HandbookEntry.self).filter(NSPredicate(format: "seasonId = %@", "Empty"))
        }

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
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
