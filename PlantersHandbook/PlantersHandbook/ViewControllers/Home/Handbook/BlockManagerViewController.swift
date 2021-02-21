//
//  BlockManagerVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift
import JDropDownAlert

class BlockManagerViewController: BlockManagerView {
    
    fileprivate var blockNotificationToken: NotificationToken?
    fileprivate let blocks: Results<Block>
    fileprivate var blockBeingEdited = -1
    fileprivate var handbookEntry : HandbookEntry
    
    required init(title: String, handbookEntry: HandbookEntry) {
        self.handbookEntry = handbookEntry
        self.blocks = realmDatabase.getBlockRealm(predicate: NSPredicate(format: "entryId = %@", self.handbookEntry._id)).sorted(byKeyPath: "_id")
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firstTimerKey = "BlockManagerViewController"
        if(isFirstTimer()){
            let alertController = UIAlertController(title: "Block Manager", message: "Welcome to Block Manager! \n\n This is where you can...\n1. Make notes on the day \n2. Add extra cash that you made (Other than planting) \n\n Once you create a block you move into SubBlock Manager and then Cache Manager. Each cache has its own tally", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: {_ in
                self.saveFirstTimer(finishedFirstTime: true)
            })
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    internal override func configureViews() {
        super.configureViews()
        setUpTableDelegates()
        addButton.setTitle("Add Block", for: .normal)
    }
    
    internal override func setActions() {
        addButton.addTarget(self, action: #selector(addBlockAction), for: .touchUpInside)
        notesButton.addTarget(self, action: #selector(notesButtonAction), for: .touchUpInside)
        extraCashButton.addTarget(self, action: #selector(extraCashButtonAction), for: .touchUpInside)
    }
    
    fileprivate func setUpTableDelegates(){
        managerTableView.delegate = self
        managerTableView.dataSource = self
    }
    
    fileprivate func nextVC(block: Block){
        self.navigationController?.pushViewController(
            SubBlockManagerViewController(title: block.title, block: block),
            animated: true
        )
    }
    
    @objc fileprivate func addBlockAction(){
        if(nameTextField.text! != ""){
            let block = Block(partition: realmDatabase.getParitionValue()!, title: nameTextField.text!, entryId: handbookEntry._id)
            realmDatabase.addBlock(entry: handbookEntry, block: block){ success, error in
                if error != nil{
                    let alert = JDropDownAlert()
                    alert.alertWith(error!)
                }
            }
        }
        view.endEditing(true)
        nameTextField.text = ""
    }
    
    @objc func notesButtonAction(_ sender: Any) {
        let vc = NotesModalViewController(text: handbookEntry.notes)
        vc.modalPresentationStyle = .popover
        vc.delegate = self
        present(vc, animated: true)
    }
    
    @objc func extraCashButtonAction(_ sender: Any) {
        let vc = ExtraCashModalViewController(extraCashList: handbookEntry.extraCash)
        vc.modalPresentationStyle = .pageSheet
        present(vc, animated: true)
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
        realmDatabase.deleteBlock(block: block){ success, error in
            if(success){
                print("Block Deleted From BlockManager")
            }
            else{
                let alertController = UIAlertController(title: "Error: Realm Error", message: error!, preferredStyle: .alert)
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
            realmDatabase.updateBlock(block: blocks[blockBeingEdited], _partition: nil, entryId: nil, title: returningText, date: nil, subBlocks: nil){ success, error in
                if error != nil{
                    let alert = JDropDownAlert()
                    alert.alertWith("Error with database, restart app if further errors : " + error!)
                }
            }
            let indexPath = IndexPath(item: blockBeingEdited, section: 0)
            managerTableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
}

extension BlockManagerViewController: NotesModalViewDelegate{
    func saveNotes(notes: String) {
        realmDatabase.updateHandbookEntry(entry: handbookEntry, _partition: nil, seasonId: nil, notes: notes, date: nil, blocks: nil, extraCash: nil){ success, error in
            if error != nil{
                let alert = JDropDownAlert()
                alert.alertWith("Error with database, restart app if further errors : " + error!)
            }
        }
    }
}
