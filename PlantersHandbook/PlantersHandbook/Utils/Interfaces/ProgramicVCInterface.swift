//
//  ProgramicViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import Foundation

protocol ProgramicVCInterface{
    func generateLayout() -> Void
    func configureViews() -> Void
    func setActions() -> Void
}
