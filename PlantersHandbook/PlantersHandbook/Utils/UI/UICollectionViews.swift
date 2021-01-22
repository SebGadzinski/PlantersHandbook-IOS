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
