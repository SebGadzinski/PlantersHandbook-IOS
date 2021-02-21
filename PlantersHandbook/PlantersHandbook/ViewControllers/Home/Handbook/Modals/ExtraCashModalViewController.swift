//
//  ExtraCashModalViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-15.
//

import UIKit
import RealmSwift
import JDropDownAlert

class ExtraCashModalViewController: ExtraCashModalView {

    var extraCashList: List<ExtraCash>
    var selectedExtraCash = 0
    fileprivate var extraCashNotificationToken: NotificationToken?


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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        extraCashNotificationToken?.invalidate()
    }
    
    override func setUpOverlay() {
        super.setUpOverlay()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func setActions() {
        super.setActions()
        extraCashButton.addTarget(self, action: #selector(extraCashButtonAction), for: .touchUpInside)
    }
    
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
    
    fileprivate func extraCashSelected(row: Int){
        extraCashButton.setTitle("Save", for: .normal)
        selectedExtraCash = row
        reasonTextField.text = extraCashList[row].reason
        cashTextField.text = String(extraCashList[row].cash)
    }
    
    fileprivate func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}

extension ExtraCashModalViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return extraCashList.count
    }
    
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

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        extraCashSelected(row: indexPath.row)
    }

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
