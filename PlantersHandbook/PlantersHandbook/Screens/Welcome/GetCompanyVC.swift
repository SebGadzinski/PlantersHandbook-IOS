//
//  GetCompanyVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-10.
//

import UIKit
import RealmSwift

class GetCompanyVC: UIViewController {
    let userRealm: Realm
    var notificationToken: NotificationToken?
    var userData: User?
    
    init(userRealm: Realm) {
        self.userRealm = userRealm

        super.init(nibName: nil, bundle: nil)

        let usersInRealm = userRealm.objects(User.self)
        notificationToken = usersInRealm.observe { [weak self, usersInRealm] (changes) in
            self?.userData = usersInRealm.first
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
