//
//  AddEntryViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-12.
//

import UIKit

class AddEntryModalViewController: AddEntryModalView {
    weak var delegate : AddEntryModalDelegate?
    private var seasonId : String
    
    required init(seasonId: String) {
        self.seasonId = seasonId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func setActions(){
        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    @objc fileprivate func addButtonAction(_ sender: Any) {
        let newEntry = HandbookEntry(partition: realmDatabase.getParitionValue()!, seasonId: seasonId)
        newEntry.date = datePicker.date

        if let delegate = delegate{
            delegate.createEntry(entry: newEntry)
        }
        self.dismiss(animated: true, completion: nil)
        // Dismiss current Viewcontroller and back to Original
        self.navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

}

protocol AddEntryModalDelegate:NSObjectProtocol {
    func createEntry(entry : HandbookEntry)
}
