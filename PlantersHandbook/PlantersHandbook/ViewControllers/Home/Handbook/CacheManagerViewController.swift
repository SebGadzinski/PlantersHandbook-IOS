//
//  CacheManagerVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift
import JDropDownAlert

///CacheManagerViewController.swift -Manages caches in a subBlock
class CacheManagerViewController: CacheManagerView {
    
    ///Initializes required fields
    ///- Parameter title: Title of the manager
    ///- Parameter subBlock: Upper HierarchyObject to the objects in the manager is managing
    required init(title: String, subBlock: SubBlock) {
        super.init(title: title, upperHierarchyObject: subBlock, idString: "subBlockId")
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
    fileprivate func nextVC(cache: Cache){
        self.navigationController?.pushViewController(
            TallySheetViewController(cache: cache),
            animated: true
        )
    }
    
    ///Adds a cache to given list and updates database
    @objc override func addAction(){
        super.addAction()
        if(nameTextField.text! != ""){
            let cache = Cache(partition: realmDatabase.getParitionValue()!, title: nameTextField.text!, subBlockId: upperHierarchyObject._id)
            realmDatabase.addCache(subBlock: upperHierarchyObject, cache: cache){ success, error in
                if error != nil{
                    let alert = JDropDownAlert()
                    alert.alertWith(error!)
                }
            }
        }
        view.endEditing(true)
        nameTextField.text = ""
    }
    
    ///Opens OneTextFieldModalViewController which is used to rename a cache
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

extension CacheManagerViewController: UITableViewDelegate, UITableViewDataSource{
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
        nextVC(cache: objects[indexPath.row])
    }

    ///Tells the delegate a row is selected.
    ///- Parameter tableView: The table-view object requesting the insertion or deletion.
    ///- Parameter editingStyle: The cell editing style corresponding to a insertion or deletion requested for the row specified by indexPath. Possible editing styles are UITableViewCell.EditingStyle.insert or UITableViewCell.EditingStyle.delete.
    ///- Parameter indexPath: An index path locating the row in tableView.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let cache = objects[indexPath.row]
        realmDatabase.deleteCache(cache: cache){ success, error in
            if(success){
                print("Cache Deleted From CacheManager")
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
extension CacheManagerViewController: OneTextFieldModalDelegate{
    ///Changes cache name
    ///- Parameter returningText: Name of cache
    func completionHandler(returningText: String) {
        if objectBeingEdited > -1 && objectBeingEdited < objects.count{
            realmDatabase.updateCacheTitle(cache: objects[objectBeingEdited], title: returningText){ success, error in
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

