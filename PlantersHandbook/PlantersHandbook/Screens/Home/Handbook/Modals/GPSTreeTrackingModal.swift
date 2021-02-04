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

class GPSTreeTrackingModal: ProgramicVC, GMSMapViewDelegate {
    weak var delegate : GPSTreeTrackingModal_Delegate?
    fileprivate var googleMapsLayout : UIView!
    fileprivate var actionLayout : UIView!
    
    fileprivate let cacheCoordinates: List<CoordinateInput>
    fileprivate var locationManager: CLLocationManager
    fileprivate var treesPerPlot: Int
    
    var locationNotificationToken: NotificationToken?
    
    fileprivate let engageTrackingButton = PH_Button(title: "Start Planting", fontSize: FontSize.large)
    fileprivate let distanceTravelledTextField = SUI_Label(title: "0 m", fontSize: FontSize.extraLarge)
    fileprivate let treesPlantedTheoreticallyTextField = SUI_Label(title: "0 trees", fontSize: FontSize.extraLarge)
    fileprivate let treesPerPlotTextField = SUI_TextField_Form(placeholder: "Trees Per Plot", textType: .none)
    fileprivate let undoImage = UIImageView(image: UIImage(named: "undo.png"))
    
    fileprivate var mapView = GMSMapView()
    fileprivate let trackingPath = GMSMutablePath()
    fileprivate var pathHistory : [GMSMutablePath] = []
    
    fileprivate var totalDistance : Double = 0.0
    fileprivate var prevTrackingCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    required init(title: String, cacheCoordinates: List<CoordinateInput>, treesPerPlot: Int, locationManager: CLLocationManager) {
        self.cacheCoordinates = cacheCoordinates
        self.locationManager = locationManager
        self.treesPerPlot = treesPerPlot
                        
        super.init(nibName: nil, bundle: nil)
        
        self.title = title
    }
    
    deinit {
        locationNotificationToken?.invalidate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let myLocation = self.locationManager.location {
            let camera = GMSCameraPosition.camera(withLatitude: myLocation.coordinate.latitude, longitude: myLocation.coordinate.longitude, zoom: 18.0)
            self.mapView.camera = camera
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let delegate = delegate{
            delegate.closedModal()
        }
    }
    
    override func generateLayout() {
        googleMapsLayout = SUI_View(backgoundColor: .systemBackground)
        actionLayout = SUI_View(backgoundColor: .systemBackground)
    }
    
    override func configureViews() {
        setUpOverlay()
        setUpGoogleMapsLayout()
        setUpActionLayout()
        createAllPaths()
        setDistanceTextField()
        calculateTrees()
        keyboardMoveUpWhenTextFieldTouched = view.frame.height*0.33
    }
    
    override func setActions() {
        engageTrackingButton.addTarget(self, action: #selector(engageTrackingButtonAction), for: .touchUpInside)
        treesPerPlotTextField.addTarget(self, action: #selector(treesPerPlotInputAction), for: .editingDidEnd)
        undoImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(undoTap)))
    }
    
    func setUpOverlay(){
        let frame = bgView.safeAreaFrame
        
        let blackBar = UIView()
        blackBar.backgroundColor = .secondaryLabel
        
        [googleMapsLayout, blackBar, actionLayout].forEach{bgView.addSubview($0)}

        googleMapsLayout.anchor(top: bgView.topAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor,size: .init(width: 0, height: frame.height*0.70))
        blackBar.anchor(top: googleMapsLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: 3))
        actionLayout.anchor(top: blackBar.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.20))
    }
    
    func setUpGoogleMapsLayout(){
        print("Start Tracking")
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
            
        mapView.delegate = self
        mapView.mapType = .satellite
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        
        //Bar for people to grab and close the modal
        let topBar = SUI_View(backgoundColor: .clear)
        
        [mapView, topBar].forEach{googleMapsLayout.addSubview($0)}
    
        topBar.anchor(top: googleMapsLayout.topAnchor, leading: googleMapsLayout.leadingAnchor, bottom: nil, trailing: googleMapsLayout.trailingAnchor, size: .init(width: 0, height: googleMapsLayout.safeAreaFrame.height*0.2))
        
        mapView.anchor(top: googleMapsLayout.topAnchor, leading: googleMapsLayout.leadingAnchor, bottom: googleMapsLayout.bottomAnchor, trailing: googleMapsLayout.trailingAnchor)
        
        topBar.addSubview(undoImage)
        
        undoImage.anchor(top: topBar.topAnchor, leading: nil, bottom: nil, trailing: topBar.trailingAnchor,  padding: .init(top: 5, left: 0, bottom: 0, right: 5) ,size: .init(width: mapView.safeAreaFrame.width*0.13, height: mapView.safeAreaFrame.width*0.13))
        undoImage.isUserInteractionEnabled = true
    }
    
    func setUpActionLayout(){
        [engageTrackingButton, treesPerPlotTextField, distanceTravelledTextField, treesPlantedTheoreticallyTextField].forEach{actionLayout.addSubview($0)}

        engageTrackingButton.anchor(top: actionLayout.topAnchor, leading: actionLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 10, left: 10, bottom: 0, right: 10), size: .init(width: actionLayout.safeAreaFrame.width/2, height: actionLayout.safeAreaFrame.height*0.45))
        
        if let delegate = delegate{
            if delegate.isPlanting(){
                setEngageButtonStop()
                setNotificationForTrackingList()
            }
        }
        
        treesPerPlotTextField.anchor(top: engageTrackingButton.bottomAnchor, leading: engageTrackingButton.leadingAnchor, bottom: nil, trailing: engageTrackingButton.trailingAnchor, padding: .init(top: 10, left: 30, bottom: 0, right: 30))
        treesPerPlotTextField.textAlignment = .center
        treesPerPlotTextField.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.meduim))
        treesPerPlotTextField.text = String(treesPerPlot)
        treesPerPlotTextField.keyboardType = .numberPad

        distanceTravelledTextField.anchor(top: nil, leading: engageTrackingButton.trailingAnchor, bottom: nil, trailing: actionLayout.trailingAnchor, size: .init(width: 0, height: actionLayout.safeAreaFrame.height*0.45))
        distanceTravelledTextField.anchorCenterY(to: engageTrackingButton)

        treesPlantedTheoreticallyTextField.anchor(top: nil, leading: treesPerPlotTextField.trailingAnchor, bottom: nil, trailing: actionLayout.trailingAnchor, size: .init(width: 0, height: actionLayout.safeAreaFrame.height*0.45))
        treesPlantedTheoreticallyTextField.anchorCenterY(to: treesPerPlotTextField)
        treesPlantedTheoreticallyTextField.anchorCenterX(to: distanceTravelledTextField)
        treesPlantedTheoreticallyTextField.textColor = .systemGreen
    }
    
    @objc func engageTrackingButtonAction(){
        if let delegate = delegate{
            if delegate.isPlanting(){
                setEngageButtonStart()
                addPathToMap()
                trackingPath.removeAllCoordinates()
                updateTrackingPolyline()
                prevTrackingCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
            }
            else{
                trackingPath.removeAllCoordinates()
                setEngageButtonStop()
                realmDatabase.addToList(list: cacheCoordinates, item: CoordinateInput())
                setNotificationForTrackingList()
            }
            delegate.flipBooleanIsPlanting()
        }
    }
    
    @objc func treesPerPlotInputAction(){
        if(treesPerPlotTextField.text != "0" && treesPerPlotTextField.text != ""){
            if let delegate = delegate{
                treesPerPlot = Int(treesPerPlotTextField.text!)!
                delegate.saveTreesPerPlot(treePerPlot: treesPerPlot)
            }
        }
        calculateTrees()
    }
    
    @objc func undoTap(gesture: UIGestureRecognizer) {
        print("Undo Tapped")
        if let coordinatesCovered = cacheCoordinates.last{
            if let delegate = delegate{
                realmDatabase.clearList(list: coordinatesCovered.input)
                realmDatabase.removeLastInList(list: cacheCoordinates)
                if delegate.isPlanting(){
                    engageTrackingButtonAction()
                }
                if !pathHistory.isEmpty{
                    pathHistory.removeLast()
                }
                reloadAllPaths()
            }
        }
    }
    
    func addPathToMap(){
        let path = GMSMutablePath(path: trackingPath)
        addPolyline(path: path)
        pathHistory.append(path)
    }

    func addCoordinatesToMap(coordianteIndexs: [Int]){
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
        updateTrackingPolyline()
    }
    
    func setEngageButtonStart(){
        engageTrackingButton.layer.borderColor = UIColor.systemGreen.cgColor
        engageTrackingButton.setTitle("Start Planting", for: .normal)
    }
    
    func setEngageButtonStop(){
        engageTrackingButton.layer.borderColor = UIColor.systemRed.cgColor
        engageTrackingButton.setTitle("Stop Planting", for: .normal)
    }
    
    func createAllPaths(){
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
                        updateTrackingPolyline()
                    }
                }
            }
        }
    }
    
    func reloadAllPaths(){
        totalDistance = 0
        mapView.clear()
        print(pathHistory)
        for path in pathHistory{
            print(path)
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
    
    func setDistanceTextField(){
        distanceTravelledTextField.text = String(Double(totalDistance/1000.0).round(to: 2)) + "Km"
    }
    
    func calculateTrees(){
        if treesPerPlot > 0{
            //Caclulation: total distanc/target inter-tree distance
            treesPlantedTheoreticallyTextField.text = String(Int(totalDistance/Double(11547.0/Double(treesPerPlot*200)).squareRoot())) + " Trees"
        }
    }
    
    func updateTrackingPolyline(){
        let polyline = GMSPolyline(path: trackingPath)
        polyline.strokeColor = .systemRed
        polyline.strokeWidth = 5.0
        polyline.map = mapView
    }
    
    func setNotificationForTrackingList(){
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
    
    func addPolyline(path: GMSMutablePath){
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

protocol GPSTreeTrackingModal_Delegate:NSObjectProtocol {
    func flipBooleanIsPlanting()
    func isPlanting() -> Bool
    func closedModal()
    func saveTreesPerPlot(treePerPlot: Int)
}





