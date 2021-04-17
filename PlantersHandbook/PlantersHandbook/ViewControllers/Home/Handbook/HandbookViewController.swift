//
//  HandbookVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift
import JDropDownAlert

///HandbookViewController.swift - Manages season and handbook entries
class HandbookViewController: HandbookView {
    fileprivate var seasonNotificationToken: NotificationToken?
    fileprivate var handbookEntryNotificationToken: NotificationToken?
    fileprivate let seasons: Results<Season>
    fileprivate var handbookEntries: Results<HandbookEntry>
    fileprivate var seasonSelected = -1;
    
    ///Contructor that initalizes required fields and does any neccesary start functionality
    required init() {        
        seasons = realmDatabase.findObjectRealm(predicate: nil, classType: Season()).sorted(byKeyPath: "date", ascending: false)
        
        if let season = seasons.first{
            handbookEntries = realmDatabase.findObjectRealm(predicate: NSPredicate(format: "seasonId = %@", season._id), classType: HandbookEntry()).sorted(byKeyPath: "date", ascending: false)
        }
        else{
            handbookEntries = realmDatabase.findObjectRealm(predicate: NSPredicate(format: "seasonId = %@", "Empty"), classType: HandbookEntry())
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
                if(self!.seasonSelected != -1 && tableView.visibleCells.count > 0){
                    tableView.selectRow(at: IndexPath(row: self!.seasonSelected, section: 0), animated: true, scrollPosition: .top)
                }
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
    ///Called when view controller is deinitializing
    deinit {
        handbookEntryNotificationToken?.invalidate()
        seasonNotificationToken?.invalidate()
    }
    
    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Functionality for when view will appear
    ///- Parameter animated: Boolean to decide if view will apear with anination or not
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
            
            let alertController = UIAlertController(title: "Handbook", message: "Welcome to the Handbook section! \nThis is where you can...\n1. Create seasons \n2. Once you select a season, create days  \n\n Press on a day row to edit it, swipe left on an day row or any row in a table to delete it", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: {_ in
                self.saveFirstTimer(finishedFirstTime: true)
            })
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    ///Functionality for when view will disappear
    ///- Parameter animated: Boolean to decide if view will disappear with anination or not
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    ///Configuire all views in programic view controller
    internal override func configureViews() {
        super.configureViews()
        setUpTableDelegates()
    }
    
    ///Set all actions in progrmaic view controller
    internal override func setActions() {
        addEntryButton.addTarget(self, action: #selector(addEntryAction), for: .touchUpInside)
        addSeasonButton.addTarget(self, action: #selector(addSeasonAction), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutAction), for: .touchUpInside)
    }
    
    ///Sets up any table delegates and datasources
    fileprivate func setUpTableDelegates(){
        seasonTableView.delegate = self
        seasonTableView.dataSource = self
        handbookEntrysTableView.delegate = self
        handbookEntrysTableView.dataSource = self
    }
    
    ///Grabs the new set of handbookEntries connected to the seasonId, and sets up the notification for any changes and tableview
    fileprivate func setHandbookEntries(seasonId: String){
        handbookEntries = realmDatabase.findObjectRealm(predicate: NSPredicate(format: "seasonId = %@", seasonId), classType: HandbookEntry()).sorted(byKeyPath: "date", ascending: false)
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
    
    ///Goes to next designated view controller
    fileprivate func nextVC(entry: HandbookEntry) {
        self.navigationController?.pushViewController(
            BlockManagerViewController(title: GeneralFunctions.getDate(from: entry.date), handbookEntry: entry),
            animated: true
        );
    }
    
    ///Opens the AddEntryModal
    @objc fileprivate func addEntryAction(){
        if (seasonSelected > -1) {
            let entryModal = AddEntryModalViewController(seasonId: seasons[seasonSelected]._id)
            entryModal.delegate = self
            entryModal.modalPresentationStyle = .popover
            entryModal.setUpUIPopUpController(barButtonItem: nil, sourceView: addEntryButton)
            present(entryModal, animated: true)
        }else{
            let alertController = UIAlertController(title: "No Season", message: "Please select or create a season", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    ///Opens the AddSeasonModal
    @objc fileprivate func addSeasonAction(){
        let seasonModal = AddSeasonModalViewController()
        seasonModal.delegate = self
        seasonModal.modalPresentationStyle = .popover
        seasonModal.setUpUIPopUpController(barButtonItem: nil, sourceView: addSeasonButton)
        present(seasonModal, animated: true)
    }
    
    ///Logs user out and deletes any custom data user had in user storage
    @objc fileprivate func logoutAction(){
        let alertController = UIAlertController(title: "Logout", message: "Logging out deletes your quickPrep set up and formation of statistics, are you sure you want to logout?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Logout", style: .destructive, handler: {_ in
            app.currentUser?.logOut(){ [weak self] error in
                DispatchQueue.main.async {
                    if(error == nil){
                        self!.userDefaults.removeObject(forKey: "prepTreeTypes")
                        self!.userDefaults.removeObject(forKey: "prepCentPerTreeTypes")
                        self!.userDefaults.removeObject(forKey: "prepBundlesPerTreeTypes")
                        self!.userDefaults.removeObject(forKey: "cardsOrderArray")
                        self!.userDefaults.removeObject(forKey: "seasonsOrderArray")
                        self!.userDefaults.removeObject(forKey: "TallySheetViewController")
                        self!.userDefaults.removeObject(forKey: "StatisticsViewController")
                        self!.userDefaults.removeObject(forKey: "GPSTreeTrackingModalViewController")
                        self!.userDefaults.removeObject(forKey: "HandbookViewController")
                        self!.userDefaults.removeObject(forKey: "BlockManagerViewController")
                        self!.userDefaults.removeObject(forKey: "QuickPrepModalViewController")
                        self!.navigationController?.navigationController?.popToRootViewController(animated: true)
                        self!.navigationController?.pushViewController(WelcomeViewController(), animated: false)
                        
                    }
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

///Functionality required for using UITableViewDelegate, UITableViewDataSource
extension HandbookViewController: UITableViewDelegate, UITableViewDataSource{
    
    ///Tells the data source to return the number of rows in a given section of a table view.
    ///- Parameter tableView: The table-view object requesting this information.
    ///- Parameter section: An index number identifying a section in tableView.
    ///- Returns: Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (tableView == handbookEntrysTableView ? handbookEntries.count : seasons.count)
    }

    ///Asks the data source for a cell to insert in a particular location of the table view.
    ///- Parameter tableView: The table-view object requesting this cell.
    ///- Parameter indexPath: An index path locating a row in tableView.
    ///- Returns: An object inheriting from UITableViewCell that the table view can use for the specified row. UIKit raises an assertion if you return nil.
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
    
    ///Tells the delegate a row is selected.
    ///- Parameter tableView: A table view informing the delegate about the new row selection.
    ///- Parameter indexPath: An index path locating the new selected row in tableView.
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

    ///Tells the delegate a row is selected.
    ///- Parameter tableView: The table-view object requesting the insertion or deletion.
    ///- Parameter editingStyle: The cell editing style corresponding to a insertion or deletion requested for the row specified by indexPath. Possible editing styles are UITableViewCell.EditingStyle.insert or UITableViewCell.EditingStyle.delete.
    ///- Parameter indexPath: An index path locating the row in tableView.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        if(tableView == handbookEntrysTableView){
            let entry = handbookEntries[indexPath.row]
            realmDatabase.deleteEntry(entry: entry){ success, error in
                if(success){
                    print("Entry Deleted From Entry Manager")
                }
                else{
                    let alertController = UIAlertController(title: "Error: Realm Error", message: error!, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        else{
            let season = seasons[indexPath.row]
            realmDatabase.deleteSeason(season: season){ success, error in
                if(success){
                    print("Season Deleted From Season Manager")
                    if(!seasons.isEmpty){
                        seasonSelected = 0
                        setHandbookEntries(seasonId: seasons[seasonSelected]._id)
                    }else{
                        seasonSelected = -1
                    }
                }
                else{
                    let alertController = UIAlertController(title: "Error: Realm", message: error!, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

extension HandbookViewController: AddSeasonModalDelegate{
    ///Inserts season into realm if no errors
    ///- Parameter season: Season to be inserted into realm
    func createSeason(season: Season) {
        if let user = realmDatabase.findLocalUser(){
            realmDatabase.addSeason(user: user, season: season){ success, error in
                if error != nil{
                    let alert = JDropDownAlert()
                    alert.alertWith(error!)
                }
            }
        }
    }
}

extension HandbookViewController: AddEntryModalDelegate{
    ///Inserts HandbookEntry into season if no errors
    ///- Parameter entry: HandbookEntry to be inserted into season
    func createEntry(entry: HandbookEntry) {
        if (seasonSelected > -1) {
            realmDatabase.addEntry(season: seasons[seasonSelected], entry: entry){ success, error in
                if error != nil{
                    let alert = JDropDownAlert()
                    alert.alertWith(error!)
                }
            }
        }
        else{
            let alert = UIAlertController(title: "Season Error", message: "You need to select or create a season", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
}


