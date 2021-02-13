//
//  UICollectionViews.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import UIKit

// Custom Developed For Planters Handbook

func PH_CollectionView_Tally() -> UICollectionView{
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = .systemBackground
    cv.isScrollEnabled = false
    cv.translatesAutoresizingMaskIntoConstraints = false
    cv.register(TallyCell.self, forCellWithReuseIdentifier: "TallyCell")
    return cv
}

func PH_CollectionView_Plots() -> UICollectionView{
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.contentInset = .init(top: 0, left: 0, bottom: 50, right: 0)
    cv.backgroundColor = .systemBackground
    cv.translatesAutoresizingMaskIntoConstraints = false
    cv.register(PlotCell.self, forCellWithReuseIdentifier: "PlotCell")
    return cv
}

func PH_CollectionView_Statistics() -> UICollectionView{
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 20
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.contentInset = .init(top: 0, left: 0, bottom: 50, right: 0)
    cv.backgroundColor = .systemBackground
    cv.dragInteractionEnabled = true
    cv.translatesAutoresizingMaskIntoConstraints = false
    cv.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    cv.register(TotalCashCell.self, forCellWithReuseIdentifier: "TotalCashCell")
    cv.register(LineGraphCell.self, forCellWithReuseIdentifier: "LineGraphCell")
    cv.register(OverallStatsCell.self, forCellWithReuseIdentifier: "OverallStatsCell")
    cv.register(PieChartCell.self, forCellWithReuseIdentifier: "PieChartCell")
    cv.register(HorizontalBarGraphCell.self, forCellWithReuseIdentifier: "HorizontalBarGraphCell")
    cv.register(OneTotalCell.self, forCellWithReuseIdentifier: "OneTotalCell")
    return cv
}
