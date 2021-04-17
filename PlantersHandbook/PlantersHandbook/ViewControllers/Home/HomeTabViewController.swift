//
//  HomeTBC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift
import SwiftSpinner

///HomeTabViewController.swift - Tab view controller contaiing a handbook and a statistics tabs
class HomeTabViewController: UITabBarController {

    ///Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let handbookNav = HandbookNC(rootViewController: HandbookViewController())
        let statsNav = StatisticsNC(rootViewController: StatisticsViewController())
        
        self.setViewControllers([handbookNav, statsNav], animated: false)
        self.tabBar.barTintColor = .systemGreen
        self.tabBar.tintColor = .black
        
        guard let items = self.tabBar.items else{
            return
        }
        
        let images = ["book", "chart.bar"]
        let titles = ["Handbook", "Stats"]
        
        for x in 0...items.count-1{
            items[x].tag = x
            items[x].image = UIImage(systemName: images[x])
            items[x].image?.withTintColor(.black)
            items[x].title = titles[x]
        }
        self.selectedIndex = 0
        
    }
    
    ///Functionality for when view will appear
    ///- Parameter animated: Boolean to decide if view will apear with anination or not
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isHidden = true
    }

}
