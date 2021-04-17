//
//  GPSTreeTrackingVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift
import UnderLineTextField
import CoreLocation
import GoogleMaps
import JDropDownAlert

///GPSTreeTrackingModalViewController.swift - Gps tracking, along with timer and path creation features
class GPSTreeTrackingModalViewController: GPSTreeTrackingModalView, GMSMapViewDelegate {
    weak var delegate : GPSTreeTrackingModalDelegate?

    
    fileprivate let cacheCoordinates: List<CoordinateInput>
    fileprivate var locationManager: CLLocationManager
    fileprivate var treesPerPlot: Int
    fileprivate let secondsPlanted: List<Int>
    
    fileprivate var locationNotificationToken: NotificationToken?

    fileprivate let trackingPath = GMSMutablePath()
    fileprivate var pathHistory : [GMSMutablePath] = []
    
    fileprivate var timer = Timer()
    
    fileprivate var totalDistance : Double = 0.0
    fileprivate var prevTrackingCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    ///Contructor that initalizes required fields
    ///- Parameter title:Title of current view controller in navigation controller
    ///- Parameter cacheCoordinates: Cache coordinates
    ///- Parameter treesPerPlot: Ttrees per plot used for calculating current amount of trees that should be in the ground from distance travelled
    ///- Parameter locationManager: Location manager
    ///- Parameter secondsPlanted: List of total seconds planted (1 index = 1 path)
    required init(title: String, cacheCoordinates: List<CoordinateInput>, treesPerPlot: Int, locationManager: CLLocationManager, secondsPlanted: List<Int>) {
        self.cacheCoordinates = cacheCoordinates
        self.locationManager = locationManager
        self.treesPerPlot = treesPerPlot
        self.secondsPlanted = secondsPlanted
        
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Called when the View Controller is about to be deinitalized
    deinit {
        locationNotificationToken?.invalidate()
        timer.invalidate()
    }
    
    ///Functionality for when view will appear
    ///- Parameter animated: Boolean to decide if view will apear with anination or not
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let myLocation = self.locationManager.location {
            let camera = GMSCameraPosition.camera(withLatitude: myLocation.coordinate.latitude, longitude: myLocation.coordinate.longitude, zoom: 18.0)
            self.mapView.camera = camera
        }
        firstTimerKey = "GPSTreeTrackingModalViewController"
        if(isFirstTimer()){
            let alertController = UIAlertController(title: "GPS Section", message: "Welcome to the GPS section! \nThis is where you can...\n1. Record where you planted \n2. Record the amount of time you planted \n 3. View total distance travelled \n 4. Based off your plots see how many trees you should have put in the ground. (This is a estimate based off calculations) \n\n Tracking location will occur until you leave the Tally Sheet View (Where you pressed the 'GPS' button)", preferredStyle: .alert)
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
        if let delegate = delegate{
            delegate.closedModal()
        }
    }
    
    ///Configuire all views in programic view controller
    internal override func configureViews() {
        super.configureViews()
        setUpLocationManager()
        createAllPaths()
        setDistanceTextField()
        calculateTrees()
        if let delegate = delegate{
            if delegate.isPlanting(){
                setEngageButtonStop()
                setNotificationForTrackingList()
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            }
            timerView.text = delegate.getTimerCount()
        }
        treesPerPlotTextField.text = String(treesPerPlot)
        keyboardMoveWhenTextFieldTouched = view.frame.height*0.33
    }
    
    ///Set all actions in progrmaic view controller
    internal override func setActions() {
        engageTrackingButton.addTarget(self, action: #selector(engageTrackingButtonAction), for: .touchUpInside)
        treesPerPlotTextField.addTarget(self, action: #selector(treesPerPlotInputAction), for: .editingDidEnd)
        undoImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(undoTap)))
    }
    
    ///Sets up location manager to start its features
    fileprivate func setUpLocationManager(){
        print("Start Tracking")
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        mapView.delegate = self
    }
    
    ///Updates timer to whatever the TallySheetViewController is set
    @objc func updateTimer() {
        if let delegate = delegate{
            timerView.text = delegate.getTimerCount()
        }
    }
    
    ///Completes all operations when the user wants to start/stop planting and tracking themselfes
    @objc fileprivate func engageTrackingButtonAction(){
        if let delegate = delegate{
            if delegate.isPlanting(){
                timer.invalidate()
                delegate.stopTimer()
                setEngageButtonStart()
                addTrackingPathToMap()
                trackingPath.removeAllCoordinates()
                addPolyline(path: trackingPath)
                prevTrackingCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
            }
            else{
                realmDatabase.addToList(list: secondsPlanted, item: 0){ success, error in
                    if error != nil{
                        let alert = JDropDownAlert()
                        alert.alertWith("Error with database, restart app if further errors")
                    }
                }
                delegate.startTimer()
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
                trackingPath.removeAllCoordinates()
                setEngageButtonStop()
                realmDatabase.addToList(list: cacheCoordinates, item: CoordinateInput()){ success, error in
                    if error != nil{
                        let alert = JDropDownAlert()
                        alert.alertWith("Error with database, restart app if further errors")
                    }
                }
                setNotificationForTrackingList()
            }
            delegate.flipBooleanIsPlanting()
        }
    }
    
    ///Saves the updated trees per plot value
    @objc fileprivate func treesPerPlotInputAction(){
        if(treesPerPlotTextField.text != "0" && treesPerPlotTextField.text != ""){
            if let delegate = delegate{
                treesPerPlot = Int(treesPerPlotTextField.text!)!
                delegate.saveTreesPerPlot(treesPerPlot: treesPerPlot)
            }
        }
        calculateTrees()
    }
    
    ///Removes last path made
    @objc fileprivate func undoTap(gesture: UIGestureRecognizer) {
        if let coordinatesCovered = cacheCoordinates.last{
            if let delegate = delegate{
                timer.invalidate()
                realmDatabase.clearList(list: coordinatesCovered.input){ success, error in
                    if error != nil{
                        let alert = JDropDownAlert()
                        alert.alertWith("Error with database, restart app if further errors : " + error!)
                    }
                }
                realmDatabase.removeLastInList(list: cacheCoordinates){ success, error in
                    if error != nil{
                        let alert = JDropDownAlert()
                        alert.alertWith("Error with database, restart app if further errors : " + error!)
                    }
                }
                if delegate.isPlanting(){
                    engageTrackingButtonAction()
                }
                if !pathHistory.isEmpty{
                    pathHistory.removeLast()
                }
                if !secondsPlanted.isEmpty{
                    realmDatabase.removeLastInList(list: secondsPlanted){ success, error in
                        if error != nil{
                            let alert = JDropDownAlert()
                            alert.alertWith("Error with database, restart app if further errors : " + error!)
                        }
                    }
                    delegate.reCalculateCounter()
                }
                updateTimer()
                reloadAllPaths()
            }
        }
    }
    
    ///Adds the current tracking path to the map
    fileprivate func addTrackingPathToMap(){
        let path = GMSMutablePath(path: trackingPath)
        addPolyline(path: path)
        pathHistory.append(path)
    }

    ///Adds the coordinates to the tracking path
    ///- Parameter coordianteIndexs: list of indexs of new coordinates that is inside the current Coordinates list corresponding to current path
    fileprivate func addCoordinatesToMap(coordianteIndexs: [Int]){
        for index in coordianteIndexs{
            let currentCoordinate = CLLocationCoordinate2D(latitude: cacheCoordinates.last!.input[index].latitude, longitude: cacheCoordinates.last!.input[index].longitude)
            if(prevTrackingCoordinate.longitude != 0.0){
                totalDistance += GMSGeometryDistance(prevTrackingCoordinate, currentCoordinate)
            }
            trackingPath.add(currentCoordinate)
            prevTrackingCoordinate = currentCoordinate
        }
        setDistanceTextField()
        calculateTrees()
        addPolyline(path: trackingPath)
    }
    
    ///Customizes the engage button for start mode
    fileprivate func setEngageButtonStart(){
        engageTrackingButton.layer.borderColor = UIColor.systemGreen.cgColor
        engageTrackingButton.setTitle("Start Planting", for: .normal)
    }
    
    ///Customizes the engage button for stop mode
    fileprivate func setEngageButtonStop(){
        engageTrackingButton.layer.borderColor = UIColor.systemRed.cgColor
        engageTrackingButton.setTitle("Stop Planting", for: .normal)
    }
    
    ///Creates all the paths that are within this cache, and set up the current tracking path
    fileprivate func createAllPaths(){
        var prevCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        if !cacheCoordinates.isEmpty{
            if let delegate = delegate{
                let trackingLineDeduction = (delegate.isPlanting() ? 1 : 0)
                for i in 0..<cacheCoordinates.count - trackingLineDeduction{
                    let path = GMSMutablePath()
                    for coordinate in cacheCoordinates[i].input{
                        let currentCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        if(prevCoordinate.longitude != 0.0){
                            totalDistance += GMSGeometryDistance(prevCoordinate, currentCoordinate)
                        }
                        path.add(currentCoordinate)
                        prevCoordinate = currentCoordinate
                    }
                    addPolyline(path: path)
                    pathHistory.append(path)
                }
                if delegate.isPlanting(){
                    if let trackingPathCoordinates = cacheCoordinates.last{
                        for coordinate in trackingPathCoordinates.input{
                            let currentCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                            if(prevTrackingCoordinate.longitude != 0.0){
                                totalDistance += GMSGeometryDistance(prevTrackingCoordinate, currentCoordinate)
                            }
                            trackingPath.add(currentCoordinate)
                            prevTrackingCoordinate = currentCoordinate
                        }
                        addPolyline(path: trackingPath)
                    }
                }
            }
        }
    }
    
    ///Reloads all the paths
    fileprivate func reloadAllPaths(){
        totalDistance = 0
        mapView.clear()
        for path in pathHistory{
            var prevCoordinate = path.coordinate(at: 0)
            if path.count() > 0{
                for i in 1..<path.count(){
                    totalDistance += GMSGeometryDistance(prevCoordinate, path.coordinate(at: i))
                    prevCoordinate = path.coordinate(at: i)
                }
            }
            addPolyline(path: path)
        }
        setDistanceTextField()
        calculateTrees()
    }
    
    ///Update distanceTravelledTextField to have the updated total distance traveled
    fileprivate func setDistanceTextField(){
        distanceTravelledTextField.text = String(Double(totalDistance/1000.0).round(to: 2)) + "Km"
    }
    
    ///Update treesPlantedTheoreticallyTextField to have the updated amount of trees that should be in the ground based on total distance
    fileprivate func calculateTrees(){
        if treesPerPlot > 0{
            //Caclulation: total distance/target inter-tree distance
            treesPlantedTheoreticallyTextField.text = String(Int(totalDistance/Double(11547.0/Double(treesPerPlot*200)).squareRoot())) + " Trees"
        }
    }
    
    ///Ensure the notification is attached to the current path
    fileprivate func setNotificationForTrackingList(){
        self.locationNotificationToken = cacheCoordinates.last?.input.observe { [weak self] (changes) in
            switch changes {
            case .initial(_):
                print("location notification on")
            case .update(_, _, let insertions, _):
                self!.addCoordinatesToMap(coordianteIndexs: insertions)
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
    
    ///Adds a GMSMutablePath to the map
    ///- Parameter path: GMSMutablePath to be added to the map
    fileprivate func addPolyline(path: GMSMutablePath){
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = .systemRed
        polyline.strokeWidth = 5.0
        polyline.map = mapView
    }
    
    ///Centers gps view to current location
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        self.mapView.animate(toLocation: self.locationManager.location!.coordinate)
        return true
    }
    
}

///Protocol used for a view controller that uses GPSTreeTrackingModalDelegate
protocol GPSTreeTrackingModalDelegate:NSObjectProtocol {
    ///Tells delegate to flip the boolean of Cache.isPlanting
    func flipBooleanIsPlanting()
    ///Tells delegate to checks if user is currently planting in the cache
    ///- Returns: Bool based on if user is planting in cache
    func isPlanting() -> Bool
    ///Tells delegate that the modal is about to be closed, run this operation
    func closedModal()
    ///Tells delegate to saves the current tree per plot in the cache and database
    ///- Parameter treePerPlot: trees per plot number
    func saveTreesPerPlot(treesPerPlot: Int)
    ///Tells delegate starts a timer
    func startTimer()
    ///Tells delegate stops a timer
    func stopTimer()
    ///Tells delegate to get timer count
    ///- Returns: The timer count in string form
    func getTimerCount() -> String
    ///Tells delegate to calculates the counter
    func reCalculateCounter()
}





