//
//  CacheManagerVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift
import JDropDownAlert

class CacheManagerViewController: CacheManagerView {
    
    fileprivate let subBlock: SubBlock
    fileprivate var cacheNotificationToken: NotificationToken?
    fileprivate let caches: Results<Cache>
    fileprivate var cacheBeingEdited = -1

    required init(title: String, subBlock: SubBlock) {
        self.caches = realmDatabase.getCacheRealm(predicate: NSPredicate(format: "subBlockId = %@", subBlock._id)).sorted(byKeyPath: "_id")
        self.subBlock = subBlock
        
        super.init(nibName: nil, bundle: nil)
        
        titleLabel.text = "SubBlock: " + title
        self.title = "Caches"

        cacheNotificationToken = caches.observe { [weak self] (changes) in
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
        cacheNotificationToken?.invalidate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal override func configureViews() {
        super.configureViews()
        setUpTableDelegates()
        addButton.setTitle("Add Cache", for: .normal)
    }
    
    internal override func setActions() {
        addButton.addTarget(self, action: #selector(addCacheAction), for: .touchUpInside)
    }
    
    fileprivate func setUpTableDelegates(){
        managerTableView.delegate = self
        managerTableView.dataSource = self
    }
    
    fileprivate func nextVC(cache: Cache){
        self.navigationController?.pushViewController(
            TallySheetViewController(cache: cache),
            animated: true
        )
    }
    
    @objc fileprivate func addCacheAction(){
        if(nameTextField.text! != ""){
            let cache = Cache(partition: realmDatabase.getParitionValue()!, title: nameTextField.text!, subBlockId: subBlock._id)
            realmDatabase.addCache(subBlock: subBlock, cache: cache){ success, error in
                if error != nil{
                    let alert = JDropDownAlert()
                    alert.alertWith(error!)
                }
            }
        }
        view.endEditing(true)
        nameTextField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    @objc func hamdbugerMenuTapped(sender: UIButton) {
        cacheBeingEdited = sender.tag
        let oneTextFieldModal = OneTextFieldModalViewController(title: "Rename Block", textForTextField: caches[cacheBeingEdited].title)
        oneTextFieldModal.delegate = self
        oneTextFieldModal.modalPresentationStyle = .popover
        present(oneTextFieldModal, animated: true)
    }

}

extension CacheManagerViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return caches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditCell", for: indexPath) as! EditableTableViewCell
        cell.textLabel?.text = caches[indexPath.row].title
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.extraLarge))
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.hamburgerMenu.addTarget(self, action: #selector(hamdbugerMenuTapped), for: .touchUpInside)
        cell.hamburgerMenu.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        nextVC(cache: caches[indexPath.row])
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let cache = caches[indexPath.row]
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

extension CacheManagerViewController: OneTextFieldModalDelegate{
    func completionHandler(returningText: String) {
        if cacheBeingEdited > -1 && cacheBeingEdited < caches.count{
            realmDatabase.updateCacheTitle(cache: caches[cacheBeingEdited], title: returningText){ success, error in
                if error != nil{
                    let alert = JDropDownAlert()
                    alert.alertWith("Error with database, restart app if further errors : " + error!)
                }
            }
            let indexPath = IndexPath(item: cacheBeingEdited, section: 0)
            managerTableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
}

