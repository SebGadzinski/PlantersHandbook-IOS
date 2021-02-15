//
//  SubBlockVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift

class SubBlockManagerViewController: SubBlockManagerView {
    
    fileprivate let blockId: String
    fileprivate var subBlockNotificationToken: NotificationToken?
    fileprivate let subBlocks: Results<SubBlock>
    fileprivate var subBlockBeingEdited = -1
    
    required init(title: String, blockId: String) {
        self.subBlocks = realmDatabase.getSubBlockRealm(predicate: NSPredicate(format: "blockId = %@", blockId)).sorted(byKeyPath: "_id")
        self.blockId = blockId
       
        super.init(nibName: nil, bundle: nil)
        
        titleLabel.text = "Block: " + title
        self.title = "SubBlocks"

        subBlockNotificationToken = subBlocks.observe { [weak self] (changes) in
            guard let tableView = self?.managerTableView else { return }
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
    
    deinit {
        subBlockNotificationToken?.invalidate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func configureViews() {
        super.configureViews()
        setUpTableDelegates()
        addButton.setTitle("Add SubBlock", for: .normal)
    }
    
    internal override func setActions() {
        addButton.addTarget(self, action: #selector(addSubBlockAction), for: .touchUpInside)
    }
    
    fileprivate func setUpTableDelegates(){
        managerTableView.delegate = self
        managerTableView.dataSource = self
    }
    
    fileprivate func nextVC(subBlock: SubBlock){
        self.navigationController?.pushViewController(
            CacheManagerViewController(title: subBlock.title, subBlockId: subBlock._id),
            animated: true
        )
    }
    
    @objc fileprivate func addSubBlockAction(){
        if (subBlocks.contains{$0.title == nameTextField.text!}) {
                let alert = UIAlertController(title: "Duplicate SubBlock", message: "You already have a subBlock with that name in this entry, use a different name", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
        }
        else{
            if(nameTextField.text! != ""){
                let subBlock = SubBlock(partition: realmDatabase.getParitionValue()!, title: nameTextField.text!, blockId: blockId)
                realmDatabase.add(item: subBlock)
            }
        }
        view.endEditing(true)
        nameTextField.text = ""
    }
    
    fileprivate func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    @objc func hamdbugerMenuTapped(sender: UIButton) {
        subBlockBeingEdited = sender.tag
        let oneTextFieldModal = OneTextFieldModalViewController(title: "Rename Sub Block", textForTextField: subBlocks[subBlockBeingEdited].title)
        oneTextFieldModal.delegate = self
        oneTextFieldModal.modalPresentationStyle = .popover
        present(oneTextFieldModal, animated: true)
    }

}

extension SubBlockManagerViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subBlocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditCell", for: indexPath) as! EditableTableViewCell
        cell.textLabel?.text = subBlocks[indexPath.row].title
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.extraLarge))
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.hamburgerMenu.addTarget(self, action: #selector(hamdbugerMenuTapped), for: .touchUpInside)
        cell.hamburgerMenu.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        nextVC(subBlock: subBlocks[indexPath.row])
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let subBlock = subBlocks[indexPath.row]
        realmDatabase.deleteSubBlock(subBlock: subBlock){ (result) in
            if(result){
                print("SubBlock Deleted From SubBlockManager")
            }
            else{
                let alertController = UIAlertController(title: "Error: Realm Erro", message: "Could Not Delete SubBlock", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

extension SubBlockManagerViewController: OneTextFieldModalDelegate{
    func completionHandler(returningText: String) {
        if subBlockBeingEdited > -1 && subBlockBeingEdited < subBlocks.count{
            realmDatabase.updateSubBlock(subBlock: subBlocks[subBlockBeingEdited], _partition: nil, blockId: nil, title: returningText, date: nil, caches: nil)
            let indexPath = IndexPath(item: subBlockBeingEdited, section: 0)
            managerTableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
}
