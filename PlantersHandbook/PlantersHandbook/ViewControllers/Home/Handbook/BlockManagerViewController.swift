//
//  BlockManagerVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift
import JDropDownAlert

///BlockManagerViewController.swift - Manages blocks in a handbookEntry
class BlockManagerViewController: BlockManagerView {
    
    ///Initializes required fields
    ///- Parameter title: Title of the manager
    ///- Parameter handbookEntry: Upper HierarchyObject to the objects in the manager is managing
    required init(title: String, handbookEntry: HandbookEntry) {
        super.init(title: title, upperHierarchyObject: handbookEntry, idString: "entryId")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Functionality for when view will appear
    ///- Parameter animated: Boolean to decide if view will apear with anination or not
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
        titleLabel.text = GeneralFunctions.getDate(from: upperHierarchyObject.date)
    }
    
    ///Configuire all views in programic view controller
    internal override func configureViews() {
        super.configureViews()
        setUpTableDelegates()
    }
    
    ///Set all actions in progrmaic view controller
    internal override func setActions() {
        super.setActions()
        notesButton.addTarget(self, action: #selector(notesButtonAction), for: .touchUpInside)
        extraCashButton.addTarget(self, action: #selector(extraCashButtonAction), for: .touchUpInside)
        let printButton = UIBarButtonItem(title: "Print", style: .plain, target: self, action: #selector(printButtonAction))
        self.navigationItem.rightBarButtonItem = printButton
    }
    
    ///Sets up any table delegates and datasources
    override func setUpTableDelegates(){
        super.setUpTableDelegates()
        managerTableView.delegate = self
        managerTableView.dataSource = self
    }
    
    ///Goes to next designated view controller
    fileprivate func nextVC(block: Block){
        self.navigationController?.pushViewController(
            SubBlockManagerViewController(title: block.title, block: block),
            animated: true
        )
    }
    
    ///Adds a block to given list and updates database
    @objc override func addAction(){
        super.addAction()
        if(nameTextField.text! != ""){
            let block = Block(partition: realmDatabase.getParitionValue()!, title: nameTextField.text!, entryId: upperHierarchyObject._id)
            realmDatabase.addBlock(entry: upperHierarchyObject, block: block){ success, error in
                if error != nil{
                    let alert = JDropDownAlert()
                    alert.alertWith(error!)
                }
            }
        }
        view.endEditing(true)
        nameTextField.text = ""
    }
    
    ///Opens PrintHandbookEntryModalViewController
    @objc fileprivate func printButtonAction(){
        let printModal = PrintHandbookEntryModalViewController(handbookEntry: upperHierarchyObject)
        if UIDevice.current.userInterfaceIdiom == .pad{
            printModal.view.superview?.bounds = .init(x: 0, y: 0, width: 200, height: 200)
        }else{
            printModal.modalPresentationStyle = .popover
        }
        printModal.setUpUIPopUpController(barButtonItem: self.navigationItem.rightBarButtonItem, sourceView: nil)
        present(printModal, animated: true)
    }
    
    ///Opens NotesModalViewController
    @objc func notesButtonAction(_ sender: Any) {
        let vc = NotesModalViewController(text: upperHierarchyObject.notes)
        vc.modalPresentationStyle = .popover
        vc.setUpUIPopUpController(barButtonItem: nil, sourceView: notesButton)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    ///Opens ExtraCashModalViewController
    @objc func extraCashButtonAction(_ sender: Any) {
        let vc = ExtraCashModalViewController(extraCashList: upperHierarchyObject.extraCash)
        vc.modalPresentationStyle = .pageSheet
        vc.setUpUIPopUpController(barButtonItem: nil, sourceView: extraCashButton)
        present(vc, animated: true)
    }
    
    ///Opens OneTextFieldModalViewController which is used to rename a block
    @objc override func hamburgerMenuTapped(sender: UIButton) {
        super.hamburgerMenuTapped(sender: sender)
        objectBeingEdited = sender.tag
        let oneTextFieldModal = OneTextFieldModalViewController(title: "Rename Block", textForTextField: objects[objectBeingEdited].title)
        oneTextFieldModal.delegate = self
        oneTextFieldModal.modalPresentationStyle = .popover
        oneTextFieldModal.setUpUIPopUpController(barButtonItem: nil, sourceView: sender)
        present(oneTextFieldModal, animated: true)
    }

}

extension BlockManagerViewController: UITableViewDelegate, UITableViewDataSource{
    ///Tells the data source to return the number of rows in a given section of a table view.
    ///- Parameter tableView: The table-view object requesting this information.
    ///- Parameter section: An index number identifying a section in tableView.
    ///- Returns: Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    ///Asks the data source for a cell to insert in a particular location of the table view.
    ///- Parameter tableView: The table-view object requesting this cell.
    ///- Parameter indexPath: An index path locating a row in tableView.
    ///- Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. UIKit raises an assertion if you return nil.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditCell", for: indexPath) as! EditableTableViewCell
        cell.textLabel?.text = objects[indexPath.row].title
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.extraLarge))
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.hamburgerMenu.addTarget(self, action: #selector(hamburgerMenuTapped), for: .touchUpInside)
        cell.hamburgerMenu.tag = indexPath.row
        return cell
    }
    
    ///Tells the delegate a row is selected.
    ///- Parameter tableView: A table view informing the delegate about the new row selection.
    ///- Parameter indexPath: An index path locating the new selected row in tableView.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        nextVC(block: objects[indexPath.row])
    }

    ///Tells the delegate a row is selected.
    ///- Parameter tableView: The table-view object requesting the insertion or deletion.
    ///- Parameter editingStyle: The cell editing style corresponding to a insertion or deletion requested for the row specified by indexPath. Possible editing styles are UITableViewCell.EditingStyle.insert or UITableViewCell.EditingStyle.delete.
    ///- Parameter indexPath: An index path locating the row in tableView.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let block = objects[indexPath.row]
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

///Functionality required for using OneTextFieldModalDelegate
extension BlockManagerViewController: OneTextFieldModalDelegate{
    ///Changes blocks name
    ///- Parameter returningText: Name of block
    func completionHandler(returningText: String) {
        if objectBeingEdited > -1 && objectBeingEdited < objects.count{
            realmDatabase.updateBlock(block: objects[objectBeingEdited], _partition: nil, entryId: nil, title: returningText, date: nil, subBlocks: nil){ success, error in
                if error != nil{
                    let alert = JDropDownAlert()
                    alert.alertWith("Error with database, restart app if further errors : " + error!)
                }
            }
            let indexPath = IndexPath(item: objectBeingEdited, section: 0)
            managerTableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
}

///Functionality required for using NotesModalViewDelegate
extension BlockManagerViewController: NotesModalViewDelegate{
    ///Saves notes
    ///- Parameter notes: Notes from user for the handbookEntry
    func saveNotes(notes: String) {
        realmDatabase.updateHandbookEntry(entry: upperHierarchyObject, _partition: nil, seasonId: nil, notes: notes, date: nil, blocks: nil, extraCash: nil){ success, error in
            if error != nil{
                let alert = JDropDownAlert()
                alert.alertWith("Error with database, restart app if further errors : " + error!)
            }
        }
    }
}
