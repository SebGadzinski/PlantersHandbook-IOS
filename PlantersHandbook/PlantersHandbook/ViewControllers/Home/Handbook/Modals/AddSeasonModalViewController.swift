//
//  SeasonPickingModal.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-15.
//

import UIKit

class AddSeasonModalViewController: AddSeasonModalView {
    weak var delegate : AddSeasonModalDelegate?

    internal override func setActions(){
        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.seasonNameTextField.delegate = self
    }

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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

}

protocol AddSeasonModalDelegate:NSObjectProtocol {
    func createSeason(season : Season)
}

