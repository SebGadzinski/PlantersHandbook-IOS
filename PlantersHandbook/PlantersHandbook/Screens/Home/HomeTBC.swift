//
//  HomeTBC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift

class HomeTBC: UITabBarController {
    let realm: Realm
    
    init(realm: Realm) {
        self.realm = realm
        print(realm)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let handbookNav = HandbookNC(rootViewController: HandbookVC(realm: realm))
        let statsNav = StatisticsNC(rootViewController: StatisticsVC(realm: realm))
        
        self.setViewControllers([handbookNav, statsNav], animated: false)
        self.tabBar.barTintColor = .systemGreen
        self.tabBar.tintColor = .black
        
        guard let items = self.tabBar.items else{
            return
        }
        
        let images = ["book", "chart.bar"]
        let titles = ["Handbook", "Stats"]
        
        for x in 0...items.count-1{
            items[x].image = UIImage(systemName: images[x])
            items[x].image?.withTintColor(.black)
            items[x].title = titles[x]
        }
        self.selectedIndex = 0
        // Do any additional setup after loading the view.
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

}
