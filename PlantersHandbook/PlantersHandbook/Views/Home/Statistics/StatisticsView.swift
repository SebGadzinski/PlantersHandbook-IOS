//
//  StatisticsView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit

class StatisticsView: ProgramicVC {

    internal let cardsCollectionView: UICollectionView = PH_CollectionView_Statistics()
    
    internal override func setUpOverlay() {
        backgroundView.backgroundColor = .systemBackground
        backgroundView.addSubview(cardsCollectionView)
        cardsCollectionView.fillSafeSuperView(to: backgroundView)
        cardsCollectionView.backgroundColor = .systemBackground
    }
    
}
