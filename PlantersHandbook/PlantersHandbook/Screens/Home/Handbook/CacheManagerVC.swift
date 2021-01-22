//
//  CacheManagerVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift

class CacheManagerVC: ProgramicVC {
    
    fileprivate var titleLayout : UIView!
    fileprivate var actionLayout : UIView!
    fileprivate var tableViewLayout : UIView!
    
    let subBlockId: String
    let realm: Realm
    let partitionValue: String
    var cacheNotificationToken: NotificationToken?
    let caches: Results<Cache>
    fileprivate let titleLb : UILabel
    fileprivate let cacheNameInput = textField_form(placeholder: "", textType: .name)
    fileprivate let addCacheButton = ph_button(title: "Add Cache", fontSize: FontSize.large)
    fileprivate var cacheTableView = tableView_normal()
    
    required init(realm: Realm, title: String, subBlockId: String) {
        guard let syncConfiguration = realm.configuration.syncConfiguration else {
            fatalError("Sync configuration not found! Realm not opened with sync?");
        }
        
        self.realm = realm
        self.partitionValue = syncConfiguration.partitionValue!.stringValue!
        self.caches = realm.objects(Cache.self).filter(NSPredicate(format: "subBlockId = %@", subBlockId)).sorted(byKeyPath: "_id")
        self.subBlockId = subBlockId
        self.titleLb = label_normal(title: "SubBlock: " + title, fontSize: FontSize.extraLarge)
       
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Caches"

        cacheNotificationToken = caches.observe { [weak self] (changes) in
            guard let tableView = self?.cacheTableView else { return }
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
    
    
    override func generateLayout() {
        titleLayout = generalLayout(backgoundColor: .systemBackground)
        actionLayout = generalLayout(backgoundColor: .systemBackground)
        tableViewLayout = generalLayout(backgoundColor: .systemBackground)
    }
    
    override func configureViews() {
        setUpOverlay()
        setUpTitleLayout()
        setUpActionLayout()
        setUpTableViewLayout()
        setUpTableDelegates()
        keyboardMoveUpWhenTextFieldTouched = 0
    }
    
    override func setActions() {
        addCacheButton.addTarget(self, action: #selector(addCacheAction), for: .touchUpInside)
    }
    
    func setUpOverlay(){
        let frame = bgView.safeAreaFrame
        
        [titleLayout, actionLayout, tableViewLayout].forEach{bgView.addSubview($0)}
        
        titleLayout.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, padding: .init(top: 10, left: 0, bottom: 0, right: 0),size: .init(width: frame.width, height: frame.height*0.1))
        
        actionLayout.anchor(top: titleLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.20))
        
        tableViewLayout.anchor(top: actionLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.70))
    }
    
    func setUpTitleLayout(){
        [titleLb].forEach{titleLayout.addSubview($0)}
        
        titleLb.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width/2, height: titleLayout.safeAreaFrame.height/2))
        titleLb.anchorCenter(to: titleLayout)
    }
    
    func setUpActionLayout(){
        let actionFrame = actionLayout.safeAreaFrame
        let textFieldBoundarySpace = CGFloat(50)
        
        [cacheNameInput, addCacheButton].forEach{actionLayout.addSubview($0)}

        cacheNameInput.anchor(top: actionLayout.topAnchor, leading: actionLayout.leadingAnchor, bottom: nil, trailing: actionLayout.trailingAnchor, padding: .init(top: 5, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        cacheNameInput.anchorCenterX(to: actionLayout)
        self.cacheNameInput.delegate = self
        cacheNameInput.textAlignment = .center
        
        addCacheButton.anchor(top: cacheNameInput.bottomAnchor, leading: nil, bottom: actionLayout.bottomAnchor, trailing: nil, padding: .init(top: 10, left: 0, bottom: 0, right: 0),size: .init(width: actionFrame.width*0.6, height: 0))
        addCacheButton.anchorCenterX(to: actionLayout)
    }
    
    func setUpTableViewLayout(){
        [cacheTableView].forEach{tableViewLayout.addSubview($0)}

        cacheTableView.rowHeight = 70
        cacheTableView.anchor(top: tableViewLayout.topAnchor, leading: tableViewLayout.leadingAnchor, bottom: tableViewLayout.bottomAnchor, trailing: tableViewLayout.trailingAnchor, padding: .init(top: 20, left: 0, bottom: 0, right: 0))
        
        setUpTableDelegates()
    }
    
    func setUpTableDelegates(){
        cacheTableView.delegate = self
        cacheTableView.dataSource = self
    }
    
    func nextVC(cache: Cache){
        self.navigationController?.pushViewController(
            TallySheetVC(realm: realm, cache: cache),
            animated: true
        )
    }
    
    @objc func addCacheAction(){
        if (caches.contains{$0.title == cacheNameInput.text!}) {
                let alert = UIAlertController(title: "Duplicate SubBlock", message: "You already have a subBlock with that name in this entry, use a different name", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
        }
        else{
            if(cacheNameInput.text! != ""){
                let cache = Cache(partition: partitionValue, title: cacheNameInput.text!, subBlockId: subBlockId)
                try! self.realm.write {
                    self.realm.add(cache)
                }
            }
        }
        cacheNameInput.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

}

extension CacheManagerVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return caches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = caches[indexPath.row].title
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.large))
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        nextVC(cache: caches[indexPath.row])
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let cache = caches[indexPath.row]
        deleteCache(cache: cache, realm: realm){ (result) in
            if(result){
                print("Cache Deleted")
            }
            else{
                let alertController = UIAlertController(title: "Error: Realm Error", message: "Could Not Delete Cache", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}

