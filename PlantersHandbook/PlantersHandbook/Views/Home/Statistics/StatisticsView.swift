//
//  StatisticsView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-05.
//

import UIKit

///StatisticsView.swift - View for StatisticsViewController
class StatisticsView: ProgrammaticViewController {

    internal let cardsCollectionView: UICollectionView = PHUI.collectionViewStatistics()

    ///Set up overlay of view for all views in programic view controller
    internal override func setUpOverlay() {
        super.setUpOverlay()
        backgroundView.backgroundColor = .systemBackground
        backgroundView.addSubview(cardsCollectionView)
        cardsCollectionView.fillSafeSuperView(to: backgroundView)
        cardsCollectionView.backgroundColor = .systemBackground
        cardsCollectionView.contentInset = .init(top: 0, left: 0, bottom: 100, right: 0)
    }
    
}
