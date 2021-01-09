//
//  ProgramicViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation

protocol ProgramicViewController {
    func fetchData() -> Void
    func generateLayout() -> Void
    func configureViews() -> Void
    func setActions() -> Void
    func setUpOverlay() -> Void
}
