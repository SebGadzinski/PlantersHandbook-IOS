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

class TallySheetViewController: TallySheetView {

    fileprivate let cache: Cache
    fileprivate var clearingData = false
    fileprivate var gpsButtonClicked = false
    fileprivate var locationManagerNotificationToken: NotificationToken?
    
    var locationManager: CLLocationManager!
        
    required init(cache: Cache) {
        self.cache = cache
       
        super.init(nibName: nil, bundle: nil)
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
        locationManager.delegate = self
        
        realmDatabase.updateCacheIsPlanting(cache: cache, bool: false)
                
        self.title = "Cache: " + cache.title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(cache.isPlanting){
            realmDatabase.updateCacheIsPlanting(cache: cache, bool: false)
            stopTrackingLocation()
        }
    }

    internal override func configureViews() {
        super.configureViews()
        setUpTableDelegates()
        findHandbookDate()
    }
    
    internal override func setActions() {
        clearButton.addTarget(self, action: #selector(clearFieldsButton), for: .touchUpInside)
        gpsButton.addTarget(self, action: #selector(gpsButtonAction), for: .touchUpInside)
        plotsButton.addTarget(self, action: #selector(plotsButtonAction), for: .touchUpInside)
    }

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
    
    fileprivate func findHandbookDate(){
        if let subBlock = realmDatabase.getSubBlockById(subBlockId: cache.subBlockId){
            dateLabel.text = GeneralFunctions.getDate(from: subBlock.date)
        }
    }
    
    @objc fileprivate func gpsButtonAction(){
        gpsButtonClicked = true
        locationManager.requestAlwaysAuthorization()
        if locationManager.authorizationStatus == CLAuthorizationStatus.authorizedAlways{
            gpsButtonClicked = false
            goToGPSModal()
        }
        else{
            let alertController = UIAlertController(title: "Turn On Location", message: "Please go to Settings and turn on the location permissions", preferredStyle: .alert)

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
    
    fileprivate func goToGPSModal(){
        let gpsModal = GPSTreeTrackingModalViewController(title: self.title! + " GPS Tree Tracking", cacheCoordinates: cache.coordinatesCovered, treesPerPlot: cache.treePerPlot, locationManager: locationManager)
        gpsModal.delegate = self
        gpsModal.modalPresentationStyle = .popover
        present(gpsModal, animated: true)
    }
    
    @objc func plotsButtonAction(){
        let plotsModal = PlotsModalViewController(title: self.title! + " Plots", plots: cache.plots)
        plotsModal.modalPresentationStyle = .popover
        present(plotsModal, animated: true)
    }
    
    @objc fileprivate func treeTypesInputAction(sender: UITextField){
        realmDatabase.updateList(list: cache.treeTypes, index: sender.tag, item: sender.text!)
    }
    
    @objc fileprivate func centPerTreeInputAction(sender: UITextField){
        if(GeneralFunctions.containsLetters(input: sender.text!)){
            let alert = UIAlertController(title: "Error: Incorrect Type", message: "Please use numbers only for cent per tree value", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
            sender.text = ""
        }
        else{
            realmDatabase.updateList(list: cache.centPerTreeTypes, index: sender.tag, item: sender.text!.doubleValue)
            calculateTotalInLane(column: sender.tag)
        }
    }
    
    @objc fileprivate func bundleAmountInputAction(sender: UITextField){
        if(GeneralFunctions.containsLetters(input: sender.text!)){
            let alert = UIAlertController(title: "Error: Incorrect Type", message: "Please use numbers only for bundle amount", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
            sender.text = ""
        }
        else{
            realmDatabase.updateList(list: cache.bundlesPerTreeTypes, index: sender.tag, item: GeneralFunctions.integer(from: sender))
            if(cache.bundlesPerTreeTypes[sender.tag] == 0){
                sender.text = ""
            }
        }
    }
    
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
                realmDatabase.updateList(list: cache.bagUpsPerTreeTypes[cvTag].input, index: tfTag, item: value)
                calculateTotalInLane(column: tfTag)
                if(cache.bagUpsPerTreeTypes[cvTag].input[tfTag] == 0){
                    sender.text = ""
                }
            }
        }
    }
    
    @objc fileprivate func clearFieldsButton(sender: UIButton){
        clearingData = true
        realmDatabase.clearCacheTally(cache: cache){result in
            if(result){
                print("Tally Cleared")
            }
            treeTypesCollectionView.reloadData()
            centPerTreeTypeCollectionView.reloadData()
            bundlePerTreeTypeCollectionView.reloadData()
            bagUpCollectionViews.forEach{$0.reloadData()}
            totalCashPerTreeTypesCollectionView.reloadData()
            totalTreesPerTreeTypesCollectionView.reloadData()
            clearingData = false
        }
    }
    
    fileprivate func calculateTotalInLane(column: Int){
        var totalTreesInBagUps : Int = 0
        for x in 0...19{
            totalTreesInBagUps += cache.bagUpsPerTreeTypes[x].input[column]
        }
        realmDatabase.updateList(list: cache.totalTreesPerTreeTypes, index: column, item: totalTreesInBagUps)
        realmDatabase.updateList(list: cache.totalCashPerTreeTypes, index: column, item: (Double(totalTreesInBagUps)*cache.centPerTreeTypes[column]))
        totalTreesPerTreeTypesCollectionView.reloadData()
        totalCashPerTreeTypesCollectionView.reloadData()
    }
    
    fileprivate func stopTrackingLocation(){
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = false
    }
}


extension TallySheetViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: widthOfCollectionCell, height: collectionView.frame.height)
    }

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
            GeneralFunctions.createAdvancedTallyCell(cell: cell, toolBar: toolBar, tag: indexPath.row, keyboardType: .default)
            cell.input.addTarget(self, action: #selector(treeTypesInputAction), for: .editingDidEnd)
            cell.input.text = cache.treeTypes[indexPath.row]
            return cell
        }
        else if(collectionView == self.centPerTreeTypeCollectionView){
            GeneralFunctions.createAdvancedTallyCell(cell: cell, toolBar: toolBar, tag: indexPath.row, keyboardType: .decimalPad)
            cell.input.addTarget(self, action: #selector(centPerTreeInputAction), for: .editingDidEnd)
            cell.input.text = (cache.centPerTreeTypes[indexPath.row] == 0 ? "" : String(cache.centPerTreeTypes[indexPath.row]))
            return cell
        }
        else if(collectionView == self.bundlePerTreeTypeCollectionView){
            GeneralFunctions.createAdvancedTallyCell(cell: cell, toolBar: toolBar, tag: indexPath.row, keyboardType: .numberPad)
            cell.input.addTarget(self, action: #selector(bundleAmountInputAction), for: .editingDidEnd)
            cell.input.text = (cache.bundlesPerTreeTypes[indexPath.row] == 0 ? "" : String(cache.bundlesPerTreeTypes[indexPath.row]))
            return cell
        }
        else{
            GeneralFunctions.createAdvancedTallyCell(cell: cell, toolBar: toolBar, tag: indexPath.row, keyboardType: .numberPad)
            cell.input.addTarget(self, action: #selector(bagUpInputAction), for: .editingDidEnd)
            cell.input.text = (cache.bagUpsPerTreeTypes[collectionView.tag].input[indexPath.row] == 0 ? "" : String(cache.bagUpsPerTreeTypes[collectionView.tag].input[indexPath.row]))
            return cell
        }
    }
}

extension TallySheetViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if cache.isPlanting{
            if !locations.isEmpty{
                var prevCoordinate = Coordinate(longitude: -1, latitude: -1)
                var start = 0
                if cache.coordinatesCovered.last!.input.isEmpty{
                    prevCoordinate = Coordinate(longitude: locations[0].coordinate.longitude, latitude: locations[0].coordinate.latitude)
                    realmDatabase.addToList(list: cache.coordinatesCovered.last!.input, item: prevCoordinate)
                    start = 1
                }
                else{
                    prevCoordinate = cache.coordinatesCovered.last!.input.last!
                }
                for i in start..<locations.count{
                    //Check if the coordinate is 5 meters from the last one
                    if GMSGeometryDistance(CLLocationCoordinate2D(latitude: prevCoordinate.latitude, longitude: prevCoordinate.longitude), CLLocationCoordinate2D(latitude: locations[i].coordinate.latitude, longitude: locations[i].coordinate.longitude)) >= 5.0{
                        let newCoordinate = Coordinate(longitude: locations[i].coordinate.longitude, latitude: locations[i].coordinate.latitude)
                        realmDatabase.addToList(list: cache.coordinatesCovered.last!.input, item: newCoordinate)
                    }
                }
            }
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
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
    switch status {
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
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if (locationManager.authorizationStatus == CLAuthorizationStatus.authorizedAlways) && gpsButtonClicked {
            goToGPSModal()
        }
    }

    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        stopTrackingLocation()
        print("Error: \(error)")
    }
}

extension TallySheetViewController: GPSTreeTrackingModalDelegate{
    func flipBooleanIsPlanting() {
        realmDatabase.updateCacheIsPlanting(cache: cache, bool: !cache.isPlanting)
    }
    
    func isPlanting() -> Bool{
        return cache.isPlanting
    }
    
    func closedModal() {
        //If person not planting ensure no tracking is being done.
        if !cache.isPlanting{
            print("Stopped Tracking")
            stopTrackingLocation()
        }
    }
    
    func saveTreesPerPlot(treePerPlot: Int) {
        print("Saving Trees per Plot: \(treePerPlot)")
        realmDatabase.updateCacheTreePerPlot(cache: cache, treesPerPlot: treePerPlot)
    }
}
