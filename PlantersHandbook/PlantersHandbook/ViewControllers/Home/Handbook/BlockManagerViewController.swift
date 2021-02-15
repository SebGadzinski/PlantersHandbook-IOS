//
//  BlockManagerVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift

class BlockManagerViewController: BlockManagerView {
    
    fileprivate let handbookId: String
    fileprivate var blockNotificationToken: NotificationToken?
    fileprivate let blocks: Results<Block>
    fileprivate var blockBeingEdited = -1
    
    required init(title: String, handbookId: String) {
        self.blocks = realmDatabase.getBlockRealm(predicate: NSPredicate(format: "entryId = %@", handbookId)).sorted(byKeyPath: "_id")
        self.handbookId = handbookId
        
        super.init(nibName: nil, bundle: nil)
        
        titleLabel.text = title
        self.title = "Blocks"

        blockNotificationToken = blocks.observe { [weak self] (changes) in
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
        blockNotificationToken?.invalidate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func configureViews() {
        super.configureViews()
        setUpTableDelegates()
        addButton.setTitle("Add Block", for: .normal)
    }
    
    internal override func setActions() {
        addButton.addTarget(self, action: #selector(addBlockAction), for: .touchUpInside)
    }
    
    fileprivate func setUpTableDelegates(){
        managerTableView.delegate = self
        managerTableView.dataSource = self
    }
    
    fileprivate func nextVC(block: Block){
        self.navigationController?.pushViewController(
            SubBlockManagerViewController(title: block.title, blockId: block._id),
            animated: true
        )
    }
    
    @objc fileprivate func addBlockAction(){
        if (blocks.contains{$0.title == nameTextField.text!}) {
                let alert = UIAlertController(title: "Duplicate Block", message: "You already have a block with that name in this entry, use a different name", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
        }
        else{
            if(nameTextField.text! != ""){
                let block = Block(partition: realmDatabase.getParitionValue()!, title: nameTextField.text!, entryId: handbookId)
                realmDatabase.add(item: block)
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
        blockBeingEdited = sender.tag
        let oneTextFieldModal = OneTextFieldModalViewController(title: "Rename Block", textForTextField: blocks[blockBeingEdited].title)
        oneTextFieldModal.delegate = self
        oneTextFieldModal.modalPresentationStyle = .popover
        present(oneTextFieldModal, animated: true)
    }

}

extension BlockManagerViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditCell", for: indexPath) as! EditableTableViewCell
        cell.textLabel?.text = blocks[indexPath.row].title
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.extraLarge))
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.hamburgerMenu.addTarget(self, action: #selector(hamdbugerMenuTapped), for: .touchUpInside)
        cell.hamburgerMenu.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        nextVC(block: blocks[indexPath.row])
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let block = blocks[indexPath.row]
        realmDatabase.deleteBlock(block: block){ (result) in
            if(result){
                print("Block Deleted From BlockManager")
            }
            else{
                let alertController = UIAlertController(title: "Error: Realm Error", message: "Could Not Delete Block", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

extension BlockManagerViewController: OneTextFieldModalDelegate{
    func completionHandler(returningText: String) {
        if blockBeingEdited > -1 && blockBeingEdited < blocks.count{
            realmDatabase.updateBlock(block: blocks[blockBeingEdited], _partition: nil, entryId: nil, title: returningText, date: nil, subBlocks: nil)
            let indexPath = IndexPath(item: blockBeingEdited, section: 0)
            managerTableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
}
