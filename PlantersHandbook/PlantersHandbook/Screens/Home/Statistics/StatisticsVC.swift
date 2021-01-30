//
//  StatisticsViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift

class StatisticsVC: ProgramicVC {
    
    var notificationToken: NotificationToken?
    let seasons: Results<Season>
    let handbookEntries: Results<HandbookEntry>
    
    required init() {
        seasons = realmDatabase.getSeasonRealm(predicate: nil).sorted(byKeyPath: "_id")
        
        handbookEntries = realmDatabase.getHandbookEntryRealm(predicate: nil)


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
