//
//  HandbookVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift

class HandbookVC: ProgramicVC {
    
    fileprivate var titleLayout : UIView!
    fileprivate var actionLayout : UIView!
    fileprivate var tableViewLayout : UIView!
    
    let realm: Realm
    let partitionValue: String
    var seasonNotificationToken: NotificationToken?
    var handbookEntryNotificationToken: NotificationToken?
    let seasons: Results<Season>
    var handbookEntries: Results<HandbookEntry>
    fileprivate let dateLb = label_date(fontSize: FontSize.extraLarge)
    fileprivate let addEntryButton = ph_button(title: "Add Entry", fontSize: FontSize.extraLarge)
    fileprivate let addSeasonButton = ph_button(title: "Add Season", fontSize: FontSize.meduim)
    fileprivate var seasonTableView = tableView_normal()
    fileprivate var handbookEntrysTableView = tableView_normal()
    fileprivate var logoutButton = ph_button(title: "Logout", fontSize: FontSize.small)
    fileprivate var seasonSelected = -1;
    
    required init(realm: Realm) {
        guard let syncConfiguration = realm.configuration.syncConfiguration else {
            fatalError("Sync configuration not found! Realm not opened with sync?");
        }
        self.realm = realm

        // Partition value must be of string type.
        partitionValue = syncConfiguration.partitionValue!.stringValue!

        // Access all tasks in the realm, sorted by _id so that the ordering is defined.
        seasons = realm.objects(Season.self).sorted(byKeyPath: "_id")
        if let season = seasons.first{
            let predicate = NSPredicate(format: "seasonId = %@", season._id)
            handbookEntries = realm.objects(HandbookEntry.self).filter(predicate)
        }
        else{
            handbookEntries = realm.objects(HandbookEntry.self).filter(NSPredicate(format: "seasonId = %@", "Empty"))
        }
        
        super.init(nibName: nil, bundle: nil)

        seasonNotificationToken = seasons.observe { [weak self] (changes) in
            guard let tableView = self?.seasonTableView else { return }
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
        handbookEntryNotificationToken?.invalidate()
        seasonNotificationToken?.invalidate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        if(!seasons.isEmpty && seasonSelected == -1){
            seasonSelected = 0
            seasonTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
            setHandbookEntries(seasonId: seasons[seasonSelected]._id)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
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
        addEntryButton.addTarget(self, action: #selector(addEntryAction), for: .touchUpInside)
        addSeasonButton.addTarget(self, action: #selector(addSeasonAction), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutAction), for: .touchUpInside)
    }
    
    func setUpOverlay(){
        let frame = bgView.safeAreaFrame
        
        [titleLayout, actionLayout, tableViewLayout].forEach{bgView.addSubview($0)}
        
        titleLayout.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, padding: .init(top: 10, left: 0, bottom: 0, right: 0),size: .init(width: frame.width, height: frame.height*0.1))
        
        actionLayout.anchor(top: titleLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.20))
        tableViewLayout.anchor(top: actionLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.70))
    }
    
    func setUpTitleLayout(){
        [dateLb, logoutButton].forEach{titleLayout.addSubview($0)}

        logoutButton.anchor(top: nil, leading: titleLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 5, bottom: 0, right: 0), size: .init(width: titleLayout.safeAreaFrame.width*0.2, height: titleLayout.safeAreaFrame.height*0.4))
        logoutButton.anchorCenterY(to: dateLb)
        logoutButton.setTitleColor(.secondaryLabel, for: .normal)
        
        dateLb.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width/2, height: titleLayout.safeAreaFrame.height/2))
        dateLb.anchorCenter(to: titleLayout)
    }
    
    func setUpActionLayout(){
        [addEntryButton, addSeasonButton].forEach{actionLayout.addSubview($0)}

        addEntryButton.anchor(top: actionLayout.topAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0),size: .init(width: actionLayout.safeAreaFrame.width/2, height: actionLayout.safeAreaFrame.height/2))
        addEntryButton.anchorCenterX(to: actionLayout)
        
        addSeasonButton.anchor(top: addEntryButton.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 20, left: 0, bottom: 0, right: 0),size: .init(width: actionLayout.safeAreaFrame.width/4, height: actionLayout.safeAreaFrame.height/4))
        addSeasonButton.anchorCenterX(to: actionLayout)
    }
    
    func setUpTableViewLayout(){
        [seasonTableView, handbookEntrysTableView].forEach{tableViewLayout.addSubview($0)}

        seasonTableView.rowHeight = 70
        handbookEntrysTableView.rowHeight = 50
        
        seasonTableView.anchor(top: tableViewLayout.topAnchor, leading: tableViewLayout.leadingAnchor, bottom: bgView.safeAreaLayoutGuide.bottomAnchor, trailing: nil, size: .init(width: tableViewLayout.safeAreaFrame.width/2, height: tableViewLayout.safeAreaFrame.height))
        
        handbookEntrysTableView.anchor(top: tableViewLayout.topAnchor, leading: seasonTableView.trailingAnchor, bottom: bgView.safeAreaLayoutGuide.bottomAnchor, trailing: tableViewLayout.trailingAnchor, size: .init(width: tableViewLayout.safeAreaFrame.width/2, height: tableViewLayout.safeAreaFrame.height))
    }
    
    func setUpTableDelegates(){
        seasonTableView.delegate = self
        seasonTableView.dataSource = self
        handbookEntrysTableView.delegate = self
        handbookEntrysTableView.dataSource = self
    }
    
    func setHandbookEntries(seasonId: String){
        handbookEntries = realm.objects(HandbookEntry.self).filter(NSPredicate(format: "seasonId = %@", seasonId))
        handbookEntryNotificationToken = handbookEntries.observe { [weak self] (changes) in
            guard let tableView = self?.handbookEntrysTableView else { return }
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
    
    func nextVC(entry: HandbookEntry) {
        self.navigationController?.pushViewController(
            BlockManagerVC(realm: realm, title: getDate(from: entry.date), handbookId: entry._id),
            animated: true
        );
    }
    
    @objc func addEntryAction(){
        if (seasonSelected > -1) {
            let entries = realm.objects(HandbookEntry.self).filter(NSPredicate(format: "seasonId = %@", seasons[seasonSelected]._id))
            if entries.contains{getDate(from: $0.date) == getDate(from: Date())}{
                let alert = UIAlertController(title: "Duplicate Entry", message: "You already have a entry for today, please edit or delete it to add entry", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            else{
                let entry = HandbookEntry(partition: "user=" + app.currentUser!.id, seasonId: seasons[seasonSelected]._id)
                try! self.realm.write {
                    self.realm.add(entry)
                }
            }
        }
        else{
            let alert = UIAlertController(title: "Season Error", message: "You need to select or create a season", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    @objc func addSeasonAction(){
        //Seurge to Model
        let seasonModal = SeasonModal()
        seasonModal.delegate = self
        seasonModal.modalPresentationStyle = .popover
        present(seasonModal, animated: true)
    }
    
    @objc func logoutAction(){
        app.currentUser?.logOut(){ (result) in
            self.navigationController?.navigationController?.popToRootViewController(animated: true)
        }
    }
}

extension HandbookVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tableView == handbookEntrysTableView ? handbookEntries.count : seasons.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if(tableView == self.seasonTableView){
            cell.textLabel?.text = seasons[indexPath.row].title
            cell.textLabel?.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.extraLarge))
        }
        else{
            cell.textLabel?.text = getDate(from: handbookEntries[indexPath.row].date)
            cell.textLabel?.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.large))
            cell.backgroundColor = .secondarySystemFill
        }
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView == handbookEntrysTableView){
            tableView.deselectRow(at: indexPath, animated: false)
            nextVC(entry: handbookEntries[indexPath.row])
        }
        else{
            seasonSelected = indexPath.row
            setHandbookEntries(seasonId: seasons[indexPath.row]._id)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        if(tableView == handbookEntrysTableView){
            let entry = handbookEntries[indexPath.row]
            deleteEntry(entry: entry, realm: realm){ (result) in
                if(result){
                    print("Entry Deleted")
                }
                else{
                    let alertController = UIAlertController(title: "Error: Realm Error", message: "Could Not Delete Handbook Entry", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        else{
            let season = seasons[indexPath.row]
            deleteSeason(season: season, realm: realm){ (result) in
                if(result){
                    if(!seasons.isEmpty){
                        seasonSelected = 0
                        seasonTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
                        setHandbookEntries(seasonId: seasons[seasonSelected]._id)
                    }
                }
                else{
                    let alertController = UIAlertController(title: "Error: Realm", message: "Error Could Not Delete Season", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

}

extension HandbookVC: SeasonModal_Delegate{
    func createSeason(season: Season) {
        if(seasons.contains {$0.title == season.title}){
            let alertController = UIAlertController(title: "Error: Could Not Add Season", message: "Name already taken", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            try! realm.write{
                realm.add(season)
            }
            setHandbookEntries(seasonId: season._id)
        }
    }
}


