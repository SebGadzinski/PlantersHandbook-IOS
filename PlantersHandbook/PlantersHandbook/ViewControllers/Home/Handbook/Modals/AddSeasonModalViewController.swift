//
//  SeasonPickingModal.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-15.
//

import UIKit

///AddSeasonModalViewController.swift - Create a Season View Controller
class AddSeasonModalViewController: AddSeasonModalView {
    weak var delegate : AddSeasonModalDelegate?

    ///Set all actions in progrmaic view controller
    internal override func setActions(){
        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
    }
    
    ///Functionality for when view will appear
    ///- Parameter animated: Boolean to decide if view will apear with anination or not
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.seasonNameTextField.delegate = self
        textFieldShouldReturn = true
    }

    ///Action if button to create season was pressed
    ///- Parameter sender: Button that has been clicked
    @objc fileprivate func addButtonAction(_ sender: Any) {
        if(seasonNameTextField.text != ""){
            let newSeason = Season(partition: realmDatabase.getParitionValue()!, title: seasonNameTextField.text!)

            if let delegate = delegate{
                delegate.createSeason(season: newSeason)
            }
            self.dismiss(animated: true, completion: nil)
            // Dismiss current Viewcontroller and back to Original
            self.navigationController?.popViewController(animated: true)
        }
    }

}

///Protocol used for a view controller that uses AddSeasonModalVIewController
protocol AddSeasonModalDelegate:NSObjectProtocol {
    ///Tells the delegate to create a season
    ///- Parameter season: Season to be created
    func createSeason(season : Season)
}

