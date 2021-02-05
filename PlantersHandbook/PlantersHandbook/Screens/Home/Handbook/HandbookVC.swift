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
    
    fileprivate var seasonNotificationToken: NotificationToken?
    fileprivate var handbookEntryNotificationToken: NotificationToken?
    fileprivate let seasons: Results<Season>
    fileprivate var handbookEntries: Results<HandbookEntry>
    fileprivate let dateLabel = SUI_Label_Date(fontSize: FontSize.largeTitle)
    fileprivate let addEntryButton = PH_Button(title: "Add Entry", fontSize: FontSize.large)
    fileprivate let addSeasonButton = PH_Button(title: "Add Season", fontSize: FontSize.meduim)
    fileprivate var seasonTableView = SUI_TableView()
    fileprivate var handbookEntrysTableView = SUI_TableView()
    fileprivate var logoutButton = PH_Button(title: "Logout", fontSize: FontSize.meduim)
    fileprivate var seasonSelected = -1;
    
    required init() {
        print("Initializing HandbookVC")
        
        seasons = realmDatabase.getSeasonRealm(predicate: nil).sorted(byKeyPath: "_id")
        
        if let season = seasons.first{
            handbookEntries = realmDatabase.getHandbookEntryRealm(predicate: NSPredicate(format: "seasonId = %@", season._id)).sorted(byKeyPath: "date", ascending: false)
        }
        else{
            handbookEntries = realmDatabase.getHandbookEntryRealm(predicate: NSPredicate(format: "seasonId = %@", "Empty"))
        }
        
        super.init(nibName: nil, bundle: nil)
    
        seasonNotificationToken = seasons.observe { [weak self] (changes) in
            guard let tableView = self?.seasonTableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                tableView.performBatchUpdates({
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }),
                        with: .automatic)
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                        with: .automatic)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                        with: .automatic)
                })
            case .error(let error):
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
        titleLayout = SUI_View(backgoundColor: .systemBackground)
        actionLayout = SUI_View(backgoundColor: .systemBackground)
        tableViewLayout = SUI_View(backgoundColor: .systemBackground)
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
        [dateLabel, logoutButton].forEach{titleLayout.addSubview($0)}

        logoutButton.anchor(top: nil, leading: titleLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 5, bottom: 0, right: 0), size: .init(width: titleLayout.safeAreaFrame.width*0.2, height: titleLayout.safeAreaFrame.height*0.4))
        logoutButton.anchorCenterY(to: dateLabel)
        logoutButton.setTitleColor(.secondaryLabel, for: .normal)
        
        dateLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width/2, height: titleLayout.safeAreaFrame.height/2))
        dateLabel.anchorCenter(to: titleLayout)
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
        handbookEntries = realmDatabase.getHandbookEntryRealm(predicate: NSPredicate(format: "seasonId = %@", seasonId)).sorted(byKeyPath: "date", ascending: false)
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
            BlockManagerVC(title: getDate(from: entry.date), handbookId: entry._id),
            animated: true
        );
    }
    
    @objc func addEntryAction(){
        if (seasonSelected > -1) {
            
            let entries = realmDatabase.getHandbookEntryRealm(predicate: NSPredicate(format: "seasonId = %@", seasons[seasonSelected]._id)).sorted(byKeyPath: "date", ascending: false)
            if entries.contains{getDate(from: $0.date) == getDate(from: Date())}{
                let alert = UIAlertController(title: "Duplicate Entry", message: "You already have a entry for today, please edit or delete it to add entry", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            else{
                let entry = HandbookEntry(partition: realmDatabase.getParitionValue()!, seasonId: seasons[seasonSelected]._id)
                realmDatabase.add(item: entry)
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
        app.currentUser?.logOut(){ [weak self] error in
            DispatchQueue.main.async {
                if(error == nil){
                    self!.navigationController?.navigationController?.popToRootViewController(animated: true)
                }
            }
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
            cell.textLabel?.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.largeTitle))
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
            realmDatabase.deleteEntry(entry: entry){ (result) in
                if(result){
                    print("Entry Deleted From Entry Manager")
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
            realmDatabase.deleteSeason(season: season){ (result) in
                if(result){
                    print("Season Deleted From Season Manager")
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
            realmDatabase.add(item: season)
            setHandbookEntries(seasonId: season._id)
        }
    }
}


