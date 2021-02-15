//
//  HandbookVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift

class HandbookViewController: HandbookView {
    
    fileprivate var seasonNotificationToken: NotificationToken?
    fileprivate var handbookEntryNotificationToken: NotificationToken?
    fileprivate let seasons: Results<Season>
    fileprivate var handbookEntries: Results<HandbookEntry>

    fileprivate var seasonSelected = -1;
    
    required init() {        
        seasons = realmDatabase.getSeasonRealm(predicate: nil).sorted(byKeyPath: "_id", ascending: false)
        
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
//                if !insertions.isEmpty{
//                    print("inserted season")
//                    tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .middle)
//                }
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
        firstTimerKey = "HandbookViewController"
        if(isFirstTimer()){
            
            let alertController = UIAlertController(title: "Handbook", message: "Welcome to the Handbook section! \nThis is where you can...\n1. Create seasons \n2. Once you select a season, create entrys ('days')  \n\n Press on a entry to edit it", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: {_ in
                self.saveFirstTimer(finishedFirstTime: true)
            })
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    internal override func configureViews() {
        super.configureViews()
        setUpTableDelegates()
    }
    
    internal override func setActions() {
        addEntryButton.addTarget(self, action: #selector(addEntryAction), for: .touchUpInside)
        addSeasonButton.addTarget(self, action: #selector(addSeasonAction), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutAction), for: .touchUpInside)
    }
    
    fileprivate func setUpTableDelegates(){
        seasonTableView.delegate = self
        seasonTableView.dataSource = self
        handbookEntrysTableView.delegate = self
        handbookEntrysTableView.dataSource = self
    }
    
    fileprivate func setHandbookEntries(seasonId: String){
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
    
    fileprivate func nextVC(entry: HandbookEntry) {
        self.navigationController?.pushViewController(
            BlockManagerViewController(title: GeneralFunctions.getDate(from: entry.date), handbookId: entry._id),
            animated: true
        );
    }
    
    @objc fileprivate func addEntryAction(){
        if (seasonSelected > -1) {
            let entryModal = AddEntryModalViewController(seasonId: seasons[seasonSelected]._id)
            entryModal.delegate = self
            entryModal.modalPresentationStyle = .popover
            present(entryModal, animated: true)
        }
    }
    
    @objc fileprivate func addSeasonAction(){
        let seasonModal = AddSeasonModalViewController()
        seasonModal.delegate = self
        seasonModal.modalPresentationStyle = .popover
        present(seasonModal, animated: true)
    }
    
    @objc fileprivate func logoutAction(){
        app.currentUser?.logOut(){ [weak self] error in
            DispatchQueue.main.async {
                if(error == nil){
                    self!.navigationController?.navigationController?.popToRootViewController(animated: true)
                    self!.navigationController?.pushViewController(WelcomeViewController(), animated: false)
                }
            }
        }
    }
}

extension HandbookViewController: UITableViewDelegate, UITableViewDataSource{
    
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
            cell.textLabel?.text = GeneralFunctions.getDate(from: handbookEntries[indexPath.row].date)
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

extension HandbookViewController: AddSeasonModalDelegate{
    func createSeason(season: Season) {
        if(seasons.contains {$0.title == season.title}){
            let alertController = UIAlertController(title: "Error: Could Not Add Season", message: "Name already taken", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            realmDatabase.add(item: season)
        }
    }
}

extension HandbookViewController: AddEntryModalDelegate{
    func createEntry(entry: HandbookEntry) {
        if (seasonSelected > -1) {
            let entries = realmDatabase.getHandbookEntryRealm(predicate: NSPredicate(format: "seasonId = %@", seasons[seasonSelected]._id)).sorted(byKeyPath: "date", ascending: false)
            if entries.contains{GeneralFunctions.getDate(from: $0.date) == GeneralFunctions.getDate(from: entry.date)}{
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    let alert = UIAlertController(title: "Duplicate Entry", message: "You already have a entry for today, please edit or delete it to add entry", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                return
            }
            else{
                realmDatabase.add(item: entry)
            }
        }
        else{
            let alert = UIAlertController(title: "Season Error", message: "You need to select or create a season", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
}


