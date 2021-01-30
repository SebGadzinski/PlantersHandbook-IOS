//
//  UICollectionViews.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import UIKit

func tallyCV() -> UICollectionView{
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = .systemBackground
    cv.isScrollEnabled = false
    cv.translatesAutoresizingMaskIntoConstraints = false
    cv.register(TallyCell.self, forCellWithReuseIdentifier: "TallyCell")
    return cv
}

func plotsCV() -> UICollectionView{
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.contentInset = .init(top: 0, left: 0, bottom: 50, right: 0)
    cv.backgroundColor = .systemBackground
    cv.translatesAutoresizingMaskIntoConstraints = false
    cv.register(PlotCell.self, forCellWithReuseIdentifier: "PlotCell")
    return cv
}
