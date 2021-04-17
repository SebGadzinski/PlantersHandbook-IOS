//
//  TallySheetVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift
import CoreLocation
import GoogleMaps
import JDropDownAlert

///TallySheetViewController.swift - Represents a tally sheet for a cache
class TallySheetViewController: TallySheetView {

    fileprivate let cache: Cache
    fileprivate var clearingData = false
    fileprivate var gpsButtonClicked = false
    fileprivate var locationManagerNotificationToken: NotificationToken?
    fileprivate var counter : Int = 0
    fileprivate var freshCounter = 0
    fileprivate var timer = Timer()
    fileprivate var isPlaying = false
    
    var locationManager: CLLocationManager!
    
    ///Contructor that initalizes required fields and does any neccesary start functionality
    ///- Parameter cache:Cache that is being managed
    required init(cache: Cache) {
        print(cache)
        self.cache = cache
       
        super.init(nibName: nil, bundle: nil)
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
        locationManager.delegate = self
        cache.secondsPlanted.forEach{counter += $0}
        
        realmDatabase.updateCacheIsPlanting(cache: cache, bool: false){ success, error in
            if error != nil{
                let alert = JDropDownAlert()
                alert.alertWith("Error with database, restart app if further errors")
            }
        }
        self.title = "Cache: " + cache.title
    }
    
    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Called when view controller is deinitializing
    deinit {
        timer.invalidate()
    }
    
    ///Functionality for when view will appear
    ///- Parameter animated: Boolean to decide if view will apear with anination or not
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.items![0].isEnabled = false
        firstTimerKey = "TallySheetViewController"
        if(isFirstTimer()){
            let alertController = UIAlertController(title: "Tally Sheet", message: "Welcome to the Tally Sheet! \nBeside the cache title is a button which leads to the GPS section. On the top bar there is the date, buttons that lead to QuickPrep, Plots, and clearing the sheet. \n First 3 sets of inputs (rows of green lines) are meant for treetypes (SX), cent per trees (0.16), and bundle amounts (20). \nThe middle section is your bag ups. There is 20 inputs available, if you need more... start packing heavier 😜. \n Lastly at the bottom is your total trees and total cash for each tree type \n\n There are 8 columns total (8 different tree types) for each tally sheet (each Cache) \n\n", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: {_ in
                self.saveFirstTimer(finishedFirstTime: true)
            })
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    ///Set up overlay of view for all views in programic view controller
    override func setUpOverlay() {
        super.setUpOverlay()
        self.tabBarController?.delegate = self
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItem.Style.plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    ///Functionality for when view will disappear
    ///- Parameter animated: Boolean to decide if view will disappear with anination or not
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.items![0].isEnabled = true
        if(cache.isPlanting){
            realmDatabase.updateCacheIsPlanting(cache: self.cache, bool: false){ success, error in
                if error != nil{
                    let alert = JDropDownAlert()
                    alert.alertWith("Error with database, restart app if further errors")
                }
            }
            self.stopTrackingLocation()
        }
    }
    
    ///Checks to see if user want to stop tracking their current gps path
    ///- Parameter sender: Back button on navigation controller
    @objc func back(sender: UIBarButtonItem) {
        // Perform your custom actions
        checkIfGPSStillOn()
    }
    
    func checkIfGPSStillOn(){
        if(cache.isPlanting){
            let alertController = UIAlertController(title: "Stop Tracking?", message: "Currently tracking planting path, do you want to stop?", preferredStyle: .alert)

            let stopAction = UIAlertAction(title: "Stop", style: .destructive) { (_) -> Void in
                self.navigationController?.popViewController(animated: true)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

            alertController.addAction(cancelAction)
            alertController.addAction(stopAction)
            
            self.present(alertController, animated: true, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }

    ///Configuire all views in programic view controller
    internal override func configureViews() {
        super.configureViews()
        setUpTableDelegates()
        findHandbookDate()
    }
    
    ///Set all actions in progrmaic view controller
    internal override func setActions() {
        clearButton.addTarget(self, action: #selector(clearFieldsButtonAction), for: .touchUpInside)
        quickFillButton.addTarget(self, action: #selector(quickPrepButtonAction), for: .touchUpInside)
        plotsButton.addTarget(self, action: #selector(plotsButtonAction), for: .touchUpInside)
        let gpsButton = UIBarButtonItem(title: "GPS", style: .plain, target: self, action: #selector(gpsButtonAction))
        self.navigationItem.rightBarButtonItem = gpsButton
    }

    ///Sets up any table delegates and datasources
    fileprivate func setUpTableDelegates(){
        treeTypesCollectionView.delegate = self
        treeTypesCollectionView.dataSource = self
        centPerTreeTypeCollectionView.delegate = self
        centPerTreeTypeCollectionView.dataSource = self
        bundlePerTreeTypeCollectionView.delegate = self
        bundlePerTreeTypeCollectionView.dataSource = self
        for i in 0..<20{
            bagUpCollectionViews[i].delegate = self
            bagUpCollectionViews[i].dataSource = self
        }
        totalTreesPerTreeTypesCollectionView.delegate = self
        totalTreesPerTreeTypesCollectionView.dataSource = self
        totalCashPerTreeTypesCollectionView.delegate = self
        totalCashPerTreeTypesCollectionView.dataSource = self
    }
    
    ///Finds handbook date from subBlock
    fileprivate func findHandbookDate(){
        if let subblock = realmDatabase.findObjectById(Id: cache.subBlockId, classType: SubBlock()){
            if let block = realmDatabase.findObjectById(Id: subblock.blockId, classType: Block()){
                if let handbookEntry = realmDatabase.findObjectById(Id: block.entryId, classType: HandbookEntry()){
                    dateLabel.text = GeneralFunctions.getDate(from: handbookEntry.date)
                }
            }
        }
    }
    
    ///Opens QuickPrepModalViewController
    @objc fileprivate func quickPrepButtonAction(){
        let quickPrepModal = QuickPrepModalViewController()
        quickPrepModal.delegate = self
        quickPrepModal.modalPresentationStyle = .popover
        quickPrepModal.setUpUIPopUpController(barButtonItem: nil, sourceView: quickFillButton)
        present(quickPrepModal, animated: true)
    }
    
    ///Calls to open gps modal if the user has location services on and privacy restraints checked to allow
    @objc fileprivate func gpsButtonAction(){
        gpsButtonClicked = true
        locationManager.requestAlwaysAuthorization()
        if locationManager.authorizationStatus == CLAuthorizationStatus.authorizedAlways{
            gpsButtonClicked = false
            goToGPSModal()
        }
        else{
            let alertController = UIAlertController(title: "Turn On Always Location", message: "Please go to Settings and turn on 'Always' location tracking to allow the application to track your phone while it is turned off and on different applications. \nThe location tracking gets turned off when you leave the Tally Sheet (ie. press 'Back' on the navigation bar) or when you press stop planting on the GPS Section. \n\n Without this the application won't track effectively", preferredStyle: .alert)

            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                 }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)

            alertController.addAction(cancelAction)
            alertController.addAction(settingsAction)

            // check the permission status
            switch(CLLocationManager.authorizationStatus()) {
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Authorized.")
                    gpsButtonClicked = false
                    goToGPSModal()
                    // get the user location
                case .notDetermined, .restricted, .denied:
                    // redirect the users to settings
                    self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    ///Opens GPSTreeTrackingModalViewController
    fileprivate func goToGPSModal(){
        let gpsModal = GPSTreeTrackingModalViewController(title: self.title! + " GPS Tree Tracking", cacheCoordinates: cache.coordinatesCovered, treesPerPlot: cache.treePerPlot, locationManager: locationManager, secondsPlanted: cache.secondsPlanted)
        gpsModal.delegate = self
        gpsModal.modalPresentationStyle = .popover
        gpsModal.setUpUIPopUpController(barButtonItem: self.navigationItem.rightBarButtonItem, sourceView: nil)
        present(gpsModal, animated: true)
    }
    
    ///Opens PlotModalViewController
    @objc func plotsButtonAction(){
        let plotsModal = PlotsModalViewController(title: self.title! + " Plots", plots: cache.plots)
        plotsModal.modalPresentationStyle = .popover
        plotsModal.setUpUIPopUpController(barButtonItem: nil, sourceView: plotsButton)
        present(plotsModal, animated: true)
    }
    
    ///Ensures changes to a treeType UITextField is put into the caches treeTypes and saved in the realm
    ///- Parameter sender: treeType UITextField
    @objc fileprivate func treeTypesInputAction(sender: UITextField){
        realmDatabase.replaceItemInList(list: cache.treeTypes, index: sender.tag, item: sender.text!){ success, error in
            if error != nil{
                let alert = JDropDownAlert()
                alert.alertWith("Error with database, restart app if further errors : " + error!)
            }
        }
    }
    
    ///Ensures changes to a centPerTreeType UITextField is put into the caches centPerTreeTypes and saved in the realm
    ///- Parameter sender: CentPerTreeType UITextField
    @objc fileprivate func centPerTreeInputAction(sender: UITextField){
        if(sender.text!.containsLetters()){
            let alert = UIAlertController(title: "Error: Incorrect Type", message: "Please use numbers only for cent per tree value", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
            sender.text = ""
        }
        else{
            realmDatabase.replaceItemInList(list: cache.centPerTreeTypes, index: sender.tag, item: sender.text!.doubleValue){ success, error in
                if error != nil{
                    let alert = JDropDownAlert()
                    alert.alertWith("Error with database, restart app if further errors")
                }
            }
            calculateTotalInLane(column: sender.tag)
        }
    }
    
    ///Ensures changes to a bundlePerTreeType UITextField is put into the caches bundlePerTreeTypes and saved in the realm
    ///- Parameter sender: BundlePerTreeType UITextField
    @objc fileprivate func bundleAmountInputAction(sender: UITextField){
        if(sender.text!.containsLetters()){
            let alert = UIAlertController(title: "Error: Incorrect Type", message: "Please use numbers only for bundle amount", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
            sender.text = ""
        }
        else{
            realmDatabase.replaceItemInList(list: cache.bundlesPerTreeTypes, index: sender.tag, item: GeneralFunctions.integer(from: sender)){ success, error in
                if error != nil{
                    let alert = JDropDownAlert()
                    alert.alertWith("Error with database, restart app if further errors : " + error!)
                }
            }
            if(cache.bundlesPerTreeTypes[sender.tag] == 0){
                sender.text = ""
            }
        }
    }
    
    ///Ensures changes to a bagUpsPerTreeTypes UITextField is put into the caches bagUpsPerTreeTypes and saved in the realm
    ///- Parameter sender: BagUpsPerTreeTypes UITextField
    @objc fileprivate func bagUpInputAction(sender: UITextField){
        let cvTag = sender.superview!.superview!.superview!.tag
        let tfTag = sender.tag
        let value = GeneralFunctions.integer(from: sender)
        if(value == cache.bagUpsPerTreeTypes[cvTag].input[tfTag]){
            return
        }
        
        if(cache.bundlesPerTreeTypes[tfTag] == 0 && !clearingData){
            let alert = UIAlertController(title: "Error: Bundle Amount Not Set", message: "Please set bundle amount before continuing", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
            sender.text = ""
        }
        else if(cache.bundlesPerTreeTypes[tfTag] == 0 && clearingData){
            //Clearing Data Do Nothing
        }
        else{
            //Check if divisible by bundle amount
            if((value % cache.bundlesPerTreeTypes[tfTag]) != 0){
                //Alert not divisible
                let alert = UIAlertController(title: "Error: Divisibilty", message: "The bundle amount is not divisible by your input, " + String(value) + "/" + String(cache.bundlesPerTreeTypes[tfTag]) + " = " + String(Double(value)/Double(cache.bundlesPerTreeTypes[tfTag])), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

                self.present(alert, animated: true)
                sender.text = ""
            }
            else{
                realmDatabase.replaceItemInList(list: cache.bagUpsPerTreeTypes[cvTag].input, index: tfTag, item: value){ success, error in
                    if error != nil{
                        let alert = JDropDownAlert()
                        alert.alertWith("Error with database, restart app if further errors : " + error!)
                    }
                }
                calculateTotalInLane(column: tfTag)
                if(cache.bagUpsPerTreeTypes[cvTag].input[tfTag] == 0){
                    sender.text = ""
                }
            }
        }
    }
    
    ///Deletes clears all data cooresponding to the tally sheet in the cache
    ///- Parameter sender: Clear UIButton
    @objc fileprivate func clearFieldsButtonAction(sender: UIButton){
        clearingData = true
        let alertController = UIAlertController(title: "Clear Data", message: "Clear all data in tally sheet?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Clear", style: .destructive, handler: {_ in
            realmDatabase.clearCacheTally(cache: self.cache){ success, error in
                if(success){
                    print("Tally Cleared")
                }else{
                    let alert = JDropDownAlert()
                    alert.alertWith(error!)
                }
                self.treeTypesCollectionView.reloadData()
                self.centPerTreeTypeCollectionView.reloadData()
                self.bundlePerTreeTypeCollectionView.reloadData()
                self.bagUpCollectionViews.forEach{$0.reloadData()}
                self.totalCashPerTreeTypesCollectionView.reloadData()
                self.totalTreesPerTreeTypesCollectionView.reloadData()
                self.clearingData = false
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    ///Updates timer used for gps tracking
    @objc func updateTimer() {
        freshCounter += 1
        counter += 1
        realmDatabase.replaceItemInList(list: cache.secondsPlanted, index: cache.secondsPlanted.endIndex-1, item: freshCounter){ success, error in
            if error != nil{
                let alert = JDropDownAlert()
                alert.alertWith("Error with database, restart app if further errors : " + error!)
            }
        }
    }
    
    ///Calculates one coloum of bagUpsPerTreeTypes and updates totals
    fileprivate func calculateTotalInLane(column: Int){
        var totalTreesInBagUps : Int = 0
        for x in 0...19{
            totalTreesInBagUps += cache.bagUpsPerTreeTypes[x].input[column]
        }
        realmDatabase.replaceItemInList(list: cache.totalTreesPerTreeTypes, index: column, item: totalTreesInBagUps){ success, error in
            if error != nil{
                let alert = JDropDownAlert()
                alert.alertWith("Error with database, restart app if further errors : " + error!)
            }
        }
        realmDatabase.replaceItemInList(list: cache.totalCashPerTreeTypes, index: column, item: (Double(totalTreesInBagUps)*cache.centPerTreeTypes[column])){ success, error in
            if error != nil{
                let alert = JDropDownAlert()
                alert.alertWith("Error with database, restart app if further errors : " + error!)
            }
        }
        totalTreesPerTreeTypesCollectionView.reloadData()
        totalCashPerTreeTypesCollectionView.reloadData()
    }
    
    ///Stops tracking location
    fileprivate func stopTrackingLocation(){
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = false
    }
    
}

///Functionality required for using UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension TallySheetViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    ///Asks your data source object for the number of items in the specified section.
    ///- Parameter CollectionView: The collection view object displaying the flow layout.
    ///- Parameter numberOfItemsInSection: Given number of items to be insection
    ///- Returns: Number of items to be insection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    ///Asks the delegate for the size of the specified item’s cell.
    ///- Parameter collectionView: The collection view object displaying the flow layout.
    ///- Parameter collectionViewLayout: The layout object requesting the information.
    ///- Parameter indexPath: The index path of the item.
    ///- Returns: The width and height of the specified item. Both values must be greater than 0.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: widthOfCollectionCell, height: collectionView.frame.height)
    }

    ///Asks your data source object for the cell that corresponds to the specified item in the collection view.
    ///- Parameter CollectionView: The collection view object displaying the flow layout.
    ///- Parameter indexPath: Index path that specifies location of item
    ///- Returns: A configured cell object. You must not return nil from this method.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TallyCell", for: indexPath) as! TallyCell
        
        if(collectionView == self.totalTreesPerTreeTypesCollectionView){
            cell.input.tag = indexPath.row
            cell.input.isUserInteractionEnabled = false
            cell.input.text = (cache.totalTreesPerTreeTypes[indexPath.row] == 0 ? "" : String(cache.totalTreesPerTreeTypes[indexPath.row]))
            return cell
        }
        else if(collectionView == self.totalCashPerTreeTypesCollectionView){
            cell.input.tag = indexPath.row
            cell.input.isUserInteractionEnabled = false
            cell.input.text = (cache.totalCashPerTreeTypes[indexPath.row] == 0 ? "" : cache.totalCashPerTreeTypes[indexPath.row].toCurrency())
            return cell
        }
        else if(collectionView == self.treeTypesCollectionView){
            TallyCell.createAdvancedTallyCell(cell: cell, toolBar: toolBar, tag: indexPath.row, keyboardType: .default)
            cell.input.addTarget(self, action: #selector(treeTypesInputAction), for: .editingDidEnd)
            cell.input.text = cache.treeTypes[indexPath.row]
            return cell
        }
        else if(collectionView == self.centPerTreeTypeCollectionView){
            TallyCell.createAdvancedTallyCell(cell: cell, toolBar: toolBar, tag: indexPath.row, keyboardType: .decimalPad)
            cell.input.addTarget(self, action: #selector(centPerTreeInputAction), for: .editingDidEnd)
            cell.input.text = (cache.centPerTreeTypes[indexPath.row] == 0 ? "" : String(cache.centPerTreeTypes[indexPath.row]))
            return cell
        }
        else if(collectionView == self.bundlePerTreeTypeCollectionView){
            TallyCell.createAdvancedTallyCell(cell: cell, toolBar: toolBar, tag: indexPath.row, keyboardType: .numberPad)
            cell.input.addTarget(self, action: #selector(bundleAmountInputAction), for: .editingDidEnd)
            cell.input.text = (cache.bundlesPerTreeTypes[indexPath.row] == 0 ? "" : String(cache.bundlesPerTreeTypes[indexPath.row]))
            return cell
        }
        else{
            TallyCell.createAdvancedTallyCell(cell: cell, toolBar: toolBar, tag: indexPath.row, keyboardType: .numberPad)
            cell.input.addTarget(self, action: #selector(bagUpInputAction), for: .editingDidEnd)
            cell.input.text = (cache.bagUpsPerTreeTypes[collectionView.tag].input[indexPath.row] == 0 ? "" : String(cache.bagUpsPerTreeTypes[collectionView.tag].input[indexPath.row]))
            return cell
        }
    }
}

///Functionality required for using CLLocationManagerDelegate
extension TallySheetViewController: CLLocationManagerDelegate {
    ///Tells the delegate that new location data is available.
    ///- Parameter manager: v
    ///- Parameter locations: An array of CLLocation objects containing the location data. This array always contains at least one object representing the current location. If updates were deferred or if multiple locations arrived before they could be delivered, the array may contain additional entries. The objects in the array are organized in the order in which they occurred. Therefore, the most recent location update is at the end of the array.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if cache.isPlanting{
            if !locations.isEmpty{
                var prevCoordinate = Coordinate(longitude: -1, latitude: -1)
                var startCoordinate = 0
                if cache.coordinatesCovered.last!.input.isEmpty{
                    prevCoordinate = Coordinate(longitude: locations[0].coordinate.longitude, latitude: locations[0].coordinate.latitude)
                    realmDatabase.addToList(list: cache.coordinatesCovered.last!.input, item: prevCoordinate){ success, error in
                        if error != nil{
                            let alert = JDropDownAlert()
                            alert.alertWith("Error with database, restart app if further errors : " + error!)
                        }
                    }
                    startCoordinate = 1
                }
                else{
                    prevCoordinate = cache.coordinatesCovered.last!.input.last!
                }
                for i in startCoordinate..<locations.count{
                    //Check if the coordinate is 5 meters from the last one
                    if GMSGeometryDistance(CLLocationCoordinate2D(latitude: prevCoordinate.latitude, longitude: prevCoordinate.longitude), CLLocationCoordinate2D(latitude: locations[i].coordinate.latitude, longitude: locations[i].coordinate.longitude)) >= 5.0{
                        let newCoordinate = Coordinate(longitude: locations[i].coordinate.longitude, latitude: locations[i].coordinate.latitude)
                        realmDatabase.addToList(list: cache.coordinatesCovered.last!.input, item: newCoordinate){ success, error in
                            if error != nil{
                                let alert = JDropDownAlert()
                                alert.alertWith("Error with database, restart app if further errors : " + error!)
                            }
                        }
                    }
                }
            }
        }
    }
    
    ///Tells the delegate when the app creates the location manager and when the authorization status changes.
    ///- Parameter manager: The location manager object reporting the event.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        // Check accuracy authorization
        let accuracy = manager.accuracyAuthorization
        switch accuracy {
        case .fullAccuracy:
            print("Location accuracy is precise.")
        case .reducedAccuracy:
            print("Location accuracy is not precise.")
        @unknown default:
            fatalError()
        }
        // Handle authorization status
        switch manager.authorizationStatus {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
          // Display the map using the default location.
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways:
            print("Location status is OK.")
        case .authorizedWhenInUse:
            print("Location status is Only When In Use.")
        @unknown default:
            fatalError()
        }
        
        if (locationManager.authorizationStatus == CLAuthorizationStatus.authorizedAlways) && gpsButtonClicked {
            goToGPSModal()
        }
    }

    ///Tells the delegate that the location manager was unable to retrieve a location value.
    ///- Parameter manager: The location manager object that was unable to retrieve the location.
    ///- Parameter error: The error object containing the reason the location or heading could not be retrieved.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        stopTrackingLocation()
        print("Error: \(error)")
    }
}

///Functionality required for using GPSTreeTrackingModalDelegate
extension TallySheetViewController: GPSTreeTrackingModalDelegate{
    ///Flips the boolean of Cache. isPlanting
    func flipBooleanIsPlanting() {
        realmDatabase.updateCacheIsPlanting(cache: cache, bool: !cache.isPlanting){ success, error in
            if error != nil{
                let alert = JDropDownAlert()
                alert.alertWith("Error with database, restart app if further errors : " + error!)
            }
        }
    }
    
    ///Checks if user is currently planting in the cache
    ///- Returns: Bool based on if user is planting in cache
    func isPlanting() -> Bool{
        return cache.isPlanting
    }
    
    ///Modal is about to be closed, run this operation
    func closedModal() {
        if !cache.isPlanting{
            print("Stopped Tracking")
            stopTrackingLocation()
        }
    }
    
    ///Saves the current tree per plot in the cache and database
    ///- Parameter treePerPlot: Trees per plot number
    func saveTreesPerPlot(treesPerPlot: Int) {
        print("Saving Trees per Plot: \(treesPerPlot)")
        realmDatabase.updateCacheTreePerPlot(cache: cache, treesPerPlot: treesPerPlot){ success, error in
            if error != nil{
                let alert = JDropDownAlert()
                alert.alertWith("Error with database, restart app if further errors : " + error!)
            }
        }
    }
    
    ///Starts a timer
    func startTimer() {
        if(isPlaying) {
            return
        }
            
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        isPlaying = true
    }
        
    ///Stops a timer
    func stopTimer() {
        timer.invalidate()
        isPlaying = false
        freshCounter = 0
    }
    
    ///Get timer count
    ///- Returns: The timer count in string form
    func getTimerCount() -> String{
        let (h, m, s) = GeneralFunctions.secondsToHoursMinutesSeconds(seconds: counter)
        let timerString =  (h < 10 ? "0" : "") + String(h) + ":" + (m < 10 ? "0" : "") + String(m) + ":" + (s < 10 ? "0" : "") + String(s)
        return timerString
    }
    
    ///Calculates the counter
    func reCalculateCounter(){
        timer.invalidate()
        freshCounter = 0
        counter = 0
        cache.secondsPlanted.forEach{counter += $0}
    }
}

///Functionality required for using QuickPrepModalViewDelegate
extension TallySheetViewController: QuickPrepModalViewDelegate{
    ///Uploads info arrays into tally sheet
    ///- Parameter treeTypes: TreeTypes array
    ///- Parameter centPerTreeTypes: CentPerTreeTypes array
    ///- Parameter bundlePerTreeTypes: BundlePerTreeTypes
    func fillInfo(treeTypes: [String], centPerTreeTypes: [Double], bundlePerTreeTypes: [Int]) {
        realmDatabase.updateList(list: cache.treeTypes, copyArray: treeTypes){ success, error in
            if error != nil{
                let alert = JDropDownAlert()
                alert.alertWith("Error with database, restart app if further errors : " + error!)
            }
        }
        realmDatabase.updateList(list: cache.centPerTreeTypes, copyArray: centPerTreeTypes){ success, error in
            if error != nil{
                let alert = JDropDownAlert()
                alert.alertWith("Error with database, restart app if further errors : " + error!)
            }
        }
        realmDatabase.updateList(list: cache.bundlesPerTreeTypes, copyArray: bundlePerTreeTypes){ success, error in
            if error != nil{
                let alert = JDropDownAlert()
                alert.alertWith("Error with database, restart app if further errors : " + error!)
            }
        }
        treeTypesCollectionView.reloadData()
        centPerTreeTypeCollectionView.reloadData()
        bundlePerTreeTypeCollectionView.reloadData()
    }
}

extension TallySheetViewController: UITabBarControllerDelegate{
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if viewController.tabBarItem.tag == 0 {
            checkIfGPSStillOn()
        }
    }
}



