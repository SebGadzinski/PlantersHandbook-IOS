//
//  ScrollViews.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import UIKit

///ScrollViews.swift - All custom made UIScrollVIews given in static functions from SUI
extension SUI{
    ///Creates a programic UIScrollView for fully programic app (No StoryBoard)
    ///- Returns: Normal UIScrollView
    static func ScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .systemBackground
        scrollView.isScrollEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isDirectionalLockEnabled = true
        scrollView.showsVerticalScrollIndicator = true
        return scrollView
    }
}
