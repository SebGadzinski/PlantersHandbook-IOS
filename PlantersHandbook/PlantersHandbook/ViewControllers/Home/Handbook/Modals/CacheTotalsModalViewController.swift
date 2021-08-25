//
//  CacheTotalsModalViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-06-12.
//

import UIKit

class CacheTotalsModalViewController: CacheTotalsModalView {

    required init(title: String, totalTrees: Int, totalCash: Double) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        treesLabel.text = String(totalTrees)
        cashLabel.text = totalCash.toCurrency()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
