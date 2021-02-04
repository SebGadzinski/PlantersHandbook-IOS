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

class TallySheetVC: ProgramicVC {
    
    fileprivate var topLayout : UIView!
    fileprivate var infoLayout : UIView!
    fileprivate var bagUpsLayout : UIView!
    fileprivate var totalsLayout : UIView!
    
    fileprivate let cache: Cache
    
    fileprivate let dateLabel = SUI_Label(title: "", fontSize: FontSize.meduim)
    fileprivate let gpsButton = PH_Button_Tally(title: "GPS", fontSize: FontSize.extraSmall, borderColor: UIColor.green.cgColor)
    fileprivate let plotsButton = PH_Button_Tally(title: "Plots", fontSize: FontSize.extraSmall, borderColor: UIColor.orange.cgColor)
    fileprivate let clearButton = PH_Button_Tally(title: "Clear", fontSize: FontSize.extraSmall, borderColor: UIColor.red.cgColor)
    fileprivate let treeTypesCollectionView = PH_CollectionView_Tally()
    fileprivate let centPerTreeTypeCollectionView = PH_CollectionView_Tally()
    fileprivate let bundlePerTreeTypeCollectionView = PH_CollectionView_Tally()
    fileprivate var infoScrollView = SUI_ScrollView()
    fileprivate var bagUpCollectionViews : [UICollectionView] = []
    fileprivate var bagUpsScrollView = SUI_ScrollView()
    fileprivate let totalCashPerTreeTypesCollectionView = PH_CollectionView_Tally()
    fileprivate let totalTreesPerTreeTypesCollectionView = PH_CollectionView_Tally()
    fileprivate var totalsScrollView = SUI_ScrollView()
    
    fileprivate var clearingData : Bool = false
    fileprivate var widthOfCollectionCell: CGFloat!
    fileprivate var heightOfCollectionCell: CGFloat!
    fileprivate var widthOfCollectionLabel: CGFloat!
    fileprivate var gpsButtonClicked = false
    
    var locationManagerNotificationToken: NotificationToken?
    
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

    override func generateLayout() {
        topLayout = SUI_View(backgoundColor: .systemBackground)
        infoLayout = SUI_View(backgoundColor: .systemBackground)
        bagUpsLayout = SUI_View(backgoundColor: .systemBackground)
        totalsLayout = SUI_View(backgoundColor: .systemBackground)
    }
    
    override func configureViews() {
        setUpOverlay()
        setUpTopLayout()
        setUpInfoLayout()
        setUpBagUpsLayout()
        setUpTotalsLayout()
        setUpTableDelegates()
        keyboardMoveUpWhenTextFieldTouched = 0
    }
    
    override func setActions() {
        clearButton.addTarget(self, action: #selector(clearFieldsBtn), for: .touchUpInside)
        gpsButton.addTarget(self, action: #selector(gpsButtonAction), for: .touchUpInside)
        plotsButton.addTarget(self, action: #selector(plotsButtonAction), for: .touchUpInside)
    }

    func setUpOverlay(){
        let frame = bgView.safeAreaFrame
        
        let blackBarTopLayout = UIView()
        blackBarTopLayout.backgroundColor = .secondaryLabel
        let blackBarBagUpLayout = UIView()
        blackBarBagUpLayout.backgroundColor = .secondaryLabel
        let blackBarTotalLayout = UIView()
        blackBarTotalLayout.backgroundColor = .secondaryLabel
        
        [topLayout, blackBarTopLayout, infoLayout, blackBarBagUpLayout, bagUpsLayout, blackBarTotalLayout, totalsLayout].forEach{bgView.addSubview($0)}

        topLayout.anchor(top: bgView.topAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor,size: .init(width: 0, height: frame.height*0.07))
        blackBarTopLayout.anchor(top: topLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: 3))
        infoLayout.anchor(top: blackBarTopLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.19))
        blackBarBagUpLayout.anchor(top: infoLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: 3))
        bagUpsLayout.anchor(top: blackBarBagUpLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.41))
        blackBarTotalLayout.anchor(top: bagUpsLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: 3))
        totalsLayout.anchor(top: blackBarTotalLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: bgView.bottomAnchor, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: 0))
        
        heightOfCollectionCell = infoLayout.safeAreaFrame.height * 0.31
    }
    
    func setUpTopLayout(){
        
        let topFrame = topLayout.safeAreaFrame

        [dateLabel, gpsButton, plotsButton, clearButton].forEach{topLayout.addSubview($0)}

        dateLabel.anchor(top: topLayout.topAnchor, leading: topLayout.leadingAnchor, bottom: topLayout.bottomAnchor, trailing: nil, padding: .init(top: topLayout.center.y, left: 5, bottom: 0, right: 0), size: .init(width: topFrame.width*0.4, height: 0))
        findHandbookDate()

        clearButton.anchor(top: topLayout.topAnchor, leading: nil, bottom: topLayout.bottomAnchor, trailing: topLayout.trailingAnchor, padding: .init(top: topFrame.height/6, left: 0, bottom: topFrame.height/6, right: 10), size: .init(width: topFrame.width*0.15, height: 0))
        clearButton.layer.borderColor = UIColor.systemRed.cgColor

        plotsButton.anchor(top: topLayout.topAnchor, leading: nil, bottom: topLayout.bottomAnchor, trailing: clearButton.leadingAnchor, padding: .init(top: topFrame.height/6, left: 0, bottom: topFrame.height/6, right: 10), size: .init(width: topFrame.width*0.15, height: 0))
        plotsButton.layer.borderColor = UIColor.systemOrange.cgColor

        gpsButton.anchor(top: topLayout.topAnchor, leading: nil, bottom: topLayout.bottomAnchor, trailing: plotsButton.leadingAnchor, padding: .init(top: topFrame.height/6, left: 0, bottom: topFrame.height/6, right: 10), size: .init(width: topFrame.width*0.2, height: 0))
        gpsButton.layer.borderColor = UIColor.systemGreen.cgColor
    }
    
    func setUpInfoLayout(){
        let treeTypeImgString = (self.traitCollection.userInterfaceStyle == .dark ? "icons8-tree-64-white.png" : "icons8-tree-64.png")
        let cenPerTreeImgString = (self.traitCollection.userInterfaceStyle == .dark ? "icons8-cent-50-white.png" : "icons8-cent-100.png")
        let bundleImgString = (self.traitCollection.userInterfaceStyle == .dark ? "icons8-hay-52-white.png" : "icons8-hay-26.png")

        let treeTypesImg = UIImageView(image: UIImage(named: treeTypeImgString)!)
        let centPerTreeImg = UIImageView(image: UIImage(named: cenPerTreeImgString)!)
        let bundleImg = UIImageView(image: UIImage(named: bundleImgString)!)
        
        [treeTypesImg, centPerTreeImg, bundleImg, infoScrollView].forEach{infoLayout.addSubview($0)}
        
        widthOfCollectionLabel = infoLayout.safeAreaFrame.width*0.1
        
        treeTypesImg.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 5, bottom: 0, right: 0), size: .init(width: widthOfCollectionLabel, height: heightOfCollectionCell))

        centPerTreeImg.anchor(top: treeTypesImg.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 5, bottom: 0, right: 0))
        centPerTreeImg.anchorSize(to: treeTypesImg)

        bundleImg.anchor(top: centPerTreeImg.bottomAnchor, leading: infoLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 5, bottom: 0, right: 0))
        bundleImg.anchorSize(to: treeTypesImg)

        infoScrollView.frame = .init(x: 0, y: 0, width: infoLayout.safeAreaFrame.width - treeTypesImg.frame.width, height: infoLayout.safeAreaFrame.height)
        infoScrollView.translatesAutoresizingMaskIntoConstraints = false
        infoScrollView.isScrollEnabled = true
        infoScrollView.showsHorizontalScrollIndicator = false
        infoScrollView.backgroundColor = .systemBackground
        infoScrollView.anchor(top: infoLayout.topAnchor, leading: treeTypesImg.trailingAnchor, bottom: infoLayout.bottomAnchor, trailing: infoLayout.trailingAnchor)
        
        widthOfCollectionCell = infoScrollView.safeAreaFrame.width * 0.20
        
        [treeTypesCollectionView, centPerTreeTypeCollectionView, bundlePerTreeTypeCollectionView].forEach{infoScrollView.addSubview($0)}

        treeTypesCollectionView.anchor(top: infoScrollView.topAnchor, leading: infoScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 3, bottom: 0, right: 0), size: .init(width: widthOfCollectionCell*9, height: heightOfCollectionCell))

        centPerTreeTypeCollectionView.anchor(top: treeTypesCollectionView.bottomAnchor, leading: infoScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 3, bottom: 0, right: 0))
        centPerTreeTypeCollectionView.anchorSize(to: treeTypesCollectionView)

        bundlePerTreeTypeCollectionView.anchor(top: centPerTreeTypeCollectionView.bottomAnchor, leading: infoScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 3, bottom: 0, right: 0))
        bundlePerTreeTypeCollectionView.anchorSize(to: treeTypesCollectionView)

        infoScrollView.contentSize = .init(width: widthOfCollectionCell*9, height: infoLayout.safeAreaFrame.height)
    }
    
    func setUpBagUpsLayout(){
        bagUpsLayout.addSubview(bagUpsScrollView)
        
        bagUpsScrollView.frame = .init(x: 0, y: 0, width: bagUpsLayout.safeAreaFrame.width, height: bagUpsLayout.safeAreaFrame.height)
        bagUpsScrollView.anchor(top: bagUpsLayout.topAnchor, leading: bagUpsLayout.leadingAnchor, bottom: bagUpsLayout.bottomAnchor, trailing: bagUpsLayout.trailingAnchor)
        bagUpsScrollView.translatesAutoresizingMaskIntoConstraints = false
        bagUpsScrollView.isScrollEnabled = true
        bagUpsScrollView.showsHorizontalScrollIndicator = false
        bagUpsScrollView.showsVerticalScrollIndicator = true
        bagUpsScrollView.backgroundColor = .systemBackground
        bagUpsScrollView.isDirectionalLockEnabled = true
        
        var labels : [UILabel] = []
        
        for i in 0..<20 {
            let label = UILabel()
            label.text = String(i+1)
            label.textAlignment = .center
            label.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.large))
            labels.append(label)
            bagUpCollectionViews.append(PH_CollectionView_Tally())
            bagUpCollectionViews[i].tag = i
        }
        
        labels.forEach{bagUpsScrollView.addSubview($0)}
        bagUpCollectionViews.forEach{bagUpsScrollView.addSubview($0)}
        
        labels[0].anchor(top: bagUpsScrollView.topAnchor, leading: bagUpsScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 10, left: 0, bottom: 0, right: 0), size: .init(width: widthOfCollectionLabel+5, height: heightOfCollectionCell*0.90)) // + 5 for margins on  a imageview
        
        bagUpCollectionViews[0].anchor(top: bagUpsScrollView.topAnchor, leading: labels[0].trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 3, bottom: 0, right: 0), size: .init(width: widthOfCollectionCell*9.5, height: heightOfCollectionCell*0.90))
        
        labels[0].anchorCenterY(to: bagUpCollectionViews[0])
        
        for i in 1..<labels.count {
            bagUpCollectionViews[i].anchor(top: bagUpCollectionViews[i-1].bottomAnchor, leading: bagUpCollectionViews[i-1].leadingAnchor, bottom: nil, trailing: nil)
            bagUpCollectionViews[i].anchorSize(to: bagUpCollectionViews[i-1])
    
            labels[i].anchor(top: nil, leading: bagUpsScrollView.leadingAnchor, bottom: nil, trailing: nil)
            labels[i].anchorSize(to: labels[i-1])
            labels[i].anchorCenterY(to: bagUpCollectionViews[i])
        }
        
        bagUpsScrollView.contentSize = .init(width: widthOfCollectionCell*9.6, height: heightOfCollectionCell*27) //Seems as margins increased the height
    }
    
    func setUpTotalsLayout(){
        let totalTreeImgString = (self.traitCollection.userInterfaceStyle == .dark ? "icons8-floating-island-forest-64-white.png" : "icons8-floating-island-forest-64.png")
        let totalCashImgString = (self.traitCollection.userInterfaceStyle == .dark ? "icons8-cash-app-50-white.png" : "icons8-cash-app-100.png")
        
        let totalTreeImg = UIImageView(image: UIImage(named: totalTreeImgString)!)
        let totalCashImg = UIImageView(image: UIImage(named: totalCashImgString)!)
        
        let totalsFrame = totalsLayout.safeAreaFrame
        
        [totalTreeImg, totalCashImg, totalsScrollView].forEach{totalsLayout.addSubview($0)}
                
        totalTreeImg.anchor(top: totalsLayout.topAnchor, leading: totalsLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 5, bottom: 0, right: 0), size: .init(width: widthOfCollectionLabel, height: heightOfCollectionCell))

        totalCashImg.anchor(top: totalTreeImg.bottomAnchor, leading: totalsLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 5, bottom: 0, right: 0))
        totalCashImg.anchorSize(to: totalTreeImg)

        totalsScrollView.frame = .init(x: 0, y: 0, width: totalsFrame.width - totalTreeImg.frame.width, height: totalsFrame.height)
        totalsScrollView.translatesAutoresizingMaskIntoConstraints = false
        totalsScrollView.isScrollEnabled = true
        totalsScrollView.isDirectionalLockEnabled = true
        totalsScrollView.showsHorizontalScrollIndicator = false
        totalsScrollView.showsVerticalScrollIndicator = false
        totalsScrollView.backgroundColor = .systemBackground
        totalsScrollView.anchor(top: totalsLayout.topAnchor, leading: totalTreeImg.trailingAnchor, bottom: totalsLayout.bottomAnchor, trailing: totalsLayout.trailingAnchor)
        
        [totalCashPerTreeTypesCollectionView, totalTreesPerTreeTypesCollectionView,].forEach{totalsScrollView.addSubview($0)}

        totalTreesPerTreeTypesCollectionView.anchor(top: totalsScrollView.topAnchor, leading: totalsScrollView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 3, bottom: 0, right: 0), size: .init(width: widthOfCollectionCell*9, height: heightOfCollectionCell))

        totalCashPerTreeTypesCollectionView.anchor(top: totalTreesPerTreeTypesCollectionView.bottomAnchor, leading: totalTreesPerTreeTypesCollectionView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 2, left: 0, bottom: 0, right: 0))
        totalCashPerTreeTypesCollectionView.anchorSize(to: totalTreesPerTreeTypesCollectionView)

        totalsScrollView.contentSize = .init(width: widthOfCollectionCell*9, height: totalTreesPerTreeTypesCollectionView.frame.height + totalCashPerTreeTypesCollectionView.frame.height)
    }
    
    func setUpTableDelegates(){
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
    
    func findHandbookDate(){
        if let subBlock = realmDatabase.getSubBlockById(subBlockId: cache.subBlockId){
            dateLabel.text = getDate(from: subBlock.date)
        }
    }
    
    @objc func gpsButtonAction(){
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
    
    func goToGPSModal(){
        let gpsModal = GPSTreeTrackingModal(title: self.title! + " GPS Tree Tracking", cacheCoordinates: cache.coordinatesCovered, treesPerPlot: cache.treePerPlot, locationManager: locationManager)
        gpsModal.delegate = self
        gpsModal.modalPresentationStyle = .popover
        present(gpsModal, animated: true)
    }
    
    @objc func plotsButtonAction(){
        let plotsModal = PlotsModal(title: self.title! + " Plots", plots: cache.plots)
        plotsModal.modalPresentationStyle = .popover
        present(plotsModal, animated: true)
    }
    
    @objc func treeTypesInputAction(sender: UITextField){
        realmDatabase.updateList(list: cache.treeTypes, index: sender.tag, item: sender.text!)
    }
    
    @objc func centPerTreeInputAction(sender: UITextField){
        if(containsLetters(input: sender.text!)){
            let alert = UIAlertController(title: "Error: Incorrect Type", message: "Please use numbers only for cent per tree value", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
            sender.text = ""
        }
        else{
            realmDatabase.updateList(list: cache.centPerTreeTypes, index: sender.tag, item: sender.text!.doubleValue)
            calculateTotalInLane(lane: sender.tag)
        }
    }
    
    @objc func bundleAmountInputAction(sender: UITextField){
        if(containsLetters(input: sender.text!)){
            let alert = UIAlertController(title: "Error: Incorrect Type", message: "Please use numbers only for bundle amount", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
            sender.text = ""
        }
        else{
            realmDatabase.updateList(list: cache.bundlesPerTreeTypes, index: sender.tag, item: integer(from: sender))
            if(cache.bundlesPerTreeTypes[sender.tag] == 0){
                sender.text = ""
            }
        }
    }
    
    @objc func bagUpInputAction(sender: UITextField){
        let cvTag = sender.superview!.superview!.superview!.tag
        let tfTag = sender.tag
        let value = integer(from: sender)
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
                calculateTotalInLane(lane: tfTag)
                if(cache.bagUpsPerTreeTypes[cvTag].input[tfTag] == 0){
                    sender.text = ""
                }
            }
        }
    }
    
    @objc func clearFieldsBtn(sender: UIButton){
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
    
    func calculateTotalInLane(lane: Int){
        var totalTreesInBagUps : Int = 0
        for x in 0...19{
            totalTreesInBagUps += cache.bagUpsPerTreeTypes[x].input[lane]
        }
        realmDatabase.updateList(list: cache.totalTreesPerTreeTypes, index: lane, item: totalTreesInBagUps)
        realmDatabase.updateList(list: cache.totalCashPerTreeTypes, index: lane, item: (Double(totalTreesInBagUps)*cache.centPerTreeTypes[lane]))
        totalTreesPerTreeTypesCollectionView.reloadData()
        totalCashPerTreeTypesCollectionView.reloadData()
    }
    
    func stopTrackingLocation(){
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = false
    }
}


extension TallySheetVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
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
            createAdvancedTallyCell(cell: cell, toolBar: kb, tag: indexPath.row, keyboardType: .default)
            cell.input.addTarget(self, action: #selector(treeTypesInputAction), for: .editingDidEnd)
            cell.input.text = cache.treeTypes[indexPath.row]
            return cell
        }
        else if(collectionView == self.centPerTreeTypeCollectionView){
            createAdvancedTallyCell(cell: cell, toolBar: kb, tag: indexPath.row, keyboardType: .decimalPad)
            cell.input.addTarget(self, action: #selector(centPerTreeInputAction), for: .editingDidEnd)
            cell.input.text = (cache.centPerTreeTypes[indexPath.row] == 0 ? "" : String(cache.centPerTreeTypes[indexPath.row]))
            return cell
        }
        else if(collectionView == self.bundlePerTreeTypeCollectionView){
            createAdvancedTallyCell(cell: cell, toolBar: kb, tag: indexPath.row, keyboardType: .numberPad)
            cell.input.addTarget(self, action: #selector(bundleAmountInputAction), for: .editingDidEnd)
            cell.input.text = (cache.bundlesPerTreeTypes[indexPath.row] == 0 ? "" : String(cache.bundlesPerTreeTypes[indexPath.row]))
            return cell
        }
        else{
            createAdvancedTallyCell(cell: cell, toolBar: kb, tag: indexPath.row, keyboardType: .numberPad)
            cell.input.addTarget(self, action: #selector(bagUpInputAction), for: .editingDidEnd)
            cell.input.text = (cache.bagUpsPerTreeTypes[collectionView.tag].input[indexPath.row] == 0 ? "" : String(cache.bagUpsPerTreeTypes[collectionView.tag].input[indexPath.row]))
            return cell
        }
    }
}

extension TallySheetVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if cache.isPlanting{
            if !locations.isEmpty{
                for i in 0..<locations.count{
                    let newCoordinate = Coordinate(longitude: locations[i].coordinate.longitude, latitude: locations[i].coordinate.latitude)
                    realmDatabase.addToList(list: cache.coordinatesCovered.last!.input, item: newCoordinate)
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

extension TallySheetVC: GPSTreeTrackingModal_Delegate{
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
