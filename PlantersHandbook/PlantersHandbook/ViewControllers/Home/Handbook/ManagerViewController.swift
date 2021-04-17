//
//  ManagerViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-04-05.
//

import UIKit
import RealmSwift

class ManagerViewController<ObjectClass:Object, HierarchyObjectClass:Object>: ManagerView, ManagerInterface { 
    internal let upperHierarchyObject: HierarchyObjectClass
    internal var objectNotificationToken: NotificationToken?
    internal var objects: Results<ObjectClass>!
    internal var objectBeingEdited = -1
    fileprivate let idString : String
    
    ///Initializes required fields
    ///- Parameter title: Title of the manager
    ///- Parameter upperHierarchyObject: Upper HierarchyObject to the objects in the manager is managing
    ///- Parameter idString: String for identifying the object ( I don't like using this but its neccesary right now
    init(title: String, upperHierarchyObject: HierarchyObjectClass, idString: String) {
        self.idString = idString
        self.objects = realmDatabase.findObjectRealm(predicate: NSPredicate(format: "\(idString) = %@",  upperHierarchyObject.value(forKey: "_id") as! String), classType: ObjectClass()).sorted(byKeyPath: "_id")
        self.upperHierarchyObject = upperHierarchyObject
       
        super.init(nibName: nil, bundle: nil)
        
        titleLabel.text = HierarchyObjectClass.className() + ": " + title
        self.title = ObjectClass.className() + "s"

        if(objects != nil){
            objectNotificationToken = objects.observe { [weak self] (changes) in
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
        textFieldShouldReturn = true
    }
    
    ///Called when view controller is deinitializing
    deinit {
        objectNotificationToken?.invalidate()
    }
    
    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Configuire all views in programic view controller
    internal override func configureViews() {
        super.configureViews()
        addButton.setTitle("Add \(ObjectClass.className())", for: .normal)
    }
    
    ///Set all actions in progrmaic view controller
    internal override func setActions() {
        addButton.addTarget(self, action: #selector(addAction), for: .touchUpInside)
    }
    
    ///Sets up any table delegates and datasources
    internal func setUpTableDelegates(){
    }
    
    ///Goes to next designated view controller
    internal func nextVC(object: ObjectClass){
    }
    
    ///Adds a object  to given list and updates database
    @objc internal func addAction(){
    }
    
    ///Opens OneTextFieldModalViewController which is used to rename a subBlock
    @objc func hamburgerMenuTapped(sender: UIButton) {
    }

}
