//
//  UIScrollVIews.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation
import UIKit

func SUI_ScrollView() -> UIScrollView {
    let scrollView = UIScrollView()
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.backgroundColor = .systemBackground
    scrollView.isScrollEnabled = true
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.isDirectionalLockEnabled = true
    scrollView.showsVerticalScrollIndicator = true
    return scrollView
}
