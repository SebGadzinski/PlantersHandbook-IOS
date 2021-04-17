//
//  ExtraCashModalViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-15.
//

import UIKit
import RealmSwift
import JDropDownAlert

///ExtraCashModalViewController.swift - Displays extra cash from a handbookEntry
class ExtraCashModalViewController: ExtraCashModalView {

    fileprivate var extraCashList: List<ExtraCash>
    fileprivate var selectedExtraCash = 0
    fileprivate var extraCashNotificationToken: NotificationToken?

    ///Contructor that initalizes required fields and does any neccesary start functionality
    ///- Parameter extraCashList: List of extra cash
    required init(extraCashList: List<ExtraCash>) {
        self.extraCashList = extraCashList
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = "Extra Cash"
        extraCashNotificationToken = self.extraCashList.observe { [weak self] (changes) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView.
                tableView.performBatchUpdates({
                    // It's important to be sure to always update a table in this order:
                    // deletions, insertions, then updates. Otherwise, you could be unintentionally
                    // updating at the wrong index!
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }),
                        with: .automatic)
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                        with: .automatic)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                        with: .automatic)
                })
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
    
    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Called when view controller is deinitializing
    deinit {
        extraCashNotificationToken?.invalidate()
    }
    
    ///Set up overlay of view for all views in programic view controller
    override func setUpOverlay() {
        super.setUpOverlay()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    ///Set all actions in progrmaic view controller
    override func setActions() {
        super.setActions()
        extraCashButton.addTarget(self, action: #selector(extraCashButtonAction), for: .touchUpInside)
    }
    
    ///If the extra cash object is currently being edited, save the object, if not add the new extra cash object to the extra cash list
    ///- Parameter sender: Extra cash button
    @objc func extraCashButtonAction(_ sender: Any) {
        if(extraCashButton.titleLabel?.text == "Add Extra Cash"){
            if(cashTextField.text != "" && reasonTextField.text != ""){
                insertExtraCash()
            }
        }
        else{
            realmDatabase.updateHandbookExtraCash(extraCashList: extraCashList, cash: Double(cashTextField.text!), reason: reasonTextField.text, index: selectedExtraCash){ success, error in
                if error != nil{
                    let alert = JDropDownAlert()
                    alert.alertWith("Error with database, restart app if further errors : " + error!)
                }
            }
            cashTextField.text = ""
            reasonTextField.text = ""
            view.endEditing(true)
            extraCashButton.setTitle("Add Extra Cash", for: .normal)
        }
    }
    
    ///Adds the new extra cash to the extra cash list of the HandbookEntry
    fileprivate func insertExtraCash(){
        let newCash = ExtraCash()
        newCash.cash = Double(cashTextField.text!)!
        newCash.reason = reasonTextField.text
        realmDatabase.addToList(list: extraCashList, item: newCash){ success, error in
            if error != nil{
                let alert = JDropDownAlert()
                alert.alertWith("Error with database, restart app if further errors : " + error!)
            }
        }
        cashTextField.text = ""
        reasonTextField.text = ""
        view.endEditing(true)
    }
    
    ///Selects the extra cash from the extra cash list
    ///- Parameter row: Row of extra cash in tableView
    fileprivate func extraCashSelected(row: Int){
        extraCashButton.setTitle("Save", for: .normal)
        selectedExtraCash = row
        reasonTextField.text = extraCashList[row].reason
        cashTextField.text = String(extraCashList[row].cash)
    }

}

///Functionality required for using UITableViewDelegate and UITableViewDataSource
extension ExtraCashModalViewController: UITableViewDelegate, UITableViewDataSource{
    
    ///Tells the data source to return the number of rows in a given section of a table view.
    ///- Parameter tableView: The table-view object requesting this information.
    ///- Parameter section: An index number identifying a section in tableView.
    ///- Returns: Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return extraCashList.count
    }
    
    ///Asks the data source for a cell to insert in a particular location of the table view.
    ///- Parameter tableView: The table-view object requesting this cell.
    ///- Parameter indexPath: An index path locating a row in tableView.
    ///- Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. UIKit raises an assertion if you return nil.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.separatorInset = .init(top: 0, left: 5, bottom: 0, right: 5)
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.green
        cell.selectedBackgroundView = bgColorView
        cell.textLabel?.textAlignment = .center
        cell.tintColor = .systemGreen
        cell.textLabel?.text = extraCashList[indexPath.row].reason.firstCoupleWords + " | $" + String(extraCashList[indexPath.row].cash)
        return cell
    }

    ///Asks the data source to verify that the given row is editable.
    ///- Parameter tableView: The table-view object requesting this information.
    ///- Parameter indexPath: An index path locating a row in tableView.
    ///- Returns: True if the row indicated by indexPath is editable; otherwise, false.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    ///Tells the delegate a row is selected.
    ///- Parameter tableView: A table view informing the delegate about the new row selection.
    ///- Parameter indexPath: An index path locating the new selected row in tableView.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        extraCashSelected(row: indexPath.row)
    }

    ///Tells the delegate a row is selected.
    ///- Parameter tableView: The table-view object requesting the insertion or deletion.
    ///- Parameter editingStyle: The cell editing style corresponding to a insertion or deletion requested for the row specified by indexPath. Possible editing styles are UITableViewCell.EditingStyle.insert or UITableViewCell.EditingStyle.delete.
    ///- Parameter indexPath: An index path locating the row in tableView.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            realmDatabase.removeItemInList(list: extraCashList, index: indexPath.row){ success, error in
                if error != nil{
                    let alert = JDropDownAlert()
                    alert.alertWith("Error with database, restart app if further errors : " + error!)
                }
            }
        }
    }
}
