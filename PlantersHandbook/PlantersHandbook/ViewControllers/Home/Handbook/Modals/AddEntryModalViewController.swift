//
//  AddEntryViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-12.
//

import UIKit

///AddEntryModalViewController.swift - Create a HandbookEntry View Controller
class AddEntryModalViewController: AddEntryModalView {
    weak var delegate : AddEntryModalDelegate?
    private var seasonId : String
    
    ///Contructor that initalizes required fields
    ///- Parameter seasonId: Id of season where entry is to be added
    required init(seasonId: String) {
        self.seasonId = seasonId
        super.init(nibName: nil, bundle: nil)
        textFieldShouldReturn = true
    }
    
    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Set all actions in progrmaic view controller
    internal override func setActions(){
        addButton.addTarget(self, action: #selector(addButtonAction), for: .touchUpInside)
    }

    ///Creates the entry and sends it to HandbookViewController, and pops this modal from navigation controller stack
    ///- Parameter sender: Add button
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

}

///Protocol used for a view controller that uses AddEntryModalVIewController
protocol AddEntryModalDelegate:NSObjectProtocol {
    ///Tells the delegate to create a HandbookEntry
    ///- Parameter season: HandbookEntry to be created
    func createEntry(entry : HandbookEntry)
}
