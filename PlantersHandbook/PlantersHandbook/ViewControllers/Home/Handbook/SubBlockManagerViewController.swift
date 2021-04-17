//
//  SubBlockVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift
import JDropDownAlert

///SubBlockManagerViewController.swift - Manages subBlocks in a caches
class SubBlockManagerViewController: SubBlockManagerView {
    
    ///Initializes required fields
    ///- Parameter title: Title of the manager
    ///- Parameter block: Upper HierarchyObject to the objects in the manager is managing
    required init(title: String, block: Block) {
        super.init(title: title, upperHierarchyObject: block, idString: "blockId")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    ///Configuire all views in programic view controller
    internal override func configureViews() {
        super.configureViews()
        setUpTableDelegates()
    }
    
    ///Sets up any table delegates and datasources
    override func setUpTableDelegates(){
        super.setUpTableDelegates()
        managerTableView.delegate = self
        managerTableView.dataSource = self
    }
    
    ///Goes to next designated view controller
    fileprivate func nextVC(subBlock: SubBlock){
        self.navigationController?.pushViewController(
            CacheManagerViewController(title: subBlock.title, subBlock: subBlock),
            animated: true
        )
    }
    
    ///Adds a subBlock  to given list and updates database
    @objc override func addAction(){
        super.addAction()
        if(nameTextField.text! != ""){
            let subBlock = SubBlock(partition: realmDatabase.getParitionValue()!, title: nameTextField.text!, blockId: upperHierarchyObject._id)
            realmDatabase.addSubBlock(block: upperHierarchyObject, subBlock: subBlock){ success, error in
                if error != nil{
                    let alert = JDropDownAlert()
                    alert.alertWith(error!)
                }
            }
        }
        view.endEditing(true)
        nameTextField.text = ""
    }
    
    ///Opens OneTextFieldModalViewController which is used to rename a subBlock
    @objc override func hamburgerMenuTapped(sender: UIButton) {
        super.hamburgerMenuTapped(sender: sender)
        objectBeingEdited = sender.tag
        let oneTextFieldModal = OneTextFieldModalViewController(title: "Rename SubBlock", textForTextField: objects[objectBeingEdited].title)
        oneTextFieldModal.delegate = self
        oneTextFieldModal.modalPresentationStyle = .popover
        oneTextFieldModal.setUpUIPopUpController(barButtonItem: nil, sourceView: sender)
        present(oneTextFieldModal, animated: true)
    }

}

///Functionality required for using UITableViewDelegate and UITableViewDataSource
extension SubBlockManagerViewController: UITableViewDelegate, UITableViewDataSource{
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
        nextVC(subBlock: objects[indexPath.row])
    }

    ///Tells the delegate a row is selected.
    ///- Parameter tableView: The table-view object requesting the insertion or deletion.
    ///- Parameter editingStyle: The cell editing style corresponding to a insertion or deletion requested for the row specified by indexPath. Possible editing styles are UITableViewCell.EditingStyle.insert or UITableViewCell.EditingStyle.delete.
    ///- Parameter indexPath: An index path locating the row in tableView.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let subBlock = objects[indexPath.row]
        realmDatabase.deleteSubBlock(subBlock: subBlock){ success, error in
            if(success){
                print("SubBlock Deleted From SubBlockManager")
            }
            else{
                let alertController = UIAlertController(title: "Error: Realm Erro", message: error!, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

///Functionality required for using OneTextFieldModalDelegate
extension SubBlockManagerViewController: OneTextFieldModalDelegate{
    ///Changes subBlocks name
    ///- Parameter returningText: Name of subBlock
    func completionHandler(returningText: String) {
        if objectBeingEdited > -1 && objectBeingEdited < objects.count{
            realmDatabase.updateSubBlock(subBlock: objects[objectBeingEdited], _partition: nil, blockId: nil, title: returningText, date: nil, caches: nil){ success, error in
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
