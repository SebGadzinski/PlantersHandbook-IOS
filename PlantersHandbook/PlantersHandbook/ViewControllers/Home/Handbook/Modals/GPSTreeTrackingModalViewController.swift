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
    
    required init(title: String, cacheCoordinates: List<CoordinateInput>, treesPerPlot: Int, locationManager: CLLocationManager, secondsPlanted: List<Int>) {
        self.cacheCoordinates = cacheCoordinates
        self.locationManager = locationManager
        self.treesPerPlot = treesPerPlot
        self.secondsPlanted = secondsPlanted
        
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        locationNotificationToken?.invalidate()
        timer.invalidate()
    }
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let delegate = delegate{
            delegate.closedModal()
        }
    }
    
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
        keyboardMoveUpWhenTextFieldTouched = view.frame.height*0.33
    }
    
    internal override func setActions() {
        engageTrackingButton.addTarget(self, action: #selector(engageTrackingButtonAction), for: .touchUpInside)
        treesPerPlotTextField.addTarget(self, action: #selector(treesPerPlotInputAction), for: .editingDidEnd)
        undoImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(undoTap)))
    }
    
    fileprivate func setUpLocationManager(){
        print("Start Tracking")
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        mapView.delegate = self
    }
    
    @objc func updateTimer() {
        if let delegate = delegate{
            timerView.text = delegate.getTimerCount()
        }
    }
    
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
    
    @objc fileprivate func treesPerPlotInputAction(){
        if(treesPerPlotTextField.text != "0" && treesPerPlotTextField.text != ""){
            if let delegate = delegate{
                treesPerPlot = Int(treesPerPlotTextField.text!)!
                delegate.saveTreesPerPlot(treePerPlot: treesPerPlot)
            }
        }
        calculateTrees()
    }
    
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
    
    fileprivate func addTrackingPathToMap(){
        let path = GMSMutablePath(path: trackingPath)
        addPolyline(path: path)
        pathHistory.append(path)
    }

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
    
    fileprivate func setEngageButtonStart(){
        engageTrackingButton.layer.borderColor = UIColor.systemGreen.cgColor
        engageTrackingButton.setTitle("Start Planting", for: .normal)
    }
    
    fileprivate func setEngageButtonStop(){
        engageTrackingButton.layer.borderColor = UIColor.systemRed.cgColor
        engageTrackingButton.setTitle("Stop Planting", for: .normal)
    }
    
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
    
    fileprivate func setDistanceTextField(){
        distanceTravelledTextField.text = String(Double(totalDistance/1000.0).round(to: 2)) + "Km"
    }
    
    fileprivate func calculateTrees(){
        if treesPerPlot > 0{
            //Caclulation: total distanc/target inter-tree distance
            treesPlantedTheoreticallyTextField.text = String(Int(totalDistance/Double(11547.0/Double(treesPerPlot*200)).squareRoot())) + " Trees"
        }
    }
    
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
    
    fileprivate func addPolyline(path: GMSMutablePath){
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = .systemRed
        polyline.strokeWidth = 5.0
        polyline.map = mapView
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        self.mapView.animate(toLocation: self.locationManager.location!.coordinate)
        return true
    }
    
}

protocol GPSTreeTrackingModalDelegate:NSObjectProtocol {
    func flipBooleanIsPlanting()
    func isPlanting() -> Bool
    func closedModal()
    func saveTreesPerPlot(treePerPlot: Int)
    func startTimer()
    func stopTimer()
    func getTimerCount() -> String
    func reCalculateCounter()
}





